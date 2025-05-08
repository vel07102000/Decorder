function TopazApp()
    % Singleton check
    appTag = 'MySingletonGUI';
    existingFig = findall(0, 'Type', 'figure', 'Tag', appTag);
    if ~isempty(existingFig)
        figure(existingFig);
        return;
    end

    % Main figure
    hFig = figure('Name', 'Part Decoder', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...
        'Tag', appTag, ...
        'Position', [500, 300, 640, 520], ...
        'Resize', 'off', ...
        'Color', [0.95 0.95 0.95]);

    % Create tab group
    hTabGroup = uitabgroup('Parent', hFig);
    tab1 = uitab('Parent', hTabGroup, 'Title', 'Decoder');

    % UI Layout
    labelFont = 10;
    inputFont = 10;
    leftX = 20;
    width1 = 80;
    width2 = 300;
    height = 25;
    spacing = 10;
    y = 440;

    % Excel File Label
    uicontrol('Style', 'text', 'Parent', tab1, ...
        'String', 'Excel File:', ...
        'Position', [leftX, y, width1, height], ...
        'HorizontalAlignment', 'left', ...
        'FontSize', labelFont);

    % Excel File Path Input
    hFilePath = uicontrol('Style', 'edit', 'Parent', tab1, ...
        'Position', [leftX + width1 + spacing, y, width2, height], ...
        'FontSize', inputFont);

    % Browse Button
    uicontrol('Style', 'pushbutton', 'Parent', tab1, ...
        'String', 'Browse', ...
        'Position', [leftX + width1 + width2 + 2 * spacing, y, 80, height], ...
        'FontSize', inputFont, ...
        'Callback', @(~, ~) browseExcelFile(hFilePath));

    y = y - height - spacing;

    % Part Number Label
    uicontrol('Style', 'text', 'Parent', tab1, ...
        'String', 'Part No:', ...
        'Position', [leftX, y, width1, height], ...
        'HorizontalAlignment', 'left', ...
        'FontSize', labelFont);

    % Part Number Input
    hPartNo = uicontrol('Style', 'edit', 'Parent', tab1, ...
        'Position', [leftX + width1 + spacing, y, width2, height], ...
        'FontSize', inputFont, ...
        'Tag', 'PartInput');

    % Decode Button
    hLoadBtn = uicontrol('Style', 'pushbutton', 'Parent', tab1, ...
        'String', 'Decode', ...
        'Position', [leftX + width1 + width2 + 2 * spacing, y, 80, height], ...
        'FontSize', inputFont);

    % Clear Button
    hClearBtn = uicontrol('Style', 'pushbutton', 'Parent', tab1, ...
        'String', 'Clear', ...
        'Position', [leftX + width1 + width2 + 2 * spacing + 90, y, 80, height], ...
        'FontSize', inputFont);

% Data Table (update this in your TopazApp function)
hTable = uitable('Parent', tab1, ...
    'Position', [leftX, 40, 580, 330], ...
    'Data', {}, ...
    'ColumnName', {'Name', 'Min', 'Typ', 'Max'}, ...
    'ColumnWidth', {170, 100, 100, 100}, ...
    'FontSize', 10, ...
    'RowStriping', 'on');

    % Button Callbacks
    set(hLoadBtn, 'Callback', @(~, ~) loadExcelData(hPartNo, hFilePath, hTable));
    set(hClearBtn, 'Callback', @(~, ~) clearInputs(hPartNo, hFilePath, hTable));

    % Focus cursor
    uicontrol(hPartNo);
end

% --- Browse Excel File ---
function browseExcelFile(hFilePath)
    [file, path] = uigetfile({'*.xlsx;*.xls', 'Excel Files (*.xlsx, *.xls)'}, 'Select Excel File');
    if isequal(file, 0)
        return;
    end
    fullFilePath = fullfile(path, file);
    set(hFilePath, 'String', fullFilePath);
end

% --- Clear Inputs ---
function clearInputs(hPartNo, hFilePath, hTable)
    set(hPartNo, 'String', '');
    set(hFilePath, 'String', '');
    set(hTable, 'Data', {});
end

% --- Load Excel and Decode ---
function loadExcelData(hPartNo, hFilePath, hTable)
    partNo = strtrim(get(hPartNo, 'String'));
    filePath = strtrim(get(hFilePath, 'String'));

    if isempty(partNo) || isempty(filePath)
        warndlg('Please enter a part number and select an Excel file.', 'Missing Input');
        return;
    end

    try
        T = readtable(filePath, 'TextType', 'string');
    catch ME
        warndlg(['Error reading Excel file: ' ME.message], 'Read Error');
        return;
    end

    % Check for 'PartNo' column
    if ~any(strcmpi(T.Properties.VariableNames, 'PartNo'))
        warndlg('Excel file must contain a "PartNo" column.', 'Format Error');
        return;
    end

    % Match part number
    idx = strcmpi(T.PartNo, partNo);
    if ~any(idx)
        warndlg('Part number not found in Excel file.', 'Not Found');
        return;
    end

    % Extract matched row
    partData = T(idx, :);
    varNames = T.Properties.VariableNames;

    % Now process the parameters grouped in 4 columns: Parameter, Min, Typ, Max
    data = {};  % To populate the GUI table
    col = 2;    % Start from second column (after PartNo)

    while col <= numel(varNames)
    paramName = strrep(varNames{col}, '_', ' ');  % Clean underscores
    minCol = col + 1;
    typCol = col + 2;
    maxCol = col + 3;

    if maxCol > numel(varNames)
        break; % Avoid overflow
    end

    % Read values
    paramValue = partData.(varNames{col});
    minValue   = partData.(varNames{minCol});
    typValue   = partData.(varNames{typCol});
    maxValue   = partData.(varNames{maxCol});

    % Convert everything safely to char
    paramStr = toText(paramValue);
    minStr   = toText(minValue);
    typStr   = toText(typValue);
    maxStr   = toText(maxValue);

    % Add to data
    data{end+1, 1} = paramStr;  % Parameter Name
    data{end, 2}   = minStr;    % Min
    data{end, 3}   = typStr;    % Typ
    data{end, 4}   = maxStr;    % Max

    col = col + 4;
end

    % Update the GUI table
    set(hTable, 'Data', data);
    function txt = toText(val)
    if isnumeric(val)
        if isnan(val)
            txt = '';
        else
            txt = num2str(val);
        end
    elseif isstring(val) || ischar(val)
        txt = char(val);
    else
        txt = '';
    end
end

end
