function properties = find_contiguous_patches(G,VG,C,nG)

% NB returns the IDs of each neuron in each patch, as IDed in the
% original recording. NOT the IDed sequence into the original G list...
%
% field 'patches' is in [X,Y] format: reverse indices for indexing into
% matrices i.e. (Y,X)
%
% breadth-first search: for each square, find all that are adjacent, add to
% list; repeat. When no more are adjacent, assign all to same patch. Pick
% new initial square, do again.
%
% Mark Humphries 8/1/2013

properties = struct('patches',{},'N_in_patch',[],'ixN_in_patch',{});

for iG = 1:nG
    
    % index of group entries
    ixG = find(G(:,2) == iG);
    ixN = G(ixG,1); 
    
    % remembering that: rows = Y, cols = X when we go to map view....
    [allY,allX] = ind2sub(size(VG),find(VG == iG)); % linear indices of grid squares occupied by this cluster
    
    nSquares = numel(allX);
    % Psquares = zeros(nSquares,1);
    Pctr = 1;
    checklist = [allX(1) allY(1)];
    allX(1) = []; allY(1) = [];
    properties(iG).patches = {};
    properties(iG).patches = [properties(iG).patches; checklist];
    
    while ~isempty(allX)
        while ~isempty(checklist)
            %[NC,c] = size(checklist);
            %for i = 1:NC
            for XCheck = -1:1  % check each grid square around the current one
                for YCheck = -1:1
                   if XCheck ~= 0 | YCheck ~=0
                        blnCluster = any(checklist(1,1)+XCheck == allX & checklist(1,2)+YCheck == allY);
                        blnStored = any(checklist(1,1)+XCheck == properties(iG).patches{Pctr}(:,1) & checklist(1,2)+YCheck == properties(iG).patches{Pctr}(:,2));

                        if blnCluster & ~blnStored                       
                            % if adjacent grid square is also in
                            % cluster AND not in storage then:
                            % mark for checking
                            checklist = [checklist; checklist(1,1)+XCheck checklist(1,2)+YCheck];
                            % and store 
                            properties(iG).patches{Pctr} = [properties(iG).patches{Pctr}; checklist(1,1)+XCheck checklist(1,2)+YCheck];
                            % and remove from overall list of squares
                            ix = find(checklist(1,1)+XCheck == allX & checklist(1,2)+YCheck == allY);
                            % keyboard
                            allX(ix) = [];
                            allY(ix) = [];
                        end
                   end
                end
            end
            checklist(1,:) = [];  % checked so remove!
            
        end  % end of check on list of grid location
        
        
        
        % find number of cells in this patch...
        properties(iG).N_in_patch(Pctr) = 0;
        properties(iG).ixN_in_patch{Pctr} = [];
        % check each cell in this group for membership of this patch
        for iN = 1:numel(ixG)
            if any(C(ixG(iN),2) == properties(iG).patches{Pctr}(:,1) & C(ixG(iN),1) == properties(iG).patches{Pctr}(:,2))
                properties(iG).N_in_patch(Pctr) = properties(iG).N_in_patch(Pctr) + 1; % how many?
                properties(iG).ixN_in_patch{Pctr} = [properties(iG).ixN_in_patch{Pctr}; ixN(iN)];  % which neurons?
            end
        end

        % increment patch counter
        Pctr = Pctr + 1;
        
        % re-start checklist...
        if ~isempty(allX)
            checklist = [allX(1) allY(1)];
            allX(1) = []; allY(1) = [];
            properties(iG).patches = [properties(iG).patches; checklist];
        end

    end
    % keyboard
end
