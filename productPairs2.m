function [pairs] = productPairs2(X,labels,K_neighbor)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

[N, D] = size(X);
assert(length(labels) == N);
[lablist, ~, labels] = unique(labels);
K = length(lablist);
label_matrix = false(N, K);
label_matrix(sub2ind(size(label_matrix), (1:length(labels))', labels)) = true;
same_label = logical(double(label_matrix) * double(label_matrix'));

sum_X = sum(X .^ 2, 2);
DD = bsxfun(@plus, sum_X, bsxfun(@plus, sum_X', -2 * (X * X')));
DD(1:N + 1:end) = Inf;
[~, targets_ind] = sort(DD, 2, 'ascend');
targets_same = targets_ind(:,1:K_neighbor);

sam1 = repmat(1:N,K_neighbor,1);
sam2 = targets_same';
sam3 = zeros(K_neighbor,N);

for i = 1:K_neighbor
    for j = 1:N
        if labels(sam1(i,j)) ==labels(sam2(i,j))
            sam3(i,j) = 1;
        else
            sam3(i,j) = -1;
        end
    end
end
pairs = [sam1(:),sam2(:),sam3(:)];
end

