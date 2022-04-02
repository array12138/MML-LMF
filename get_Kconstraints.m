function [pairs] = get_Kconstraints(data, labels, K_neigh)
% Input: data (n x d), labels (n x 1), N is the number of training pair
% Output: S(n x n), D(n x n)

neigh_matrix = [1,1;1,2;1,3;2,1;2,2;2,3;3,1;3,2;3,3];
sim_neigh = neigh_matrix(K_neigh,1);
dim_neigh = neigh_matrix(K_neigh,2);
% 1 compute the same_label matrix
[N, ~] = size(data);
assert(length(labels) == N);
[lablist, ~, labels] = unique(labels);
K = length(lablist);
label_matrix = false(N, K);
label_matrix(sub2ind(size(label_matrix), (1:length(labels))', labels)) = true;
same_label = logical(double(label_matrix) * double(label_matrix'));
    
%2 Select target neighbors
sum_X = sum(data .^ 2, 2);
[n,~]=size(data);
DD = bsxfun(@plus, sum_X, bsxfun(@plus, sum_X', -2 * (data * data')));
disi_DD = DD;
DD(~same_label) = Inf; DD(1:N + 1:end) = Inf;
[oneSim, targets_ind] = sort(DD, 2, 'ascend');
targets_ind = targets_ind(:,1:sim_neigh);

disi_DD(same_label) = Inf; 
[oneDim, disi_ind] = sort(disi_DD, 2, 'ascend');
targets_disi = disi_ind(:,1:dim_neigh);

pairs = [];
for i = 1:N
    for j = 1:sim_neigh
        if  isinf(oneSim(i,j))
            continue;
        end
        oneVec = [i,targets_ind(i,j),1];
        pairs = [pairs;oneVec];
    end
end

for i = 1:N
    for j = 1:dim_neigh
        if  isinf(oneDim(i,j))
            continue;
        end
        oneVec = [i,targets_disi(i,j),-1];
        pairs = [pairs;oneVec];
    end
end

end