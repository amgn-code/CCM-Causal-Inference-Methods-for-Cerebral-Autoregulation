function plotCCMDiagnostic(ccmResult, targetSignal, t, targetName, EmbeddingSizes, selectedL)
% plotCCMDiagnostic
%
% Shows actual target signal vs CCM-estimated signal
% for one selected library size.

    selectedIndex = find(EmbeddingSizes == selectedL, 1);

    if isempty(selectedIndex)
        error('selectedL must be one of the EmbeddingSizes values.')
    end

    estimatedSignal = ccmResult.meanEstimateByL(:, selectedIndex);

    validRows = ~isnan(estimatedSignal);

    subplot(1,2,1)
    plot(t, targetSignal, 'k')
    hold on
    plot(t, estimatedSignal, 'r--')
    hold off
    xlabel('Time (s)')
    ylabel(targetName)
    title(sprintf('%s, L = %d', ccmResult.pairLabel, selectedL))
    legend(['Actual ' targetName], ['Estimated ' targetName], 'Location', 'best')
    grid on

    subplot(1,2,2)
    scatter(targetSignal(validRows), estimatedSignal(validRows), '.')
    hold on
    plot(xlim, xlim, 'k--')
    hold off
    xlabel(['Actual ' targetName])
    ylabel(['Estimated ' targetName])
    title('Observed vs Estimated')
    grid on

end