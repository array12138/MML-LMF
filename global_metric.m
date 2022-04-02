function [L,DD_final,DD_I] = global_metric(X,pairs,mu)
% Learn a global metric by picking the set of pair constraints pairs
% X: n x d
% pairs: selected pairs number--nc, nc x 3 
% mu : parameter, mu*\|L\|_F^2
% return L: d x d, a global metric
% DD_final: n x n ,Distance metric at the current L
%     DD_I: npais x 1, Euclidean distance of the current constraint pair

% 1 Set learning parameters
min_iter = 50;          % minimum number of iterations
max_iter = 1000;        % maximum number of iterations
eta = 1e-4;             % learning rate
tol = 1e-5;             % tolerance for convergence
gamma = 2;              % gamma value
best_C = Inf;           % best error obtained so far
[N,D] = size(X);
L0 = eye(D);    
C = Inf; prev_C = Inf;
npairs = size(pairs,1); % number of pairs
sum_X = sum(X .^ 2, 2);
DD = bsxfun(@plus, sum_X, bsxfun(@plus, sum_X', -2 * (X * X'))); % Calculate the Euclidean distance between samples
DD_I = zeros(npairs,1);
for i = 1:npairs
    DD_I(i) = DD(pairs(i,1),pairs(i,2));
end
% 2 Perform main learning iterations
iter = 0;
while (prev_C - C > tol || iter < min_iter) && iter < max_iter
     % Compute value of cost function
    prev_C = C;
    G = 0;
    L = L0; % L == prev_L, L0 = current_L
    C = 0;
    count = 1;
    for i = 1: npairs
        delta_i = pairs(i,3)* (gamma - DD(pairs(i,1),pairs(i,2))); % qt(gamma - dist)
        temp_matrix = (X(pairs(i,1),:)-X(pairs(i,2),:))' * (X(pairs(i,1),:)-X(pairs(i,2),:)) * L0;
        if delta_i>1
            count = count + 1;
            continue;
        else
            if delta_i<0
                C =  C + (0.5 - delta_i); % objective value
                G = G + 2* pairs(i,3) * temp_matrix;
            else
                C = C + 0.5 *(delta_i - 1)^2; % objective value
                G = G - 2* pairs(i,3) * (delta_i - 1) * temp_matrix;
            end
        end
    end
%     disp(['Number of constraints satisfied: ',num2str(count)]);
    G = G + 2*mu * L0;
    if C < best_C
        best_C = C;
        best_L = L0;
        DD_final = DD;
    end
    % Perform gradient update
    L0 = L0 - (eta ./ N) .* G;
    XL0 = X * L0;
    sum_X = sum(XL0 .^ 2, 2);
    DD = bsxfun(@plus, sum_X, bsxfun(@plus, sum_X', -2 * (XL0 * XL0')));

    % Update learning rate
    if C < prev_C
        eta = eta * 1.05;
    else
        L0 = L;
        eta = eta * .5;
    end
    % Print out progress
    iter = iter + 1;
%     if rem(iter, 10) == 0
%        disp(['Iteration ' num2str(iter) ': error is ' num2str(C/N)]);
%     end
end
L = best_L;
end
