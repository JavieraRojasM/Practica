function [D] = pdist_oneLine(varargin)
% This is my one-line implementation that is equivalent to BOTH pdist and
% pdist2 which compute the Euclidean distance between all pairs of input
% observations. This implementation is completely vectorized, so it is much
% faster than any loop-based method, though it's not quite as fast as
% MATLAB's built-in pdist/pdist2 functions as those are executed from
% precompiled MEX files. Though computationally lite, the vectorization of
% this implementation makes it memory-intensive, so you run the risk of
% running out of RAM if the number of observations is sufficiently large.
% The built-in functions have protections against that but this
% implementation does not, so be warned!
% 
%
% pdist USE:
%
% D = pdist_oneLine(X)
%
% For pdist use, simply input the set of observations X as a single n by k
% matrix, where n is the number of observations and k is the dimensionality
% of the observations' features (E.G. x-coordinates in the 1st column,
% y-coordinates in the 2nd column, etc). The output D will be an n by n
% matrix of the distances between each pair of observations from the input
% matrix X. Each measurement is repeated twice, making D symetric about its
% diagnonal. The diagonal represents distances between an observation and
% itself, so the diagonal is all zeros. For example, the distance between
% observations 5 and 7 (defined by rows 5 and 7 from the input matrix X,
% X(5,:) and X(7,:)) can be found at D(5,7) and D(7,5).
% 
%
% pdist2 USE:
%
% D = pdist_oneLine(X,Y)
%
% For pdist2 use, simply input both sets of observations as separate
% matrices, X and Y, in the same format as the pdist use-case. The output D
% will be and n by m matrix of the distances between each pair of X and Y
% observations, where n and m are the number of X and Y observations,
% respectively. Each measurement in D is unqiue because X and Y contain
% unique observations. For example, the distance between observation 5 from
% X, X(5,:), and observation 7 from Y, Y(7,:), can be found at D(5,7).
%
%
% Author: Andrew M. Soltisz
% Email: andysoltisz@gmail.com
% GitHub: https://github.com/andrewsoltisz/pdist-one-line/tree/main
% MathWorks: https://www.mathworks.com/matlabcentral/fileexchange/136559-pdist_oneline
% Last Updated: 10/12/2023
%
% Copyright 2023, Andrew Michael Soltisz. All rights reserved.
% This source code is licensed under the BSD-3-Clause License found in the
% LICENSE.txt file in the root directory of this source tree.

    D = squeeze(sqrt(sum(reshape(repmat(varargin{1},[1,size(varargin{end},1)])-reshape(varargin{end}',[1,numel(varargin{end})]),[size(varargin{1},1),size(varargin{1},2),size(varargin{end},1)]).^2,2)));

end