function [neighborDistances, neighborRowIndices] = findEmbeddingNeighbors(e, tau, m, timestamp, firstIndex)

    k = e + 1;
    rowIndex = timeToIndex(timestamp, firstIndex, true);
    
    neighborDistances = Inf(k,1);
    neighborRowIndices = NaN(k,1);
    
    queryRow = m(rowIndex, :);

    theilerExclusionWindow = e * tau;
    
    for i = 1:1:size(m,1)
        if abs(i-rowIndex) > theilerExclusionWindow
            difference = queryRow - m(i, :);
            distance = sqrt(sum(difference.^2));
            [maxDistance, maxIndex] = max(neighborDistances);
            if distance < maxDistance
                if distance == 0
                    neighborDistances(maxIndex) = eps;
                else
                    neighborDistances(maxIndex) = distance;
                end
                
                neighborRowIndices(maxIndex) = i;
    
            end
        end
    end

end
