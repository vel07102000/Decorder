function decoded = decodepart_excel(excelPath, partNo)
    % Validate input
    if nargin < 2 || exist(excelPath, 'file') ~= 2
        error('Excel file path is missing or invalid.');
    end

    if length(partNo) < 18
        error('Part number too short!');
    end

    % Initialize decoded structure
    decoded = struct();
    decoded.product_family = partNo(1:7);  % Extract product family from partNo
    decoded.silicon_revision = partNo(8);  % Silicon revision
    decoded.temperature_code = partNo(9);  % Temperature code
    decoded.output_type = partNo(10);     % Output type
    decoded.package_code = partNo(11);    % Package code
    decoded.stability_code = partNo(12);  % Stability code
    decoded.i2c_code = partNo(13);        % I2C code
    decoded.vdd_code = partNo(14:15);     % VDD code (14-15)
    decoded.pin1_feature = partNo(16);    % Pin1 feature
    decoded.pin3_feature = partNo(17);    % Pin3 feature

    % Frequency extraction
    if isletter(partNo(end))
        freqStr = partNo(19:end-1);
    else
        freqStr = partNo(19:end);
    end
    decoded.frequency_hz = str2double(freqStr) * 1e6;  % Convert to Hz

    % Load Excel file
    [~, sheets] = xlsfinfo(excelPath);  % Get sheet names

    % Fetch data from the appropriate sheets based on partNo slices
    try
        % Product Family Sheet (first 7 characters)
        sheetName = decoded.Product_Family;  % Sheet is named after product family
        decoded.product_family_specs = getSheetData(excelPath, sheetName);
        
%          need to take extact row value along with column names 

        % Temperature Code Sheet (9th character)
        sheetName = decoded.temperature_code;  % Sheet named after temperature code
        decoded.temperature_specs = getSheetData(excelPath, sheetName);

        % Stability Code Sheet (12th character)
        sheetName = decoded.stability_code;   % Sheet named after stability code
        decoded.stability_specs = getSheetData(excelPath, sheetName);

        % I2C Code Sheet (13th character)
        sheetName = decoded.i2c_code;         % Sheet named after I2C code
        decoded.i2c_specs = getSheetData(excelPath, sheetName);

        % VDD Code Sheet (14th-15th characters)
        sheetName = decoded.vdd_code;         % Sheet named after VDD code
        decoded.vdd_specs = getSheetData(excelPath, sheetName);

        % Pin1 Feature Sheet (16th character)
        sheetName = decoded.pin1_feature;     % Sheet named after Pin1 feature
        decoded.pin1_specs = getSheetData(excelPath, sheetName);

        % Pin3 Feature Sheet (17th character)
        sheetName = decoded.pin3_feature;     % Sheet named after Pin3 feature
        decoded.pin3_specs = getSheetData(excelPath, sheetName);

    catch decodeErr
        warning('Error occurred while decoding: %s', decodeErr.message);
    end,
end

% Helper function to read data from the specified sheet
function sheetData = getSheetData(excelPath, sheetName)
    try
        % Read the sheet data
        sheetData = readtable(excelPath, 'Sheet', sheetName);
    catch
        error('Error reading sheet: %s from Excel', sheetName);
    end
end
