function [pairs_metric] = local_metric_origin(X,pridata,parameter)
% Initialize the metric for each constraint, without considering the fusion of metrics
% X: a nxd dataset
% pridata.L0: a global metric
% pridata.DD: a n x n distance metrix, two-by-two distance of the sample pair under the global metric L0
% pridata.DD_I: a npairs x 1 vector, the corresponding Euclidean distance for each pick pair
% pridata.pairs: nc x 3 pairs, pairs(:,1,2) is sample index, pairs(:,3) the pair label

% parameter.beta: a scaler parameter
% parameter.gamma
% return pairs_metric: 
%                    a npairs * 1 cell, where each cell is the metric corresponding to the constraint
d = size(X,2);
npairs = size(pridata.pairs,1);
% 1 Calculate the metric for each pair of constraints
pairs_metric = cell(npairs,1);
for i = 1:npairs
    delta_i = pridata.pairs(i,3)* (pridata.DD_L0(pridata.pairs(i,1),pridata.pairs(i,2))-2)-1;
    if delta_i<=0
        pairs_metric{i,1} = zeros(d,d);
    else
        Xij = pridata.DD_Xij{i,1};
        dist = pridata.DD_I(i);
        temp_matrix = Xij * pridata.L0;
        pairs_metric{i,1}  = -pridata.pairs(i,3)/ parameter.beta *(eye(d,d)-pridata.pairs(i,3)*Xij/(parameter.beta+pridata.pairs(i,3)*dist)) * temp_matrix;
    end
end
end

