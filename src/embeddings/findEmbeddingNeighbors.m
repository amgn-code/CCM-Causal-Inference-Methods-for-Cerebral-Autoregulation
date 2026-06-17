function [neighborDistances, neighborRowIndices] = findEmbeddingNeighbors(e, tau, M, embeddingTargetIndex, libStart, libEnd)

    k = e + 1;
    
    neighborDistances = Inf(k,1);
    neighborRowIndices = NaN(k,1);
    
    embeddingTargetVector = M(embeddingTargetIndex, :);

    theilerExclusionWindow = e * tau;
    
    for i = libStart:libEnd
        if (i < embeddingTargetIndex - theilerExclusionWindow || ...
                i > embeddingTargetIndex + theilerExclusionWindow)
            
            difference = embeddingTargetVector - M(i, :);
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
