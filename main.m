%% Clean Start

clearvars, clc, close all

%% Generate Test Signals
fs = 4;
t = (0:1/fs:300)';

x = sin(2*pi*0.05*t) + 0.5*sin(2*pi*0.13*t);
%y = 0.8*x + 0.2*sin(2*pi*0.02*t);

y = zeros(size(x));

for i = 2:length(x)
    y(i) = 0.8*y(i-1) + 0.4*x(i-1);
end


n  = length(x);


%% User Editable Parameters
e = 3;
tau = 4;  

% Dependent Parameter
firstEmbeddingIndex = 1 +(e-1) * tau;

%% Find Embeddings

Mx = findEmbedding(x, firstEmbeddingIndex, tau, e);
My = findEmbedding(y, firstEmbeddingIndex, tau, e);

%% Plot Embedding Manifolds

figure()
plot3(Mx(:,1), Mx(:,2), Mx(:,3), '.')
xlabel('x(t)')
ylabel('x(t - tau)')
zlabel('x(t - 2tau)')
title('Delay Embedding of x')
grid on

%% User editable experimental parameters

maxEmbeddingSize = n - firstEmbeddingIndex + 1;
EmbeddingSizes = [50 75 100 150 200 300 450 600 800 1000 maxEmbeddingSize];
numTrials = 3;

%%

ccmEstimateData = struct();
ccmEstimateMatrix = NaN(n, 2+ numTrials*2);

ccmCorrData = struct();

x_estimate = NaN(n,1);
y_estimate = NaN(n,1);


for l = 1:length(EmbeddingSizes)

    ccmEstimateMatrix = [x, y];

    xCorrelations = NaN(1, numTrials);
    yCorrelations = NaN(1, numTrials);

    for m = 1:numTrials
        
        L = EmbeddingSizes(l); 
        
        libStart = randi([firstEmbeddingIndex, n - L + 1]);
        libEnd = libStart + L - 1;

        for i = firstEmbeddingIndex:n
            [neighborDistances_x, neighborIndices_x] = findEmbeddingNeighbors(e, tau, Mx, i, libStart, libEnd);
            [neighborDistances_y, neighborIndices_y] = findEmbeddingNeighbors(e, tau, My, i, libStart, libEnd);

            x_estimate(i) = findEstimate(neighborDistances_y, neighborIndices_y, x);
            y_estimate(i) = findEstimate(neighborDistances_x, neighborIndices_x, y);

        end

        ccmEstimateMatrix(:, 2*m + 1) = x_estimate;
        ccmEstimateMatrix(:, 2*m + 2) = y_estimate;

        validX = ~isnan(x_estimate);
        R_x = corrcoef(x(validX), x_estimate(validX));
        xCorrelations(m) = R_x(1,2);

        validY = ~isnan(y_estimate);
        R_y = corrcoef(y(validY), y_estimate(validY));
        yCorrelations(m) = R_y(1,2);

        x_estimate = NaN(n,1);
        y_estimate = NaN(n,1);
      

    end
   
    matrixName = sprintf('LibSize_%d', EmbeddingSizes(l));

    xEstimateColumns = 3:2:(2 + 2*numTrials);
    yEstimateColumns = 4:2:(2 + 2*numTrials);

    averageXEstimate = mean(ccmEstimateMatrix(:, xEstimateColumns), 2, 'omitnan');
    averageYEstimate = mean(ccmEstimateMatrix(:, yEstimateColumns), 2, 'omitnan');
    
    ccmEstimateData.(matrixName).data = ccmEstimateMatrix;
    ccmEstimateData.(matrixName).means = [averageXEstimate, averageYEstimate];

    ccmCorrData.(matrixName).correlations = [xCorrelations; yCorrelations];
    ccmCorrData.(matrixName).meanCorrelations = mean( ...
        ccmCorrData.(matrixName).correlations, 2, 'omitnan');
    
end
 

%%

meanXByL = NaN(length(EmbeddingSizes), 1);
meanYByL = NaN(length(EmbeddingSizes), 1);

for l = 1:length(EmbeddingSizes)

    matrixName = sprintf('LibSize_%d', EmbeddingSizes(l));

    meanXByL(l) = ccmCorrData.(matrixName).meanCorrelations(1);
    meanYByL(l) = ccmCorrData.(matrixName).meanCorrelations(2);

end

%%

figure()
plot(EmbeddingSizes, meanXByL, '-o')
hold on
plot(EmbeddingSizes, meanYByL, '-o')
hold off

xlabel('Library Size L')
ylabel('Cross-map skill \rho')
legend('M_y estimates x', 'M_x estimates y', 'Location', 'best')
title('CCM Convergence')
grid on

%% Diagnostic Plot Using Average Estimates

selectedL = EmbeddingSizes(end);
matrixName = sprintf('LibSize_%d', selectedL);

averageEstimates = ccmEstimateData.(matrixName).means;

x_from_y_avg = averageEstimates(:,1);  % My estimates x
y_from_x_avg = averageEstimates(:,2);  % Mx estimates y

validX = ~isnan(x_from_y_avg);
validY = ~isnan(y_from_x_avg);

figure()

subplot(2,2,1)
plot(t, x, 'k')
hold on
plot(t, x_from_y_avg, 'r--')
hold off
xlabel('Time (s)')
ylabel('x')
title(sprintf('M_y estimates x, L = %d', selectedL))
legend('Actual x', 'Estimated x')
grid on

subplot(2,2,2)
scatter(x(validX), x_from_y_avg(validX), '.')
hold on
plot(xlim, xlim, 'k--')
hold off
xlabel('Actual x')
ylabel('Estimated x')
title('Observed vs Estimated x')
grid on

subplot(2,2,3)
plot(t, y, 'k')
hold on
plot(t, y_from_x_avg, 'r--')
hold off
xlabel('Time (s)')
ylabel('y')
title(sprintf('M_x estimates y, L = %d', selectedL))
legend('Actual y', 'Estimated y')
grid on

subplot(2,2,4)
scatter(y(validY), y_from_x_avg(validY), '.')
hold on
plot(xlim, xlim, 'k--')
hold off
xlabel('Actual y')
ylabel('Estimated y')
title('Observed vs Estimated y')
grid on



%% 3D Plot Data Across All Library Sizes

averageXByL = NaN(length(EmbeddingSizes), n);
averageYByL = NaN(length(EmbeddingSizes), n);

for l = 1:length(EmbeddingSizes)

    matrixName = sprintf('LibSize_%d', EmbeddingSizes(l));

    averageEstimates = ccmEstimateData.(matrixName).means;

    averageXByL(l, :) = averageEstimates(:,1)';
    averageYByL(l, :) = averageEstimates(:,2)';

end


%% 3D Average Estimate Surfaces

[TGrid, LGrid] = meshgrid(t, EmbeddingSizes);

figure()

subplot(1,2,1)
surf(TGrid, LGrid, averageXByL)
shading interp
xlabel('Time (s)')
ylabel('Library Size L')
zlabel('Estimated x')
title('M_y estimates x across L')
grid on
view(45, 30)

subplot(1,2,2)
surf(TGrid, LGrid, averageYByL)
shading interp
xlabel('Time (s)')
ylabel('Library Size L')
zlabel('Estimated y')
title('M_x estimates y across L')
grid on
view(45, 30)









%{
Panel A: MAP ↔ CBFV convergence curves
Panel B: CO2 ↔ CBFV convergence curves
Panel C: MAP ↔ CO2 convergence curves
Panel D: summary heatmap of max-L rho or convergence slope
%}