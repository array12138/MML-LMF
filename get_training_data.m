function [pairs] = get_training_data(data, label, npairs)
% Input: data (n x d), label (n x 1), npairs is the number of selected training pair
% Output: pairs (npairs x 3), pairs(:,1,2) is the serial number of the
% sample, pairs(:,3) is the label of the constraint, like is 1 and unlike is -1
    [n] = size(data,1);
    indexs = randperm(n^2, npairs);
    pairs = zeros(npairs,3);
    for i=1: length(indexs)
        u = indexs(i)/n;
        v = mod(indexs(i), n);
        p = floor(u) + (v~=0);
        q = v + 1;
        if label(p) == label(q)
            if p<q
                pairs(i,1) = p;
                pairs(i,2) = q;
                pairs(i,3) = 1;
            else
                pairs(i,1) = q;
                pairs(i,2) = p;
                pairs(i,3) = 1;
            end
        else
            if p<q
                pairs(i,1) = p;
                pairs(i,2) = q;
                pairs(i,3) = -1;
            else
                pairs(i,1) = q;
                pairs(i,2) = p;
                pairs(i,3) =-1;
            end
        end
    end
end