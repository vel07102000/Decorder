function decoded = decodepart(jsonPath, partNo)
    % Validate input
    if nargin < 2 || exist(jsonPath, 'file') ~= 2
        error('JSON mapping file path is missing or invalid.');
    end

    if length(partNo) < 18
        error('Part number too short!');
    end

    % Load JSON map
    jsonText = fileread(jsonPath);
    mapData = jsondecode(jsonText);

    % Initialize decoded structure
    decoded = struct();
    decoded.product_family = partNo(1:7);
    decoded.silicon_revision = partNo(8);
    decoded.temperature_code = partNo(9);
    decoded.output_type = partNo(10);
    decoded.package_code = partNo(11);
    decoded.stability_code = partNo(12);
    decoded.i2c_code = partNo(13);
    decoded.vdd_code = partNo(14:15);
    decoded.pin1_feature = partNo(16);
    decoded.pin3_feature = partNo(17);

    % Frequency
    if isletter(partNo(end))
        freqStr = partNo(19:end-1);
    else
        freqStr = partNo(19:end);
    end
    decoded.frequency_hz = str2double(freqStr) * 1e6;

    try
        % Product family (directly copied as-is)
        % already set

        % Temperature range
        if isfield(mapData.temperature_range, decoded.temperature_code)
            decoded.temperature_range = mapData.temperature_range.(decoded.temperature_code);
            decoded.temperature_range_notation = decoded.temperature_code;
        end

        % Output waveform
        if isfield(mapData.output_waveform, decoded.output_type)
            decoded.output_waveform = mapData.output_waveform.(decoded.output_type).output_waveform;
        end

        % Special FSPECL (mockup, adjust logic as needed)
        if strcmp(decoded.output_waveform, 'FSPECL_VDD')
            % You can modify this part to fetch actual values
            decoded.fspecl_vdd_VHn = 1.05;
            decoded.fspecl_vdd_VLn = 1.55;
        end

        % Package size
        if isfield(mapData.package_size, decoded.package_code)
            decoded.package_sz = mapData.package_size.(decoded.package_code);
        end

        % Frequency stability
        if isfield(mapData.frequency_stability_ppm, decoded.stability_code)
            decoded.frequency_stability_ppm = mapData.frequency_stability_ppm.(decoded.stability_code);
        end

        % VDD
        if isfield(mapData.supply_voltage, decoded.vdd_code)
            vddInfo = mapData.supply_voltage.(decoded.vdd_code);
            decoded.vdd_notation = decoded.vdd_code;
            decoded.vdd_nom = vddInfo.vdd_nom;
            decoded.vdd_max = vddInfo.vdd_max;
        end

        % Superreg Enable (mockup logic, customize as per your real rules)
        decoded.superreg_enable = 1; % always 1 for now, or change based on conditions

        % Pin 1 feature
        if isfield(mapData.prog_pin_feature, decoded.pin1_feature)
            decoded.feature_pin = mapData.prog_pin_feature.(decoded.pin1_feature);
        end

    catch decodeErr
        warning('Partial decode due to: %s', decodeErr.message);
    end

    % Strip to only required fields
    keepFields = {
        'product_family', ...
        'silicon_revision', ...
        'temperature_range_notation', ...
        'temperature_range', ...
        'output_waveform', ...
        'fspecl_vdd_VHn', ...
        'fspecl_vdd_VLn', ...
        'package_sz', ...
        'frequency_stability_ppm', ...
        'vdd_notation', ...
        'superreg_enable', ...
        'vdd_nom', ...
        'vdd_max', ...
        'feature_pin', ...
        'frequency_hz'
    };

    allFields = fieldnames(decoded);
    for i = 1:numel(allFields)
        if ~ismember(allFields{i}, keepFields)
            decoded = rmfield(decoded, allFields{i});
        end
    end
end
