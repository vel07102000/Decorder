function myApp()
    % Singleton check
    appTag = 'MySingletonGUI';
    existingFig = findall(0, 'Type', 'figure', 'Tag', appTag);

    if ~isempty(existingFig)
        figure(existingFig);
        return;
    end

    % Main figure
    hFig = figure('Name', 'Multi-Tab GUI', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'ToolBar', 'none', ...
        'Tag', appTag, ...
        'Position', [500, 300, 600, 500]);

    % Create tab group
    hTabGroup = uitabgroup('Parent', hFig);

    % ===== Tab 1: Decoder =====
    tab1 = uitab('Parent', hTabGroup, 'Title', 'Decoder');

    % File path label
    uicontrol('Style', 'text', 'Parent', tab1, ...
        'String', 'File Path:', ...
        'Position', [10 430 100 20], ...
        'HorizontalAlignment', 'left', ...
        'FontSize', 10);

    % File path input
    hFilePath = uicontrol('Style', 'edit', 'Parent', tab1, ...
        'Position', [70 430 250 25], ...
        'FontSize', 10);

    % Browse button for file path
    hBrowseBtn = uicontrol('Style', 'pushbutton', 'Parent', tab1, ...
        'String', 'Browse', ...
        'Position', [320 430 100 25], ...
        'FontSize', 10, ...
        'Callback', @(src, event) browseFile(hFilePath));

    % Part No. label
    uicontrol('Style', 'text', 'Parent', tab1, ...
        'String', 'Part No:', ...
        'Position', [10 390 100 20], ...
        'HorizontalAlignment', 'left', ...
        'FontSize', 10);

    % Part No input
    hPartNo = uicontrol('Style', 'edit', 'Parent', tab1, ...
        'Position', [70 390 250 25], ...
        'FontSize', 10);

    % Decode button
    hLoadBtn = uicontrol('Style', 'pushbutton', 'Parent', tab1, ...
        'String', 'Decode', ...
        'Position', [320 390 100 25], ...
        'FontSize', 10);

    % Clear button
    hClearBtn = uicontrol('Style', 'pushbutton', 'Parent', tab1, ...
        'String', 'Clear', ...
        'Position', [420 390 100 25], ...
        'FontSize', 10);

    % Data table
    hTable = uitable('Parent', tab1, ...
        'Position', [30 50 520 320], ...  % Larger table
        'Data', {}, ...
        'ColumnName', {'ID', 'Name', 'Value'}, ...
        'ColumnWidth', {50, 200, 100}, ...
        'FontSize', 10);

    % Assign callbacks
    set(hLoadBtn, 'Callback', @(src, event) loadData(hPartNo, hFilePath, hTable));
    set(hClearBtn, 'Callback', @(src, event) clearInputs(hPartNo, hFilePath, hTable));

    % ===== Tab 2: Placeholder =====
    tab2 = uitab('Parent', hTabGroup, 'Title', 'Report Generation');

    uicontrol('Style', 'text', 'Parent', tab2, ...
        'String', 'This tab is under construction. More to come!', ...
        'Position', [150 180 300 40], ...
        'FontSize', 12, ...
        'ForegroundColor', [0.4 0.4 0.4]);
end

% Callback for browsing file
function browseFile(hFilePath)
    % Open file dialog to choose file
    [fileName, filePath] = uigetfile('*.*', 'Select a File');
    if fileName ~= 0
        fullPath = fullfile(filePath, fileName);
        set(hFilePath, 'String', fullPath);
    end
end

% Callback for loading data
function loadData(hPartNo, hFilePath, hTable)
    partNo = get(hPartNo, 'String');
    filePath = get(hFilePath, 'String');

    if isempty(partNo) || isempty(filePath)
        warndlg('Please provide Part No and File Path.', 'Missing Input');
        return;
    end

    % Simulated loading of data from the file
    try
        % Read from the file (you can modify this as per your file format)
        fileData = readtable(filePath); % assuming CSV or other tabular format
        data = table2cell(fileData);
    catch
        warndlg('Error reading the file. Please check the file format.', 'File Error');
        return;
    end

    % Insert the partNo into the table
    for i = 1:size(data, 1)
        data{i, 2} = [partNo '_' num2str(i)]; % Adding Part No info to Name column
    end

    % Update table
    set(hTable, 'Data', data);
end

% Callback for clearing inputs and table
function clearInputs(hPartNo, hFilePath, hTable)
    % Clear the part number and file path fields
    set(hPartNo, 'String', '');
    set(hFilePath, 'String', '');

    % Clear the table
    set(hTable, 'Data', {});
end
