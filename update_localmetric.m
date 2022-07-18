function [newpairs_metric] = update_localmetric(X,npairs_metric,pridata,weight,nlabel_list,parameter)
% Update the current metric metrix  based on the partition "label_list"
% X:              a n x d metric
% npairs_metric:  a num x 1 cell metric, num is the number of non-zero metrics
% pridata: a stucture, pridata.pairs:  a npairs x 3 matrix, constraint matrix for selection
%                      pridata.DD_Xij: a npairs x 1 cell metric, which holds the xij matrix of each pair
%                                      (xi - xj) * (xi - xj)', to reduce the amount of calculations
% weight.w_ij:    a num x num metric, num is the number of non-zero metrics
% weight.cst_ind: a num x 1 column vector, index of the metric to be fused in the constraint
% label_list:     a npairs x 1 column vector
% nlabel_list:    a num x 1 column label vector
% parameter:      a structure, holds the parameters corresponding to the function
% return: 
%                 newpairs_metric: Updated constraint metric matrix
all_parition = unique(nlabel_list);
nparition = length(all_parition);
d = size(X,2);
for i = 1:nparition
    one_parition = find(nlabel_list == all_parition(i));
 
    w_Cj = sum(weight.w_ij(one_parition(:),:),1);
   
    temp_matrix = zeros(d,d);
    for j = 1:length(nlabel_list) % w{C,j}*Lj in other C
        temp_matrix = temp_matrix + w_Cj(j) * npairs_metric{j};
    end
    temp_matrix2 = zeros(d,d);
    for j = 1:length(one_parition)% qt* Xij* L0 in C
        temp_matrix2 = temp_matrix2 + pridata.pairs(weight.cst_ind(one_parition(j)),3) * pridata.DD_Xij{weight.cst_ind(one_parition(j)),1}* pridata.L0;
    end
    part2 = parameter.mu * temp_matrix-temp_matrix2;
    
    alpha_value = parameter.beta *length(one_parition) + parameter.mu * sum(w_Cj(:));
    all_invmetric = cell(length(one_parition)+1,1); %Store intermediate variables for each inverse avoidance
    for j = 1:length(one_parition)+1
        if j == 1
            all_invmetric{j} = 1/alpha_value * eye(d,d);
        else
            % q_t*K_{t-1}*u_t*u_t^T*K_{t-1}
            fenzi = pridata.pairs(weight.cst_ind(one_parition(j-1)),3) * all_invmetric{j-1}*pridata.DD_Xij{weight.cst_ind(one_parition(j-1)),1} * all_invmetric{j-1};
            ut = X(pridata.pairs(weight.cst_ind(one_parition(j-1)),1),:)- X(pridata.pairs(weight.cst_ind(one_parition(j-1)),2),:);
            fenmu = 1+ pridata.pairs(weight.cst_ind(one_parition(j-1)),3) * ut * all_invmetric{j-1}* ut';
            all_invmetric{j} = all_invmetric{j-1}- fenzi/fenmu;
        end
    end
    new_metric = all_invmetric{length(one_parition) + 1} * part2;
    for j = 1:length(one_parition)
        npairs_metric{one_parition(j),1} = new_metric;
    end
end
newpairs_metric = npairs_metric;
end

