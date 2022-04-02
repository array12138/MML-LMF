function [pairs] = get_all_pairs(label)
% Input: label (n x 1)
% Output: pairs (n x(n-1)/2 x 3)
n = length(label);
pairs = zeros(n*(n-1)/2,3);
count = 1;
for i = 1:n-1
    for j = i+1:n
        pairs(count,1) = i;
        pairs(count,2) = j;
        if label(i) == label(j)
            pairs(count,3) = 1;
        else
            pairs(count,3) = -1;
        end
        count = count + 1;
    end
end
end

