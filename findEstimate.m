function estimate = findEstimate(neighborDistances, neighborTimeIndices, signal)

    u = exp(-neighborDistances/min(neighborDistances));
    
    w = u / sum(u);
    
    estimate = sum(signal(neighborTimeIndices).*w);

end