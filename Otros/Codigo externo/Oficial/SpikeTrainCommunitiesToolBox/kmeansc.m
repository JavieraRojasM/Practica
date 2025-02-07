
function [idx, mean_val] = kmeansc(X,K,iteration)

% Keisuke Matsuoka (2025). k-means clustering without toolbox 
% (https://www.mathworks.com/matlabcentral/fileexchange/60553-k-means-clustering-without-toolbox), 
% MATLAB Central File Exchange. 15/01/2025                   

% X : your data(column:samples, feature vector)
% K : number of crass
% iteration:% Maximum number of attempts


% Modification were made by Javiera Rojas 15/01/2025
    % line 27 was replace by line 28, in in which the original distance 
    % formula is replaced by the Euclidean distance formula 

% n=number of samples, d:dimension of feature vector
[n,d] = size(X);

% Decide randomly an initial value from X
P = randperm(n);

% initial value of center vector
mean_val = X(P(1,1:K)',:);

for iter = 1:iteration
    for i = 1:n
        for j = 1:K
            
            %distance(i,j) = sum(abs(X(i,:) - mean_val(j,:)));
            distance(i,j) = sqrt(sum((X(i,:) - mean_val(j,:)).^2));

        end %EOF j
        [D(i,:),idx(i,:)] = min(distance(i,:)');
    end %EOF i
    
    for j=1:K
        mean_val(K,:) =  sum(X(idx==K,:)) / sum(idx==j);
    end
    
end
end