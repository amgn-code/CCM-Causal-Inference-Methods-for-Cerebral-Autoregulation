function estimate = findEstimate(neighborDistances, neighborIndex, signal)

    u = exp(-neighborDistances/min(neighborDistances));
    
    w = u / sum(u);
    
    estimate = sum(signal(neighborIndex).*w);

end