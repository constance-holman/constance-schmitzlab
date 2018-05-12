function db_gui(host, user, password, database)

%% (1) gui setup
% (1.1) parse input arguments
p = inputParser;
p.addRequired('host', @(x) ischar(x));
p.addRequired('user', @(x) ischar(x));
p.addRequired('password', @(x) ischar(x));
p.addRequired('database', @(x) ischar(x));
p.parse(host, user, password, database);
args = p.Results;

fprintf(['Welcome to SchmitzLab database GUI!\n\n', ...
    'Copyright (C) 2018 Viktor Bahr (viktor [at] eridian.systems)\n\n', ...
    'Looking for working MySQL connector... ']);

% (1.2) test connector
if exist('mysql', 'file') == 3
    s = mysql('status');
    if s == 1
        fprintf('Done.\n\nTrying to establish connection... ');
        try 
            r = evalc('mysql(''open'', args.host, args.user, args.password)');
            r = evalc('mysql(''use'', args.database)');
        catch me
            fprintf('Failed.\n');
            error(me.message)
        end
        fprintf('Done.\n')
    elseif s == 0
        fprintf('Done.\n');
        answer = input('A SQL connection is already opened, [c]ontinue, close [a]ll, [q]uit: ', 's');
        if any(strcmpi(answer, {'c', 'continue'}))
            % do nothing
        elseif any(strcmpi(answer, {'a', 'ca', 'close', 'close all'}))
            while mysql('status') == 0
                mysql close;
            end
            fprintf('\nAll connections closed.\n')
            fprintf('Trying to establish new connection... ');
            try 
                r = evalc('mysql(''open'', args.host, args.user, args.password)');
                r = evalc('mysql(''use'', args.database)');
            catch me
                fprintf('Failed.\n');
                error(me.message)
            end
            fprintf('Done.\n')
        else
            fprintf('\nOkay, bye.\n')
            return;
        end
    else
        error('Connector works not as expected.');
    end
else
    error('MySQL connector not found on PATH.');
end

% (1.3) init schema
fprintf('\nInitializing database schema ... ');
if exist('db_init', 'file') == 0
    addpath('sql');
end
try
    db = db_init();
catch me
    fprintf('Failed.\n');
    error(me.message);
end
init = which('db_init.m');
fprintf('Done.\nSchema: ''%s''\n\nVerifying database:\n', init);

% (1.4) verify database
verified = verify_db(db, args);
if ~verified
    error('Database not compatible.')
end

% (1.5) draw gui
fprintf('Creating main window... ');
[gui, data] = draw_main();
fprintf('Done.\n\n');

% end of main function
%% (2) ui drawing functions
%% (2.1) draw main ui
    function [gui, data] = draw_main()
        % init handle and data container
        gui = struct();
        data = struct();
     
        % get screensize
        screenSz = get(0, 'Screensize');
        screenSz = [screenSz(3), screenSz(4)];
        bgColor = [0.9400 0.9400 0.9400];
        gui.main = figure('DockControls', 'off', ...
            'MenuBar', 'none', ...
            'Name', 'SchmitzLab Database', ...
            'NumberTitle', 'off', ...
            'Color', bgColor, ...
            'Position', [screenSz(1)/4, screenSz(2)+screenSz(2)/5, screenSz(1)/2, screenSz(2)/1.5], ...
            'ToolBar', 'none', ...
            'Resize', 'off');
        
        % create menus
        gui.menu_file = uimenu('Label', 'File');
        gui.menuitem_close = uimenu(gui.menu_file, 'Label', 'Quit', ...
            'Accelerator', 'Q');
        gui.menu_edit = uimenu('Label', 'Edit');
        gui.menuitem_project = uimenu(gui.menu_edit, 'Label', 'Project');
        gui.menuitem_experiment = uimenu(gui.menu_edit, 'Label', 'Experiment');
        gui.menuitem_animal = uimenu(gui.menu_edit, 'Label', 'Animal');
        gui.menuitem_session = uimenu(gui.menu_edit, 'Label', 'Session');
        gui.menuitem_behavior = uimenu(gui.menu_edit, 'Label', 'Behavior');
        gui.menuitem_recording = uimenu(gui.menu_edit, 'Label', 'Recording');
        gui.menuitem_histology = uimenu(gui.menu_edit, 'Label', 'Histology');
        gui.menu_about = uimenu('Label', 'About');
        
        % create first page
        [gui.project, data.project] = draw_project(gui.main);
    end
    
