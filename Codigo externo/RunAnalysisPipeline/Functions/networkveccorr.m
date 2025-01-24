function [networkvector,Rp,P,R,vecbins] = networkveccorr(spkdata,T,stateDt,varargin)

% NETWORKVECCORR construct and correlate network state vectors
% [N,Rp,P,R,M] = NETWORKVECCORR(S,T,Dt) for the spike-data in two-column array S,  
% recorded over time T = [start end], constructs the vectors of network activity 
% for each bin of width Dt between T(1) and T(2). Each vector gives the spike activity of each neuron
% in that bin. The vectors are then correlated to construct the network's activity-vector correlation matrix.
% 
% Returns: N, the matrix of network vectors (#neurons,#bins); Rp, the matrix of significant
% network correlations (all non-significant entries set to 0); 
% P, the matrix of significance levels of each correlation; R, the raw correlation matrix.
% M: vector of times for vector edges 
%
% STATEVECCORR(...,ALPHA,FLAG) are optional arguments. ALPHA sets the significance level for
% the correlations (default is p = 0.05), set to [] to omit; FLAG = 'B'
% will compute correlations between network vectors represented as binary
% vectors (having entry 1 if neuron is active and 0 otherwise).
%
% Notes:
% (1) Spike-data supplied as S = [ID,Ts], each row specifying a spike at
% time Ts from neuron ID
% (2) All times should be in seconds
% (3) Correlation is computed as the correlation coefficient (see CORRCOEF)
% (4) Is only useful to use FLAG = 'B' for small bin sizes (small on
% scale of neuron firing rate)
%
% Mark Humphries 4/11/2013

if nargin >= 4 & ~isempty(varargin{1})
    alpha = varargin{1};
else
    alpha = 0.05;
end

if nargin >= 5 & findstr(varargin{2},'B')
    bln = 1;
else 
    bln = 0;
end

allcellIDs = unique(spkdata(:,1));
nallIDs = numel(allcellIDs);
vecbins = T(1):stateDt:T(2);
networkvector = zeros(nallIDs,numel(vecbins)-1);


for i = 1:nallIDs
    currix = find(spkdata(:,1) == allcellIDs(i));
    ts = spkdata(currix,2); 
    if ts
        hst = histc(ts,vecbins);
        networkvector(i,:) = hst(1:end-1)'; % ignore last bin: histc's last bin = "exact match"
        if bln
            networkvector(i,:) = double(networkvector(i,:) > 0);
        end
    end
end

sc = sum(networkvector);
[R,P] = corrcoef(networkvector(:,sc > 0));
Rp = R; Rp(P > alpha) = 0;    