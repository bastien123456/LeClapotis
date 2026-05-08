function [Nbpt, Nbtri, Coorneu, Refneu, Numtri, Reftri, Numtre, Nbtre] = LC_read_mesh(nomfile, idx_Free, idx_lat)
% updated lecture_mesh function to work with latest version of gmsh
% Lucian Constantin, lucian.constantin@mta.ro, 07.05.2026

    TYPE_TRI = 2;
    TYPE_TET = 4;

    % read file
    lines = readlines(nomfile);
    lines = cellstr(lines);

    node_start = find(strcmp(strtrim(lines), '$Nodes'),       1);
    node_end   = find(strcmp(strtrim(lines), '$EndNodes'),    1);
    elem_start = find(strcmp(strtrim(lines), '$Elements'),    1);
    elem_end   = find(strcmp(strtrim(lines), '$EndElements'), 1);
    ent_start  = find(strcmp(strtrim(lines), '$Entities'),    1);
    
    if any([isempty(node_start), isempty(node_end), isempty(elem_start), isempty(elem_end)])
        error('read_mesh: could not find $Nodes or $Elements in %s', nomfile);
    end
    if isempty(ent_start)
        error('read_mesh: could not find $Entities in %s — physical groups may not be defined', nomfile);
    end

    %parse $Entities to map geometric surface tag to physical tag
    counts   = str2double(strsplit(strtrim(lines{ent_start + 1})));
    n_points = counts(1);
    n_curves = counts(2);
    n_surfs  = counts(3);
    
    i = ent_start + 2;
    for k = 1:n_points + n_curves
        i = i + 1;
    end

    geom_to_phys = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

    for k = 1:n_surfs
        parts        = str2double(strsplit(strtrim(lines{i})));
        geom_tag     = parts(1);
        num_phys     = parts(8);
        if num_phys > 0
            phys_tag = parts(9);   % take the first physical tag
            geom_to_phys(int32(geom_tag)) = int32(phys_tag);
        end
        i = i + 1;
    end

    fprintf('Geometric surfaces with physical tags:\n');
    ks = keys(geom_to_phys);
    for k = 1:numel(ks)
        fprintf('  geom tag %d → physical tag %d\n', ks{k}, geom_to_phys(ks{k}));
    end

    %parse $Nodes
    summary     = str2double(strsplit(strtrim(lines{node_start + 1})));
    total_nodes = summary(2);

    raw_tags   = zeros(total_nodes, 1);
    raw_coords = zeros(total_nodes, 3);

    block_info = struct('ref', {}, 'tags', {});
    b   = 0;
    ptr = 1;
    i   = node_start + 2;

    while i <= node_end - 1
        header    = str2double(strsplit(strtrim(lines{i})));
        dim       = header(1);
        geom_tag  = header(2);
        num_nodes = header(4);
        i = i + 1;

        tags = zeros(num_nodes, 1);
        for k = 1:num_nodes
            tags(k) = str2double(strtrim(lines{i}));
            i = i + 1;
        end

        coords = zeros(num_nodes, 3);
        for k = 1:num_nodes
            coords(k, :) = str2double(strsplit(strtrim(lines{i})));
            i = i + 1;
        end

        raw_tags(ptr : ptr + num_nodes - 1)      = tags;
        raw_coords(ptr : ptr + num_nodes - 1, :) = coords;
        ptr = ptr + num_nodes;

        b = b + 1;
        block_info(b).ref  = 0;
        block_info(b).tags = tags;
        if dim == 2 && isKey(geom_to_phys, int32(geom_tag))
            phys = double(geom_to_phys(int32(geom_tag)));
            if phys == idx_Free
                block_info(b).ref = idx_Free;
            elseif phys == idx_lat
                block_info(b).ref = idx_lat;
            end
        end
    end

    % sort by global tag for consistent 1:Nbpt indexing
    [sorted_tags, sort_idx] = sort(raw_tags);
    Coorneu = raw_coords(sort_idx, :);
    Nbpt    = size(Coorneu, 1);

    max_tag   = max(sorted_tags);
    tag2local = zeros(max_tag, 1, 'uint32');
    for k = 1:Nbpt
        tag2local(sorted_tags(k)) = k;
    end

    % build Refneu
    node_refs = zeros(max_tag, 1);
    for b = 1:numel(block_info)
        if block_info(b).ref ~= 0
            node_refs(block_info(b).tags) = block_info(b).ref;
        end
    end

    Refneu = zeros(Nbpt, 1);
    for k = 1:Nbpt
        Refneu(k) = node_refs(sorted_tags(k));
    end

    % parse $Elements
    summary2    = str2double(strsplit(strtrim(lines{elem_start + 1})));
    total_elems = summary2(2);

    tri_nodes = zeros(total_elems, 3, 'uint32');
    tri_ref   = zeros(total_elems, 1);
    tet_nodes = zeros(total_elems, 4, 'uint32');
    n_tri = 0;
    n_tet = 0;

    i = elem_start + 2;
    while i <= elem_end - 1
        header    = str2double(strsplit(strtrim(lines{i})));
        dim       = header(1);
        geom_tag  = header(2);
        etype     = header(3);
        num_elems = header(4);
        i = i + 1;

        block_ref = 0;
        if dim == 2 && isKey(geom_to_phys, int32(geom_tag))
            phys = double(geom_to_phys(int32(geom_tag)));
            if phys == idx_Free
                block_ref = idx_Free;
            elseif phys == idx_lat
                block_ref = idx_lat;
            end
        end

        for k = 1:num_elems
            parts     = str2double(strsplit(strtrim(lines{i})));
            local_idx = tag2local(parts(2:end));

            if etype == TYPE_TRI
                n_tri = n_tri + 1;
                tri_nodes(n_tri, :) = local_idx;
                tri_ref(n_tri)      = block_ref;
            elseif etype == TYPE_TET
                n_tet = n_tet + 1;
                tet_nodes(n_tet, :) = local_idx;
            end

            i = i + 1;
        end
    end

    Numtri = tri_nodes(1:n_tri, :);
    Reftri = tri_ref(1:n_tri);
    Nbtri  = n_tri;
    Numtre = tet_nodes(1:n_tet, :);
    Nbtre  = n_tet;

    %display summary
    fprintf('--- read_mesh: %s ---\n', nomfile);
    fprintf('  Nodes      : %d\n', Nbpt);
    fprintf('  Triangles  : %d  (free: %d, lateral: %d)\n', ...
        Nbtri, sum(Reftri == idx_Free), sum(Reftri == idx_lat));
    fprintf('  Tetrahedra : %d\n', Nbtre);
    fprintf('  Free surface nodes   : %d\n', sum(Refneu == idx_Free));
    fprintf('  Lateral surface nodes: %d\n', sum(Refneu == idx_lat));
end