%% (2.2) draw project table contols
    function [ui, dat] = draw_project(main)
        % get table data
        [id, name] = mysql('select project_id, name from Project;');
        ui = struct(); % struct with ui handles
        dat = struct(); % struct with table data
        if numel(id) == 0 % empty table
            name_popup_state = 'off';
            name_edit_state = 'on'; % show editbox, add and cancel btn
            name_string = {''};
        else % populated table
            name_popup_state = 'on'; % show key select popup
            name_edit_state = 'off';
            name_string = keystr_zipper(name, id);
        end
        
        % draw ui controls
        ui.panel = uipanel('Parent', main, ...
            'BorderType', 'line', ...
            'HighlightColor', [0 0 0], ...
            'Units', 'norm', ...
            'Position', [0.025 0.825, 0.475, 0.125]);
        ui.title_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'norm', ...
            'FontSize', 12, ...
            'FontWeight', 'bold', ...
            'String', 'Project', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'on', ...
            'Position', [0.42 0.6 0.2 0.3]);
        ui.subtitle_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'norm', ...
            'FontSize', 8, ...
            'String', sprintf('( Rows: %d )', numel(id)), ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'on', ...
            'Position', [0.79 0.545 0.2 0.3]);
        ui.name_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'norm', ...
            'FontSize', 10, ...
            'String', 'Name:', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'on', ...
            'Position', [0.05 0.25 0.15 0.2]);
        ui.name_popup = uicontrol('Parent', ui.panel, ...
            'Style', 'popupmenu', ...
            'Units', 'norm', ...
            'Enable', 'on', ...
            'Visible', name_popup_state, ...
            'Position', [0.24 0.45 0.5 0.05], ...
            'FontSize', 10, ...
            'String', name_string, ...
            'Value', 1, ...
            'TooltipString', 'Select stimulus', ...
            'Callback', @project_select_fcn);
        ui.name_edit = uicontrol('Parent', ui.panel, ...
            'Style', 'edit', ...
            'Units', 'norm', ...
            'Enable', 'on', ...
            'Visible', name_edit_state, ...
            'Position', [0.24 0.205 0.498 0.285]);
        ui.name_add_btn = uicontrol('Parent', ui.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'norm', ...
            'Enable', name_edit_state, ...
            'Visible', 'on', ...
            'String', '+', ...
            'Callback', @project_add_fcn, ...
            'Position', [0.78 0.225 0.05 0.275]);
        ui.name_rem_btn = uicontrol('Parent', ui.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'norm', ...
            'Enable', name_popup_state, ...
            'Visible', 'on', ...
            'String', '-', ...
            'Callback', @project_rem_fcn, ...
            'Position', [0.84 0.225 0.05 0.275]);
        ui.name_cancel_btn = uicontrol('Parent', ui.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'norm', ...
            'Enable', name_edit_state, ...
            'Visible', 'on', ...
            'String', 'x', ...
            'Callback', @project_cancel_fcn, ...
            'Position', [0.9 0.225 0.05 0.275]);
        
        % asign variable to data container
        dat.id = id;
        dat.name = name;
    end


