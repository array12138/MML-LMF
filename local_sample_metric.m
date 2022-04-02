function [pointL] = local_sample_metric(X,L0,i_point,pairs,pairs_metric)
% 求所有L的均值
i_pairs = find(pairs(:,1) == i_point);
pointL = 0;
if isempty(i_pairs)
    pointL = L0;
else
    lss_vec = zeros(length(i_pairs),1);
    for i = 1:length(i_pairs)
        [Li] = pairs_metric{pairs(i_pairs(i),1)};
        try
            loss_temp = compute(X,L0,Li,pairs(i_pairs(:),:));
        catch
            loss_temp = compute(X,L0,Li,pairs(i_pairs(:),:));
        end
        lss_vec(i) = loss_temp;
        pointL = pointL + Li;
    end
    index1 = find(min(lss_vec) == lss_vec);
    try
        pointL = L0 + pairs_metric{pairs(i_pairs(index1(1)),1)};
    catch
        pointL = L0;
%         disp(['bbb']);
    end
end
end
function loss = compute(X,L0,Li,pairs)
loss = 0;
for i = 1:size(pairs,1)
    temp = (X(pairs(i,1),:)-X(pairs(i,2),:)) * (L0 + Li);
    loss = loss + pairs(i,3)* norm(temp,2);
end
end

