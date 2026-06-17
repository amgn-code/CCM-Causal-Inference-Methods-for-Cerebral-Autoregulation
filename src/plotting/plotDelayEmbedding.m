function plotDelayEmbedding(M, signalName)
% plotDelayEmbedding
%
% Plots a delay embedding matrix.
%
% If embedding dimension is:
%   e = 1  -> plots signal value vs row index
%   e = 2  -> plots 2D embedding
%   e >= 3 -> plots first 3 dimensions as a 3D projection
%
% Inputs:
%   M          = delay embedding matrix
%   signalName = name used in labels/title, e.g. 'MAP', 'CO2', 'CBFV'

    if nargin < 2
        signalName = 'x';
    end

    e = size(M, 2);

    % Only plot rows where the needed coordinates are not NaN
    dimsToPlot = min(e, 3);
    validRows = all(~isnan(M(:, 1:dimsToPlot)), 2);

    if e == 1

        plot(find(validRows), M(validRows, 1), '.')
        xlabel('Sample index')
        ylabel(sprintf('%s(t)', signalName))
        title(sprintf('1D Delay Embedding of %s', signalName))

    elseif e == 2

        plot(M(validRows, 1), M(validRows, 2), '.')
        xlabel(sprintf('%s(t)', signalName))
        ylabel(sprintf('%s(t - \\tau)', signalName))
        title(sprintf('2D Delay Embedding of %s', signalName))

    else

        plot3(M(validRows, 1), M(validRows, 2), M(validRows, 3), '.')
        xlabel(sprintf('%s(t)', signalName))
        ylabel(sprintf('%s(t - \\tau)', signalName))
        zlabel(sprintf('%s(t - 2\\tau)', signalName))

        if e == 3
            title(sprintf('3D Delay Embedding of %s', signalName))
        else
            title(sprintf('3D Projection of %dD Delay Embedding of %s', e, signalName))
        end

    end

    grid on

end