function [accuracy] = KNN_sample(train_data,train_label,test_data,test_label,sample_metric,K)
%UNTITLED7 此处显示有关此函数的摘要
%   此处显示详细说明
N = size(train_data,1);
n_test = size(test_data,1);
preds = zeros(n_test,1);
for j_point = 1:n_test
    two_point = test_data(j_point,:);
    oneVec = zeros(N,1);
    for i_point = 1:N
        one_point = train_data(i_point,:);
        temp =  (one_point - two_point)*sample_metric{i_point,1};
        oneVec(i_point) = sum(temp.^2);
    end
    [~,index] = sort(oneVec,'ascend');
    oneVec = train_label(index(1:K));
    [label_vec]= unique(oneVec);
    if length(label_vec) == 1
        preds(j_point)  = label_vec(1);
    else
        max_vec = zeros(length(label_vec),1);
        for k_vec = 1:length(label_vec)
            max_vec(k_vec) = length(find(label_vec(k_vec) == oneVec));
        end
        index1 = find(max(max_vec)==max_vec);
        preds(j_point) = label_vec(index1(1));
    end
end
index = find((test_label-preds)==0);
accuracy = length(index)/n_test;
end

