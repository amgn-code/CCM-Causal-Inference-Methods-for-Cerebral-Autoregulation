function M = findEmbedding(signal, firstEmbeddingIndex, tau, e)
    
    M = NaN(length(signal), e);

    for i = firstEmbeddingIndex:size(M,1)
    
        for j = 1:1:size(M,2)
    
            M(i, j) = signal(i - (j-1)*tau);
          
        end
    
    end
end