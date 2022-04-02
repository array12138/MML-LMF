clc;clear;
%1 Read dataset
filename = 'dataset.mat'; % nxd matrix,n: sample num, d: dim num
load(filename); %dataset name: data, label:true label
%% Indexing of data
index_data =2;
% %%
filename = dataset{index_data,3};
disp(filename);
data = dataset{index_data,1};
label = dataset{index_data,2};
% data = X;
% label = Y;
[n_sam] = length(label);
% 2 Product n_trials trials
n_trials = 1;
i_trials = 1;
mu_value = [1:9];
parameter.mu = 1;
beta_value = 10.^(-3:0);
parameter.gamma = 1;
parameter.fuse_ratio = 1.1;
% parameter.neigh = 5;
parameter.dim = size(data,2);
alltrials_result = zeros(n_trials,3);
while i_trials <= n_trials
    disp(['i_trials = ',num2str(i_trials)]);
    ntrain = floor(n_sam*0.7);
    train_index = randperm(n_sam,ntrain);
    test_index = (1:n_sam)';
    test_index(train_index(:)) = [];
    % 3 Extraction of data
    train_data = data(train_index(:),:);
    [train_data,mu,sigma] = zscore(train_data);
    % Prevent data from appearing exactly the same
    index = find(sigma==0);
    mu(index(:)) = 1;
    sigma(index(:)) = 1;
    train_label = label(train_index(:));
    test_data = data(test_index(:),:);
    for i = 1:size(test_data,1)
        test_data(i,:) = (test_data(i,:) - mu)./sigma;
    end
    test_label = label(test_index(:));
    para_metrix = zeros(length(mu_value)*length(beta_value),3);
    parm_iter = 1;
    %4.1 Perform parameter mu selection
    for mu_index = 1:length(mu_value) 
        parameter.neigh = mu_value(mu_index);
        disp([' parameter.neigh = ',num2str( parameter.neigh)]);
        %5.1 Perform the selection of the parameter beta value
        for beta_index = 1:length(beta_value) 
            parameter.beta = beta_value(beta_index); 
            disp(['parameter.beta = ',num2str(parameter.beta)]);
            para_metrix(parm_iter,2) =  mu_value(mu_index);
            para_metrix(parm_iter,3) = beta_value(beta_index);   
            tic;
            [acc_best,~] = main(train_data,train_label,test_data,test_label,parameter);
            toc;
            para_metrix(parm_iter,1)  = acc_best;
            parm_iter = parm_iter + 1;
        end%beta
     end%mu
     best_index = find(para_metrix(:,1) == max(para_metrix(:,1)));
     alltrials_result(i_trials,1) = para_metrix(best_index(1),1);
     alltrials_result(i_trials,2) = para_metrix(best_index(1),2);
     alltrials_result(i_trials,3) = para_metrix(best_index(1),3);
     i_trials = i_trials  + 1;
end
save([filename,'_all_new','.mat'],'alltrials_result');
result = [mean(alltrials_result(:,1)),std(alltrials_result(:,1))];
save([filename,'_index_new','.mat'],'result');