%% (3) ui callback functions
%% (3.1) project table callbacks  
    function project_select_fcn(src, event)
        % update selected key store
    end

    function project_add_fcn(src, event)
        if strcmp(get(gui.project.name_popup, 'Visible'), 'on')
            name_popup_state = 'off';
            name_edit_state = 'on';
        elseif strcmp(get(gui.project.name_edit, 'Visible'), 'on')
            name = get(gui.project.name_edit, 'String');
            data.project.id = [data.project.id, insert_project(name)];
            data.project.name = [data.project.name, name];
            set(gui.project.subtitle_text, ...
                'String', sprintf('( Rows: %d )', length(data.project.id)));
            set(gui.project.name_edit, 'String', '');
            set(gui.project.name_popup, ...
                'String', keystr_zipper(data.project.name, data.project.id));
            set(gui.project.name_popup, ...
                'Value', length(data.project.id));
            name_popup_state = 'on';
            name_edit_state = 'off';
        end
        set(gui.project.name_edit, 'Visible', name_edit_state);
        set(gui.project.name_popup, 'Visible', name_popup_state);
        set(gui.project.name_cancel_btn, 'Enable', name_edit_state);
        set(gui.project.name_rem_btn, 'Enable', name_popup_state);
    end

    function project_rem_fcn(src, event)
        val = get(gui.project.name_popup, 'Value');
        id = data.project.id(val);
        answer = questdlg('Are you sure?', 'Confirm removal', 'Yes', 'No', 'No');
        if strcmp(answer, 'Yes')
            % delete row
            mysql(sprintf('delete from Project where project_id = %d;', id));
            % update ui / data container
            data.project.id(val) = [];
            data.project.name(val) = [];
            set(gui.project.subtitle_text, ...
                'String', sprintf('( Rows: %d )', length(data.project.id)));
            set(gui.project.name_popup, ...
                'String', keystr_zipper(data.project.name, data.project.id));
            set(gui.project.name_popup, ...
                'Value', length(data.project.id));
            if isempty(data.project.id) % force edit mode
                set(gui.project.name_edit, 'Visible', 'on');
                set(gui.project.name_popup, 'Visible', 'off');
                set(gui.project.name_cancel_btn, 'Enable', 'on');
                set(gui.project.name_rem_btn, 'Enable', 'off');
            end
        end
    end

    function project_cancel_fcn(src, event)
        if ~isempty(data.project.id)
            set(gui.project.name_edit, 'Visible', 'off');
            set(gui.project.name_popup, 'Visible', 'on');
            set(gui.project.name_rem_btn, 'Enable', 'on');
            set(src, 'Enable', 'off');
        else
            set(gui.project.name_edit, 'String', '');
        end
    end

%% (4) helper functions
    % zip cellstring and integer into new cellstring
    function keystr = keystr_zipper(cellstr, id)
        n = length(cellstr);
        keystr = cell(n, 1);
        if n == 0
            keystr = {''};
            return;
        end
        for i = 1:n
            keystr{i} = sprintf('%s (ID: %d)', cellstr{i}, id(i));
        end
    end

    % verify database integrity
    function bool = verify_db(db, args)
        % verify if tables are there
        t = mysql('show tables;');
        tables = fieldnames(db);
        alive = cellfun(@(x) any(strcmp(t, x)), tables);
        if all(alive)
            fprintf('- [x] All tables present.\n')
        elseif any(alive)
            fprintf('- [~] Detected missing tables:\n');
            fprintf('\t%s\n',tables{~alive});
            create = input('- [~] Create missing tables? [Y/n]: ', 's');
            if isempty(create) || ~any(strcmpi(create, {'n', 'no'}))
                cellfun(@(x) create_table(db.(x), 'Verbose', false), tables(~alive));
                alive = cellfun(@(x) any(strcmp(x, tables)), t);
                fprintf('- [x] All tables present.\n')
            else
                fprintf('- [~] Okay, continuing with missing tables.\n')
            end
        else
            fprintf('- [o] No tables detected.\n');
            create = input('- [o] Create all tables? [Y/n]: ', 's');
            if isempty(create) || ~any(strcmpi(create, {'n', 'no'}))
                create_table(db, 'Verbose', false);
                alive = cellfun(@(x) any(strcmp(x, tables)), t);
                fprintf('- [x] All tables present.\n')
            else
                fprintf('- [o] Okay, bye.\n')
                bool = false;
                return
            end
        end
        % verify that database is populated with a-priori knowledge
        cnt = cellfun(@(x) mysql(sprintf('select count(*) from %s', x)), tables(alive));
        if ~any(cnt)
            fprintf('- [o] Database is empty.\n');
            setup = input('- [o] Run setup script? [Y/n]: ', 's');
            if isempty(setup) || ~any(strcmpi(setup, {'n', 'no'}))
                db_setup(args.host, args.user, args.password, args.database, 'Verbose', false);
            else
                fprintf('- [o] Warning, some functions will not be useable.\n');
            end
        else
            fprintf('- [x] Database seems populated (%d rows).\n', sum(cnt));
        end
        fprintf('\n')
        bool = true;
    end

%     function col_cell = htmlCellColor(color, str)
%         if ~isempty(color)
%             col_cell = sprintf('<html><table border=0 bgcolor=%s><TR><TD>%s</TD></TR></table></html>', ...
%                 color, str);
%         end
%     end
end

