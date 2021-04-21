function edh = readMwEdh(edh_path)
%READMWEDH Attempt to read the mindware edit file
%   Detailed explanation goes here
fid = fopen(edh_path,'r','b');
edh=fread(fid,'uint16');
fclose(fid);
end

