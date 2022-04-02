function [acc_best,class_best] = main(train_data,train_label,test_data,test_label,parameter)
%UNTITLED11 此处显示有关此函数的摘要
%   此处显示详细说明
% [pairs] = productPairs2(train_data,train_label,parameter.neigh);
[pairs] = get_Kconstraints(train_data, train_label, parameter.neigh);
% KK = length(unique(train_label));
% npairs = 1000*KK*(KK-1);
% pairs = get_training_data(train_data, train_label, npairs);

DD_Xij = cell(size(pairs,1),1);
% 3.1 Since the calculation of (xi-xj)*(xi-xj)' occurs repeatedly in the code, a cell matrix is used to store all its calculations
for i = 1:size(pairs,1)
    temp = (train_data(pairs(i,1),:) - train_data(pairs(i,2),:));
    DD_Xij{i,1} = temp' * temp;
end
%4 Learning a global metric metrix
[L0,DD_L0,DD_I] = global_metric(train_data,pairs,parameter.mu);
%5 Initialize the metric for each constraint
pridata.DD_Xij = DD_Xij;
pridata.DD_I = DD_I;
pridata.DD_L0 = DD_L0;
pridata.L0 = L0;
pridata.pairs = pairs;

[pairs_metric] = local_metric_origin(train_data,pridata,parameter);
%6 Initialize the label of the constraint corresponding to the metric
label_list = zeros(size(pairs_metric,1),1);  % index for storing zeros metric
count = 0;
for i = 1:size(pairs_metric,1)
    temp_metric = pairs_metric{i,1};
    if sum(temp_metric(:)) == 0
        label_list(i) = 1;
    else
        count = count + 1;
    end
end
nlabel_list = [1:count]'; % Non-zeros label list


% 7 Pick the metric that is not zero
npairs_metric = cell(count,1);
count = 1;
for i = 1:size(pairs,1)
    temp_metric = pairs_metric{i,1};
    if sum(temp_metric(:)) == 0
        continue;
    else
        npairs_metric{count,1} =  pairs_metric{i,1};
        count = count + 1;
    end
end
%8 Initialize the weights for constrained fusion
[weight] = compute_weight(pairs_metric,parameter.gamma,label_list);
%9 Fusion of constraints for each metric
accuracy_vec = [];

while true
    % 9.1 Update the metric corresponding to each constraint
%     tic;
    [npairs_metric] = update_localmetric(train_data,npairs_metric,pridata,weight,nlabel_list,parameter);
%     toc;
    % 9.2 Fusion of similar metrics
    if isempty(npairs_metric)
        for i = 1:size(npairs_metric,1)
            npairs_metric{i,1} = L0;
        end
    else
%         tic;
        [npairs_metric,nlabel_list] = fusion_metric(npairs_metric,nlabel_list,parameter); 
%         toc;
    end
    % 9.3 Determine the current metric
    metric_num = length(unique(nlabel_list));
    disp(['number of metric = ',num2str(metric_num)]);

    %10 Apply to the test set for the learned metric
    for i = 1:length(weight.cst_ind)
        pairs_metric(weight.cst_ind(i)) = npairs_metric(i);
    end
    sample_metric = cell(size(train_data,1),1);
    for i = 1:size(train_data,1)
        sample_metric{i,1} = local_sample_metric(train_data,L0,i,pairs,pairs_metric);
    end
%     tic;
    [accuracy] = KNN_sample(train_data,train_label,test_data,test_label,sample_metric,3);
    disp(['accuracy = ',num2str(accuracy)]);
%     toc;
    accuracy_vec = [accuracy_vec;[accuracy,metric_num]];
    if metric_num<=2
        break;
    end
end
max_accuracyindex = find(max(accuracy_vec(:,1)) == accuracy_vec(:,1));
min_classIndex = find(min(accuracy_vec(max_accuracyindex(:),2)) == accuracy_vec(max_accuracyindex(:),2));
acc_best = accuracy_vec(max_accuracyindex(1),1);
class_best = accuracy_vec(min_classIndex(1),2);
end

