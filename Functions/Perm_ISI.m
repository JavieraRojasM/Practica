function perm_isi = Perm_ISI(isi, max_perm)
    % ...


    % Inicializar matriz para almacenar los resultados
    perm_isi = zeros(max_perm, numel(isi));

    % Generar las reorganizaciones
    for i = 1:max_perm
        % Permutar aleatoriamente el vector
        perm_isi(i, :) = isi(randperm(numel(isi)));
    end

end
