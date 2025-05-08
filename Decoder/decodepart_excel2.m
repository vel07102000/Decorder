function decoded = decodepart_excel2(excelPath, partNo)
    % Validate inputs
    if nargin < 2 || exist(excelPath, 'file') ~= 2
        error('Excel file path is missing or invalid.');
    end

    if length(partNo) < 18
        error('Part number too short!');
    end

    % === Slice part number ===
    decoded = struct();
    decoded.Product_Family   = partNo(1:7);      % Product Family
    decoded.silicon_revision = partNo(8);        % Silicon Revision
    decoded.temperature_code = partNo(9);        % Temperature Code
    decoded.output_type      = partNo(10);       % Output Type
    decoded.package_code     = partNo(11);       % Package Code
    decoded.stability_code   = partNo(12);       % Stability Code
    decoded.i2c_code         = partNo(13);       % I2C Code
    decoded.vdd_code         = partNo(14:15);    % VDD Code
    decoded.pin1_feature     = partNo(16);       % Pin1 Feature
    decoded.pin3_feature     = partNo(17);  
    decoded.Specs_sheet  = partNo(1:7);  % Product Family as part of Specs sheet

    % === Frequency Extraction ===
    if isletter(partNo(end))   % Check if the last character is a letter
        freqStr = partNo(18:end-1);  % Frequency in partNo starting from character 18
    else
        freqStr = partNo(18:end);    % If no letter, frequency starts from 19
    end

    freqVal = str2double(freqStr);   % Convert frequency to number
    if isnan(freqVal)
        warning('Could not parse frequency part of the part number.');
        decoded.frequency_hz = NaN;
    else
        decoded.frequency_hz = freqVal * 1e6;  % Convert to Hz
    end

    % === List of fields/sheets to match ===
    fields_to_match = {'Product_Family', 'Specs_sheet'};  % Match Product Family and Specs Sheet

    % === Get available sheet names ===
    [~, sheetNames] = xlsfinfo(excelPath);
    decoded.sheetNames = sheetNames;
    % === Loop through fields and match with sheets ===
    for i = 1:length(fields_to_match)
        field = fields_to_match{i};

        % Check if the sheet exists
        if any(strcmpi(sheetNames, field))
            try
                tbl = readtable(excelPath, 'Sheet', field);

                % Get first column as key for matching
                keys = tbl{:, 1};  % Product numbers (e.g., SIT5134, SIT5135, etc.)

                % Convert both key and value to char for R2016b compatibility
                partValue = decoded.(field);
                matchIdx = false(size(keys));

                % Find matching rows for the given part number
                for k = 1:length(keys)
                    if iscell(keys)
                        keyVal = char(keys{k});
                    else
                        keyVal = char(keys(k));
                    end
                    matchIdx(k) = strcmpi(keyVal, partValue);  % Case insensitive match
                end

                % If matched, store the corresponding rows for Specs Sheet
                if any(matchIdx)
                    % Extract only the matching rows for the specific part number
                    matchedRows = tbl(matchIdx, :);
                    
                    % Store the matched rows for Specs sheet in decoded structure
                    decoded.([field '_info']) = matchedRows;  % Store as a table
                else
                    decoded.([field '_info']) = table();  % No match found, empty table
                end

            catch ME
                warning('Error reading sheet "%s": %s', field, ME.message);
                decoded.([field '_info']) = table();  % Fallback to empty table
            end
        else
            warning('Sheet "%s" not found in Excel file.', field);
            decoded.([field '_info']) = table();  % Sheet not found, empty table
        end
    end
end
% 