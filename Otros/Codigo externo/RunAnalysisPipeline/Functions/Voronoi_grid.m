function [V,C] = Voronoi_grid(P,G,dG,varargin)

% VORONOIGRID Voronoi diagram on discrete grid using Euclidean distamce
% [V,C] = VORONOIGRID(P,G,dG) takes m seed points in a m x n matrix P; an
% n-dimensional matrix G whose size specifies the grid for the space to be tesslated
% (entries 1 indicate a permissible grid location; entries 0 indicate a
% non-permissible location); and a scaling factor (dG) for the size of 1
% grid step in the metric space of P.
%
% Returns the Voronoi diagram on n-dimensional matrix V: each permissible
% grid location contains the index of the point in P. Non-permissible
% locations contain 0. Also returns the grid co-ordinates C of each point
% P.
% 
% ... = VORONOIGRID(...,'s') creates a sparse grid in which not all
% squares need be claimed, to account for sparse population of seed points. 
% The current algorithm sets to -1 any grid location further from the nearest
% seed point than that seed point is to any of its neighbours. 
%
% Notes
% (1) dG is the grid-step e.g. if the point co-ordinates are given in 
%   metres, then dG is the length of one grid-step in metres
% (2) Computes grid assignment as seed-point with shortest Euclidean distance 
%  between itself and the centre of that grid voxel. 
% 
%
% Mark Humphries 20/12/2012

dP = size(P);
d = size(G);
nD = ndims(G);
if dP(2) ~= nD
    error('Seed point and grid dimensions do not match')
end

V = zeros(d);
C = zeros(dP(1),nD);

dist_centre_corner = sqrt(sum(ones(nD,1).*(dG/2)^2)) + 0.0001; 
% NB: add tiny amount to get around weird MATLAB rounding error: if point
% happens to be exactly on grid intersection then its distance is given as
% being infintesimally greater than this distance to centre calculation??

if nargin >= 4 & varargin{1} == 's'
    % compute minimum distance between each seed point and its neighbours
    for iP = 1:dP(1)
        dists = sqrt(sum((repmat(P(iP,:),dP(1),1) - P).^2,2));
        minD(iP) = min(dists(dists > 0));
    end
else
    minD = ones(dP(1),1) + inf; % minimum distance is infinity
end

    
% for each grid square
for i = 1:prod(d)
    if G(i) ~= 0
        grid_corner = cell(1,nD);
        % keyboard
        [grid_corner{:}] = ind2sub(d,i); % .* dG -dG/2; % get centre of N-D grid voxel on scale of data-points 
        grid_centre = [grid_corner{:}] .*dG - dG/2;
        
        % keyboard
        dists = sqrt(sum((P - repmat(grid_centre,dP(1),1)).^2,2)); % sum along rows....
        mindist = min(dists);  
        
        nrstpnt = find(dists == mindist);  % index of nearest seed point
        if numel(nrstpnt) > 1
            keyboard
        end
        
        % check that grid location is not outside eligibility range
        if minD(nrstpnt) < mindist  % so grid location is further from 
                                     % nearest seed point than that seed point is from its closest neighbour 
            V(i) = -1;
        else
            V(i) = nrstpnt;
        end
        if mindist <= dist_centre_corner
            % then point is actually in this grid location
            C(nrstpnt,:) = [grid_corner{:}];  % location of this point on this grid 
        end
    end
end