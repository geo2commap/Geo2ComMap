FigIDX = 1;
%% CDF
figure(FigIDX); FigIDX=FigIDX+1;
cdfplot(meanSNR(:,1)); grid on;
title('SNR (dB)');
xlim([0 inf])

figure(FigIDX); FigIDX=FigIDX+1;
cdfplot(meanCap(:,1)); grid on;
title('Capacity (bps/Hz)');
xlim([0 inf])

figure(FigIDX); FigIDX=FigIDX+1;
cdfplot(meanRCN(:,1)); grid on;
title('Reciprocal Condition Number');
xlim([0 inf])

figure(FigIDX); FigIDX=FigIDX+1;
cdfplot(RI_ALL(:,1)); grid on;
title('Rank Indicator');
xlim([0 inf])

figure(FigIDX); FigIDX=FigIDX+1;
cdfplot(Throughput_ALL(:,1)); grid on;
title('Throughput (Mbps)');
xlim([0 inf])

figure(FigIDX); FigIDX=FigIDX+1;
scatter(agent(:,1),agent(:,2),[],Throughput_ALL,"filled")
colorbar
hold on
plot(anchor(1,1),anchor(1,2),'ro')
legend("Rx","Tx")
xlim([min(agent(:,1:2),[],'all')-50 max(agent(:,1:2),[],'all')+50])
ylim([min(agent(:,1:2),[],'all')-50 max(agent(:,1:2),[],'all')+50])