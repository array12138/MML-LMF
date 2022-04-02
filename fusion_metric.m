function [newpairs_metric,newlabel_list] = fusion_metric(npairs_metric,nlabel_list,parameter)
% Fusion of non-zero metrics with similar constraints
% npairs_metric:  a npairs x 1 cell metric
% label_list:    a npairs x 1 column vector, Initialized label vector, where class 1 is the constraint metric parition of all zeros
% parameter:     a structure, holds the parameters corresponding to the function
% return:        newpairs_metric: a npairs x 1 cell metric,fused the metric
%                newlabel_list: a npairs x1 column vector
partition = unique(nlabel_list);
nparition = length(partition);
dist_matrix =zeros(nparition,nparition);
dist_matrix(:) = inf;
% 1 Calculate the distance between any two parition metric
matrix_partition_index = zeros(nparition,1);
class = cell(nparition,1);
for i = 1:nparition
    class{i} = find(nlabel_list == partition(i));
end
for i = 1:nparition-1
    matrix_partition_index(i) = partition(i);
    oneclass = class{i};
    metric1 = npairs_metric{oneclass(1),1};
    for j = i+1:nparition
         twoclass = class{j}; % Cj class
         metric2 = npairs_metric{twoclass(1),1};
         dist_matrix(i,j)= norm(metric1-metric2,'fro');
    end
end

matrix_partition_index(end) = partition(end); % 
minvalue = min(dist_matrix(:));
[row,col] = find(dist_matrix<=minvalue * parameter.fuse_ratio); %The index of the class is returned
% 3 Recode the index of the class to find fused nodes with breadth-first search
all_value = unique([row,col]);
newrow = zeros(length(row),1);
newcol = zeros(length(row),1);
for i = 1:length(row)
     index = find(all_value == row(i));
     newrow(i) = index;
     index = find(all_value == col(i));
     newcol(i) = index;
end
Graph_matrix = graph(newrow,newcol); % Calculating the nearest neighbor graph
index_all = zeros(length(all_value),1); % Records whether the node has been accessed
temp_label = nlabel_list;
% 4 Perform a BFS search on each node
for i = 1:length(all_value)
    node  = bfsearch(Graph_matrix,i); % Breadth-first search for node i
    temp_mu = zeros(1,parameter.dim);
    count = 0;
    temp_metric = zeros(parameter.dim,parameter.dim);
    if sum(index_all(node(:))) ==0 % If the node has not been used
         for j = 1:length(node) % The connectivity component targeted to this i_node or for all clusters to be fused
             oneclass = find(nlabel_list == nlabel_list(matrix_partition_index(all_value(node(j))))); % Cj fused class
             count  = count + length(oneclass);
             if isempty(oneclass)
                disp('hahahah');
             end 
             temp_metric = temp_metric +  length(oneclass)* npairs_metric{oneclass(1),1};
         end
        all_sam = [];
        for j = 1:length(node)  % The connectivity component targeted to this i_node
            oneclass = find(nlabel_list == nlabel_list(matrix_partition_index(all_value(node(j))))); % Cj fused class
            all_sam = [all_sam;oneclass];
            for k = 1:length(oneclass)
                npairs_metric{oneclass(k),1} = temp_metric/count;
            end
        end
        temp_label(all_sam(:)) = min(nlabel_list(all_sam(:)));
    end
    index_all(node(:)) = 1;
end
newpairs_metric = npairs_metric;
newlabel_list = temp_label;
end