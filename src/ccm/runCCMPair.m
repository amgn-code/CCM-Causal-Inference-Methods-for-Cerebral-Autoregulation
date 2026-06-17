function ccmPairResult = runCCMPair(M_source, targetSignal, e, tau, firstEmbeddingIndex, EmbeddingSizes, numTrials, pairLabel)
% runCCMPair
%
% Uses one embedding manifold to estimate one target signal.
%
% Example:
%   runCCMPair(M_cbv, map, ...)
%
% means:
%   M_CBV estimates MAP

    if nargin < 8
        pairLabel = 'CCM pair';
    end

    n = length(targetSignal);
    numLibrarySizes = length(EmbeddingSizes);

    estimateData = struct();
    corrData = struct();

    rhoTrials = NaN(numLibrarySizes, numTrials);
    meanRho = NaN(numLibrarySizes, 1);
    stdRho = NaN(numLibrarySizes, 1);

    meanEstimateByL = NaN(n, numLibrarySizes);

    for l = 1:numLibrarySizes

        L = EmbeddingSizes(l);

        ccmEstimateMatrix = NaN(n, 1 + numTrials);
        ccmEstimateMatrix(:,1) = targetSignal;

        correlations = NaN(1, numTrials);

        for m = 1:numTrials

            targetEstimate = NaN(n,1);

            libStart = randi([firstEmbeddingIndex, n - L + 1]);
            libEnd = libStart + L - 1;

            for i = firstEmbeddingIndex:n

                [neighborDistances, neighborIndices] = findEmbeddingNeighbors( ...
                    e, tau, M_source, i, libStart, libEnd);

                targetEstimate(i) = findEstimate( ...
                    neighborDistances, neighborIndices, targetSignal);

            end

            ccmEstimateMatrix(:, m + 1) = targetEstimate;

            validRows = ~isnan(targetEstimate);

            R = corrcoef(targetSignal(validRows), targetEstimate(validRows));
            correlations(m) = R(1,2);

        end

        matrixName = sprintf('LibSize_%d', L);

        averageEstimate = mean(ccmEstimateMatrix(:, 2:end), 2, 'omitnan');

        estimateData.(matrixName).data = ccmEstimateMatrix;
        estimateData.(matrixName).meanEstimate = averageEstimate;

        corrData.(matrixName).correlations = correlations;
        corrData.(matrixName).meanCorrelation = mean(correlations, 'omitnan');

        rhoTrials(l,:) = correlations;
        meanRho(l) = mean(correlations, 'omitnan');
        stdRho(l) = std(correlations, 0, 2, 'omitnan');

        meanEstimateByL(:,l) = averageEstimate;

    end

    ccmPairResult.pairLabel = pairLabel;
    ccmPairResult.rhoTrials = rhoTrials;
    ccmPairResult.meanRho = meanRho;
    ccmPairResult.stdRho = stdRho;
    ccmPairResult.meanEstimateByL = meanEstimateByL;

    ccmPairResult.estimateData = estimateData;
    ccmPairResult.corrData = corrData;

end