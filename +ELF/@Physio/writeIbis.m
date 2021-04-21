function writeIbis(ibis,savepath)
%writeIbis: Writes IBI series to savepath
%   Expects simple array of ibis in seconds
fid = fopen(savepath,'wt');
for i=1:length(ibis)
    fprintf(fid,'%f\n',ibis(i));
end
fclose(fid);
end

