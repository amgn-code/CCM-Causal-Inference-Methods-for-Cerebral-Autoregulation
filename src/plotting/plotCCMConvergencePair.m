function plotCCMConvergencePair(ccmResultA, ccmResultB, EmbeddingSizes, plotTitle)
% plotCCMConvergencePair
%
% Plots two CCM convergence curves on the same axes.

    L = EmbeddingSizes;

    plot(L, ccmResultA.meanRho, '-o', ...
        'DisplayName', ccmResultA.pairLabel)
    hold on

    plot(L, ccmResultB.meanRho, '-o', ...
        'DisplayName', ccmResultB.pairLabel)

    hold off

    xlabel('Library Size L')
    ylabel('Cross-map skill \rho')
    title(plotTitle)
    legend('Location', 'best')
    grid on

end