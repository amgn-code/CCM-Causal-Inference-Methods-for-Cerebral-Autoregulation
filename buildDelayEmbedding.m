function [mx, timeIndices] = buildDelayEmbedding(x, e, tau)
% buildDelayEmbedding
%
% Builds a delay embedding from a single time-domain signal.
%
% Inputs:
%   x   = column vector time series
%   e   = embedding dimension
%   tau = delay in samples
%
% Outputs:
%   mx        = delay embedding matrix
%   timeIndex = time indices in x corresponding to each row of mx
%
% Example:
%   x = [10 20 30 40 50 60];
%   e = 3;
%   tau = 1;
%
%   mx =
%       [30 20 10
%        40 30 20
%        50 40 30
%        60 50 40]
%
%   timeIndex =
%       [3; 4; 5; 6]


    n = length(x);
    firstUsableIndex = 1 + (e - 1) * tau;
    
    timeIndices = (firstUsableIndex:n)';
    numVectors = length(timeIndices);

    mx = zeros(numVectors, e);

    for row = 1:numVectors
        t = timeIndices(row);

        for dim = 1:e
            delayAmount = (dim - 1) * tau;
            mx(row, dim) = x(t - delayAmount);
        end
    end

end