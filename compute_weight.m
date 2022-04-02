function [weight] = compute_weight(pairs_metric,gamma,label_list)
% Calculate the weights of the initial metric for each sample
% pairs_metric: npairs x 1 cell matrix, npairs is the number of selection constraints
% parameter: a structure, holds the parameters corresponding to the function
% label_list: a npais x 1 label column vector, index for storing zeros metric
% return weight.w_ij: num_matrix x num_matrix, num_matrix:Number of non-zero matrices, Returns a Gaussian weight matrix
%        weight.constraint_indexes: Constraints that need to be integrated
npairs = size(pairs_metric,1);
oneclass = find(label_list == 1);
num_matrix = npairs - length(oneclass); % Number of non-zero matrices
w_ij = zeros(num_matrix,num_matrix);
constraint_indexes = find(label_list==0);
for i = 1:length(constraint_indexes)-1
    metric1 = pairs_metric{constraint_indexes(i),1};
    for j = i+1:length(constraint_indexes)
        metric2 = pairs_metric{constraint_indexes(j),1};
        w_ij(i,j) = exp(-gamma * norm(metric1-metric2,'fro')^2);
    end
end
w_ij = w_ij + w_ij';
weight.w_ij = w_ij;
weight.cst_ind= constraint_indexes;
end
 

