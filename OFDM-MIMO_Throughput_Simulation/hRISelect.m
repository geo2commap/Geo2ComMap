function [RI, CQI] = hRISelect(H,nVar,alg,cqiTableName,RB_Num)

nTxAnts = size(H,4);
nRxAnts = size(H,3);
maxRank = min(nTxAnts,nRxAnts);
maxRank = min(maxRank,4);
validRanks = 1:maxRank;

if strcmpi(alg,'MaxSINR')
    RI = riSelectPMI(H,nVar,validRanks,RB_Num);
else % maxSE
    [RI, CQI] = riSelectCQI(H,nVar,cqiTableName,validRanks,RB_Num);
end

end

% Selection of rank indicator based on maximizing spectral efficiency
function [RI, CQI] = riSelectCQI(H,nVar,cqiTableName,validRanks,RB_Num)

% For each valid rank, select the best CQI. Then, find the rank
% that maximizes modulation and coding efficiency
maxRank = max(validRanks);
efficiency = NaN(maxRank,1);
cqiWideband = NaN(maxRank,1);

% H = single(H);
H = squeeze(mean(H,2));
H = permute(H,[2,3,1]);
[~, ~, V] = pagesvd(pagemtimes(H,'ctranspose',H,'none'));
V_mean = mean(V,3);

for rank = validRanks
    % Determine the CQI and PMI for the current rank
    [cqi, cqiInfo] = hCQISelect(rank,H,V_mean,nVar,cqiTableName,RB_Num);

    % Get wideband CQI
    cqiWideband(rank) = cqi;

    % If the wideband CQI is appropriate, calculate the efficiency
    if all(cqi ~= 0)
        if ~any(isnan(cqi))
            % Calculate throughput-related metric using number of
            % layers, code rate and modulation, and estimated BLER
            blerWideband = cqiInfo.TransportBLER(1,:);
            ncw = numel(cqi);
            cwLayers = floor((rank + (0:ncw-1)) / ncw);
            mcs = hCQITables(cqiTableName,cqi);
            eff = cwLayers .* (1 - blerWideband) * mcs(:,4);
            efficiency(rank) = eff;
        end
    else
        efficiency(rank) = 0;
    end
end

% Return the rank that maximizes the spectral efficiency and the
% corresponding PMI.
[~,RI] = max(efficiency);
CQI = cqiWideband(RI);

end