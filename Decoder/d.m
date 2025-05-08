% Create a simple structure
config.SIT5134.freq_range = '1-60MHz';
config.SIT5134.trim_mode = 'LP';
config.SIT5134.outdrv = 'LVCMOS';

% Convert the structure to a JSON string
jsonStr = jsonencode(config);

% Save the JSON to a file
fid = fopen('C:\Report_generation\Part number\Decoder\part_config.json', 'w');
if fid == -1
    error('Cannot create JSON file.');
end
fwrite(fid, jsonStr, 'char');
fclose(fid);

disp('? JSON file saved as part_config.json');
