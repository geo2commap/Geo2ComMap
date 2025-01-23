function [cqiIndex, cqiInfo] = hCQISelect(rank,H,V_mean,nVar,cqiTableName,RB_Num)

% csirs_idx = [1:12:1620 2:12:1620];
% csirs_idx = sort(csirs_idx);
% H_temp = squeeze(mean(H,2));
% H_temp = permute(H_temp,[2,3,1]);
% H = H(csirs_idx,:,:,:);

% H = squeeze(mean(H,2));
% H = permute(H,[2,3,1]);
% [~, ~, V] = pagesvd(pagemtimes(H,'ctranspose',H,'none'));
% V_mean = mean(V,3);

W = V_mean(:,1:rank);

% Calculate the SINR values as per LMMSE method
R = pagemtimes(H,W);
[~, sb, vb] = pagesvd(R,"econ","vector"); % sb in columns
a1=1./(pagetranspose(sb .* sb)+(nVar*ones(1,size(W,2)))); % 1./(Sd^(2)+nVar)
a2 = (nVar*permute(sum(a1 .* (abs(vb) .^2), 2),[3 1 2])).^-1; % Same as 1./diag( nVar*(V.*a1')*V' );
sinr = real(a2-1);

SINR_in_dB = 10*log10(sinr+10e-16);

% Get modulation orders and target code rates from CQI table
cqiTable = nr5g.internal.nrCQITables(cqiTableName);
cqiTable = cqiTable(:,2:3);

% Get unique CQI.Qm values from the CQI table
tableQms = unique(cqiTable(:,1));
tableQms = tableQms(~isnan(tableQms));

% Get corresponding modulation strings
mods = unique([nr5g.internal.nrPDSCHConfigBase.Modulation_Values nr5g.internal.pusch.ConfigBase.Modulation_Values]);
allCQI.Qms = cellfun(@nr5g.internal.getQm,mods);
tableModulations = arrayfun(@(x)mods(allCQI.Qms==x),tableQms);

PDSCH = RB_Num*12*14; %temp
nCombosCQI = size(cqiTable,1);
CQI.TableRowCombos = 1:16;
CQI.Qm = NaN(nCombosCQI,1);
CQI.G = NaN(nCombosCQI,1);
CQI.TransportBlockSize = NaN(nCombosCQI,1);
CQI.DLSCHInfo = repmat(nrDLSCHInfo(1,0.5),nCombosCQI,1);
for CQI_idx = 2:nCombosCQI
    % Get corresponding CQI.Qm combination
    CQI.Qm(CQI_idx,1) = cqiTable(CQI_idx,1);
    % Get PXSCH capacity
    CQI.G(CQI_idx,1) = PDSCH * CQI.Qm(CQI_idx,1) * rank;

    % Get target code rates and transport block sizes.
    % Note that the 'modulations' and 'targetCodeRates' passed
    % to nrTBS are only for CQI.Qm > 0, but the output is assigned
    % for all codewords because nrTBS keys the number of
    % codewords from sum(NL). Any elements of
    % CQI.TransportBlockSize and EffectiveCodeRate corresponding to
    % invalid CQI.Qm are not subsequently used, because they are
    % avoided via checks on variable 'tuples' created below
    modulations = arrayfun(@(x)tableModulations(tableQms==x),CQI.Qm(CQI_idx,1));

    targetCodeRates = cqiTable(CQI_idx,2) / 1024;
    CQI.TransportBlockSize(CQI_idx,1) = nrTBS(modulations,rank,RB_Num,12*14,targetCodeRates(CQI.Qm(CQI_idx,1) > 0));

    % Get DL-SCH information
    CQI.DLSCHInfo(CQI_idx,CQI.Qm(CQI_idx,1) > 0) = arrayfun(@nrDLSCHInfo,CQI.TransportBlockSize(CQI_idx,CQI.Qm(CQI_idx,1) > 0),targetCodeRates(CQI.Qm(CQI_idx,1) > 0));
end

% Get number of code blocks
CQI.C = [CQI.DLSCHInfo(:).C].';

% Get rate matching buffer size
CQI.Ncb = reshape([CQI.DLSCHInfo(:).N],size(CQI.DLSCHInfo));
CQI.NBuffer = arrayfun(@nr5g.internal.ldpc.softBufferSize,CQI.DLSCHInfo,CQI.Ncb) .* CQI.C;

% Get effective code rate, accounting for rate repetition occurring
% in the first RV for code rates lower than the mother code rate
% for the LDPC base graph
den = min(CQI.G,CQI.NBuffer);
CQI.EffectiveCodeRate = CQI.TransportBlockSize ./ den;

% Use different BLER thresholds for different CQI tables
% TS 38.214 Section 5.2.2.1
if strcmpi(cqiTableName,'Table3')
    blerThreshold = 0.00001;
else
    blerThreshold = 0.1;
end

% Perform layer demapping on input SINRs
layerSINRs = nrLayerDemap(SINR_in_dB);

% Set up outputs
effectiveSINR = NaN(nCombosCQI,1);
codeBlockBLER = NaN(nCombosCQI,1);

% Two passes:
% p=1: effective SINR calculation
% p=2: code block BLER calculation
for p = 1:2

    % Get the parameter tuples for all CQI combinations for the
    % current codeword and pass
    if (p==1)

        % Effective SINR calculation, tuple is [CQI.Qm G NBuffer C]
        tuples = [CQI.Qm(:,1) CQI.G(:,1) CQI.NBuffer(:,1) CQI.C(:,1)];

    else % p==2

        % Code block BLER calculation, tuple is [trBlkSizes CQI.Qm ECR]
        tuples = [CQI.TransportBlockSize(:,1) CQI.Qm(:,1) round(CQI.EffectiveCodeRate(:,1)*1024)];

    end

    % Find the unique parameter tuples 'u' and their indices in the
    % overall set of parameter tuples 'ic'
    [u,~,ic] = unique(tuples,'rows');

    % For each parameter tuple not containing NaNs
    for i = find(~any(isnan(u),2)).'

        % Extract that parameter tuple
        tuple = u(i,:);

        % Using that tuple, calculate the effective SINR or code
        % block BLER for the current codeword. Map the result into
        % the elements of the output that correspond to CQIs with
        % parameters matching that tuple
        if (p==1)

            % Get named parameters from tuple
            Qm = tuple(1); G = tuple(2); nBuffer = tuple(3); C = tuple(4);

            splitSINRs = layerSINRs(1);

            % Get the effective SINR, accounting for rate
            % repetition occurring in the first RV for code rates
            % lower than the mother code rate for the LDPC base
            % graph
            e = effectiveSINRMapping(Qm,splitSINRs,1,1,G,nBuffer);
            effectiveSINR(ic==i,1) = e;

        else % p==2

            % Get named parameters from tuple
            trBlkSize = tuple(1); Qm = tuple(2); ECR = tuple(3) / 1024;

            % If a new configuration has been provided, cache the
            % DL-SCH info for the current parameter tuple (to avoid
            % calculating it in every 'sinrToCodeBLER' call)
            % if (newConfiguration)
                CQI.DLSCHInfo(ic==i,1) = nrDLSCHInfo(trBlkSize,ECR);
            % end

            % 'ic1' is the index of the first effective SINR and
            % DL-SCH info corresponding to this parameter tuple. It
            % does not matter which index is selected, as all the
            % indices 'find(ic==i)' point to elements with the same
            % effective SINR value and DL-SCH info
            ic1 = find(ic==i,1,'first');

            % Calculate the code block BLER
            e = effectiveSINR(ic1,1);
            c = sinrToCodeBLER(e,trBlkSize,Qm,ECR,CQI.DLSCHInfo(ic1,1));
            codeBlockBLER(ic==i,1) = c;

        end

    end

end

transportBLER = 1 - (1 - codeBlockBLER).^CQI.C;

% Select the CQI combination with the largest BLER less than or
% equal to the threshold
idx = find(all(transportBLER<=blerThreshold,2),1,'last');

if (isempty(idx))
    idx = 1;
end
tableRow = CQI.TableRowCombos(idx);
cqiIndex = tableRow - 1;

% Create CQI info structure
cqiInfo.EffectiveSINR = effectiveSINR(idx,:);
cqiInfo.TransportBlockSize = CQI.TransportBlockSize(idx,:);
cqiInfo.Qm = cqiTable(tableRow,1);
cqiInfo.TargetCodeRate = cqiTable(tableRow,2) / 1024;
cqiInfo.G = CQI.G(idx,:);
cqiInfo.NBuffer = CQI.NBuffer(idx,:);
cqiInfo.EffectiveCodeRate = CQI.EffectiveCodeRate(idx,:);
cqiInfo.CodeBLER = codeBlockBLER(idx,:);
cqiInfo.C = CQI.C(idx,:);
cqiInfo.TransportBLER = transportBLER(idx,:);

end

function effectiveSINR = effectiveSINRMapping(Qm,SINRs,alpha,beta,G,nBuffer)

    if (nargin==6 && nBuffer<G)
        % Adjust the SINRs to account for the effect of Chase combining;
        % the average number of Chase combined bits is G / min(G,nBuffer)
        SINRs = performChaseCombining(SINRs,G,min(G,nBuffer));
    end

    nCodewords = numel(Qm);
    maxC = size(SINRs,1);
    effectiveSINR = zeros(maxC,nCodewords,'like',SINRs{1});
    for i = 1:maxC
        for cwIdx = 1:nCodewords
            effectiveSINR(i,cwIdx) = wireless.internal.L2SM.calculateEffectiveSINR(SINRs{i,cwIdx},2^Qm(cwIdx),alpha,beta);
        end
    end

end

function outSINRs = performChaseCombining(inSINRs,Gsum,Csum)

    maxC = size(inSINRs,1);
    nCodewords = size(inSINRs,2);
    outSINRs = cell(maxC,nCodewords);
    for i = 1:maxC
        for cwIdx = 1:nCodewords
            outSINRs{i,cwIdx} = inSINRs{i,cwIdx} + 10*log10(Gsum(cwIdx) / Csum(cwIdx));
        end
    end

end

function codeBlockBLER = sinrToCodeBLER(effectiveSINR,trBlkSizes,Qm,ECR,varargin)

    if (nargin==5)
        dlschInfos = varargin{1};
    end

    % Load AWGN table data, converting to double
    awgnTables = loadAWGNTables();

    % Limit ECR to minimum value (1/1024) and maximum value (1023/1024) 
    % expected in the AWGN tables
    ECR = max(ECR,1/1024);
    ECR = min(ECR,1023/1024);

    % Determine the integer R for which R/1024 is closest to the ECR
    R = round(ECR * 1024);

    % For each codeword
    nCodewords = numel(trBlkSizes);
    maxC = size(effectiveSINR,1);
    codeBlockBLER = zeros(maxC,nCodewords);
    for cwIdx = 1:nCodewords

        % Get base graph number (BGN) and lifting size (Zc)
        if (nargin==5)
            dlschInfo = dlschInfos(cwIdx);
        else
            dlschInfo = nrDLSCHInfo(trBlkSizes(cwIdx),ECR(cwIdx));
        end
        BGN = dlschInfo.BGN;
        Zc = dlschInfo.Zc;

        % Get AWGN table for the tuple [BGN, R, Qm, Zc]
        awgnTable = getAWGNTable(awgnTables,BGN,R(cwIdx),Qm(cwIdx),Zc);

        % For each code block
        for i = 1:maxC
        
            % Interpolate the code block BLER from the effective SINR using
            % the AWGN table
            if (~isnan(effectiveSINR(i,cwIdx)))
                codeBlockBLER(i,cwIdx) = wireless.internal.L2SM.interpolatePER(effectiveSINR(i,cwIdx),awgnTable);
            end

        end

    end

end

function t = loadAWGNTables()

    persistent awgnTables;
    if isempty(awgnTables)
        data = coder.load('nr5g/internal/L2SM.mat');
        awgnTables = data.awgnTables;
        for bgn = 1:size(awgnTables.BGN,1)
            for r = 1:size(awgnTables.data(bgn).R,1)
                x = awgnTables.data(bgn).data(r).data;
                awgnTables.data(bgn).data(r).data = double(x);
            end
        end
    end

    t = awgnTables;

end

function t = getAWGNTable(tables,BGN,R,Qm,Zc)

    % Get tables for the BGN
    tables = tables.data(tables.BGN==BGN);

    % Get tables for the appropriate range of R
    tables = tables.data(R>=tables.R(:,1) & R<=tables.R(:,2));

    % Get table with the desired Qm and Zc, and with code rate closest to
    % but not exceeding the desired value
    e = tables.R - R;
    i = find(e>=0,1,'first');
    j = find(tables.Qm==Qm);
    k = find(tables.Zc==Zc);
    t = tables.data(:,:,i,j,k);

end