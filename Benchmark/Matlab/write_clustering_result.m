function write_clustering_result(labels, output_filename) 
fileID = fopen(output_filename, 'w');
fprintf(fileID, 'Node ID  Label\n');
for i = 1:size(labels, 1)
    fprintf(fileID, '%d  %d \n', i, labels(i));
end
fclose(fileID);
    


end

