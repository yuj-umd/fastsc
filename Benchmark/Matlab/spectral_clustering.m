function spectral_clustering(input_filename, n, k, output_filename)
    S = read_unweighted_graph(input_filename);
    % 0-based index to 1-based index
    S = S + 1;
    val = ones(size(S, 1), 1);
    S = [S val];
    G = spconvert(S);
    
    % Compute I - L. 
    network_sum = sum(G, 2);
    D_inv = diag(1./(sqrt(network_sum)));
    L = D_inv*G*D_inv;
    L = (L + L') / 2;
    [V,D] = eigs(L, k, 'LM');
    labels = kmeans(V, k);
    write_clustering_result(labels, output_filename);
end