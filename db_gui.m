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
% (2.1) draw main ui
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
            'Position', [screenSz(1)/4, screenSz(2)+screenSz(2)/5, 1000 750], ...
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
        [gui.experiment, data.experiment] = ...
            draw_experiment(gui.main, data.project.active);
    end
    
% (2.2) draw project table controls
    function [ui, dat] = draw_project(main)
        % get table data
        ui = struct(); % struct with ui handles
        dat = struct(); % struct with table data
        [dat.id, dat.name] = mysql('select * from Project;');
        if numel(dat.id) == 0 % empty table
            popup_state = 'off';
            edit_state = 'on'; % show editbox, add and cancel btn
            key_str = {''};
            dat.active = 0;
        else % populated table
            popup_state = 'on'; % show key select popup
            edit_state = 'off';
            key_str = keystr_zipper(dat.name, dat.id);
            dat.active = dat.id(1);
        end
        
        % draw ui controls
        ui.panel = uipanel('Parent', main, ...
            'BorderType', 'line', ...
            'HighlightColor', [0 0 0], ...
            'Units', 'pixel', ...
            'Position', [25 625 462.5 100]);
        ui.title_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'pixel', ...
            'FontSize', 12, ...
            'FontWeight', 'bold', ...
            'String', 'Project', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'center', ...
            'Visible', 'on', ...
            'Position', [187.25 60 88 26]);
        ui.subtitle_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'pixel', ...
            'FontSize', 8, ...
            'String', sprintf('( Rows: %d )', numel(dat.id)), ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'center', ...
            'Visible', 'on', ...
            'Position', [360 55 70 26]);
        ui.key_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'pixel', ...
            'FontSize', 10, ...
            'String', 'Name:', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'on', ...
            'Position', [15 20 66 26]);
        ui.key_popup = uicontrol('Parent', ui.panel, ...
            'Style', 'popupmenu', ...
            'Units', 'pixel', ...
            'Enable', 'on', ...
            'Visible', popup_state, ...
            'Position', [90 46 232.5 4], ...
            'FontSize', 10, ...
            'String', key_str, ...
            'Value', 1, ...
            'TooltipString', 'Select a project', ...
            'Callback', @project_select_fcn);
        ui.name_edit = uicontrol('Parent', ui.panel, ...
            'Style', 'edit', ...
            'Units', 'pixel', ...
            'Enable', 'on', ...
            'Visible', edit_state, ...
            'Position', [90 25 232.5 25]);
        ui.key_add_btn = uicontrol('Parent', ui.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'pixel', ...
            'Enable', 'on', ...
            'Visible', 'on', ...
            'String', '+', ...
            'Callback', @project_add_fcn, ...
            'Position', [352.5 25 25 25]);
        ui.key_rem_btn = uicontrol('Parent', ui.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'pixel', ...
            'Enable', popup_state, ...
            'Visible', 'on', ...
            'String', '-', ...
            'Callback', @project_rem_fcn, ...
            'Position', [382.5 25 25 25]);
        ui.key_cancel_btn = uicontrol('Parent', ui.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'pixel', ...
            'Enable', edit_state, ...
            'Visible', 'on', ...
            'String', 'x', ...
            'Callback', @project_cancel_fcn, ...
            'Position', [412.5 25 25 25]);
    end

% (2.3) draw experiment table controls
    function [ui, dat] = draw_experiment(main, active)
        % get table data
        ui = struct(); % struct with ui handles
        dat = struct(); % struct with table data
        [dat.id, dat.experimenter, dat.desc] = ...
            mysql(sprintf('select experiment_id, experimenter, description from Experiment where project_id = %d;', ...
            active));
        if active == 0 % no project selected
            popup_state = 'off';
            edit_state = 'off'; % show editbox, add and cancel btn
            key_str = {'No project selected'};
            experimenter_str = '';
            description_str = '';
            dat.active = 0;
        elseif numel(dat.id) == 0 % empty table where project_id
            popup_state = 'off';
            edit_state = 'on'; % show editbox, add and cancel btn
            key_str = {'Create new'};
            experimenter_str = '';
            description_str = '';
            dat.active = 0;
        else % populated table
            popup_state = 'on'; % show key select popup
            edit_state = 'off';
            key_str = keystr_zipper(dat.experimenter, id);
            experimenter_str = dat.experimenter(1);
            description_str = dat.desc(1);
            dat.active = dat.id(1);
        end
        
        % draw ui controls
        ui.panel = uipanel('Parent', main, ...
            'BorderType', 'line', ...
            'HighlightColor', [0 0 0], ...
            'Units', 'pixel', ...
            'Position', [512.5 555 462.5 170]);
        ui.title_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'pixel', ...
            'FontSize', 12, ...
            'FontWeight', 'bold', ...
            'String', 'Experiment', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'center', ...
            'Visible', 'on', ...
            'Position', [10 130 442.5 26]);
        ui.subtitle_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'pixel', ...
            'FontSize', 8, ...
            'String', sprintf('( Rows: %d )', numel(dat.id)), ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'center', ...
            'Visible', 'on', ...
            'Position', [360 125 70 26]);
        ui.key_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'pixel', ...
            'FontSize', 10, ...
            'String', 'Key:', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'on', ...
            'Position', [15 90 66 26]);
        ui.key_popup = uicontrol('Parent', ui.panel, ...
            'Style', 'popupmenu', ...
            'Units', 'pixel', ...
            'Enable', popup_state, ...
            'Visible', 'on', ...
            'Position', [90 116 232.5 4], ...
            'FontSize', 10, ...
            'String', key_str, ...
            'Value', 1, ...
            'TooltipString', 'Select an experiment', ...
            'Callback', @experiment_select_fcn);
        ui.experimenter_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'pixel', ...
            'FontSize', 10, ...
            'String', 'User:', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'on', ...
            'Position', [15 50 66 26]);
        ui.experimenter_edit = uicontrol('Parent', ui.panel, ...
            'Style', 'edit', ...
            'Units', 'pixel', ...
            'Enable', edit_state, ...
            'String', experimenter_str, ...
            'Visible', 'on', ...
            'Position', [90 55 232.5 25]);
        ui.description_text = uicontrol('Parent', ui.panel, ...
            'Style', 'text', ...
            'Units', 'pixel', ...
            'FontSize', 10, ...
            'String', 'Note:', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'on', ...
            'Position', [15 15 66 26]);
        ui.description_edit = uicontrol('Parent', ui.panel, ...
            'Style', 'edit', ...
            'Units', 'pixel', ...
            'Enable', edit_state, ...
            'String', description_str, ...
            'Visible', 'on', ...
            'Position', [90 20 232.5 25]);
        ui.key_add_btn = uicontrol('Parent', ui.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'pixel', ...
            'Enable', edit_state, ...
            'Visible', 'on', ...
            'String', '+', ...
            'Callback', @experiment_add_fcn, ...
            'Position', [352.5 95 25 25]);
        ui.key_rem_btn = uicontrol('Parent', ui.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'pixel', ...
            'Enable', popup_state, ...
            'Visible', 'on', ...
            'String', '-', ...
            'Callback', @experiment_rem_fcn, ...
            'Position', [382.5 95 25 25]);
        ui.key_cancel_btn = uicontrol('Parent', ui.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'pixel', ...
            'Enable', edit_state, ...
            'Visible', 'on', ...
            'String', 'x', ...
            'Callback', @experiment_cancel_fcn, ...
            'Position', [412.5 95 25 25]);
    end
%% (3) ui callback functions
% (3.1) project table callbacks  
    function project_select_fcn(src, event)
        if isempty(data.project.id)
            data.project.active = 0;
        else
            data.project.active = data.project.id(get(gui.project.key_popup, 'Value'));
        end
        % update depending tables
        experiment_update_fcn();
    end

    function project_add_fcn(src, event)
        if strcmp(get(gui.project.key_popup, 'Visible'), 'on')
            popup_state = 'off';
            edit_state = 'on';
        elseif strcmp(get(gui.project.name_edit, 'Visible'), 'on')
            name = get(gui.project.name_edit, 'String');
            data.project.id = [data.project.id, insert_project(name)];
            data.project.name = [data.project.name, name];
            set(gui.project.subtitle_text, ...
                'String', sprintf('( Rows: %d )', length(data.project.id)));
            set(gui.project.name_edit, 'String', '');
            set(gui.project.key_popup, ...
                'String', keystr_zipper(data.project.name, data.project.id));
            set(gui.project.key_popup, ...
                'Value', length(data.project.id));
            project_select_fcn(src, event); % trigger project select callback
            popup_state = 'on';
            edit_state = 'off';
        end
        set(gui.project.name_edit, 'Visible', edit_state);
        set(gui.project.key_popup, 'Visible', popup_state);
        set(gui.project.key_cancel_btn, 'Enable', edit_state);
        set(gui.project.key_rem_btn, 'Enable', popup_state);
    end

    function project_rem_fcn(src, event)
        val = get(gui.project.key_popup, 'Value');
        id = data.project.id(val);
        answ = questdlg('Are you sure?', 'Confirm removal', 'Yes', 'No', 'No');
        if strcmp(answ, 'Yes')
            % delete row
            mysql(sprintf('delete from Project where project_id = %d;', id));
            % update ui / data container
            data.project.id(val) = [];
            data.project.name(val) = [];
            set(gui.project.subtitle_text, ...
                'String', sprintf('( Rows: %d )', length(data.project.id)));
            set(gui.project.key_popup, ...
                'String', keystr_zipper(data.project.name, data.project.id));
            set(gui.project.key_popup, ...
                'Value', length(data.project.id));
            project_select_fcn(src, event);
            if isempty(data.project.id) % force edit mode
                set(gui.project.name_edit, 'Visible', 'on');
                set(gui.project.key_popup, 'Visible', 'off');
                set(gui.project.key_cancel_btn, 'Enable', 'on');
                set(gui.project.key_rem_btn, 'Enable', 'off');
            end
        end
    end

    function project_cancel_fcn(src, event)
        if ~isempty(data.project.id)
            set(gui.project.name_edit, 'Visible', 'off');
            set(gui.project.key_popup, 'Visible', 'on');
            set(gui.project.key_rem_btn, 'Enable', 'on');
            set(src, 'Enable', 'off');
        else
            set(gui.project.name_edit, 'String', '');
        end
    end

% (3.2) Experiment table callbacks

    function experiment_update_fcn()
        [data.experiment.id, data.experiment.experimenter, data.experiment.description] = ...
            mysql(sprintf('select experiment_id, experimenter, description from Experiment where project_id = %d;', ...
            data.project.active));
        if data.project.active == 0 % no project selected
            popup_state = 'off';
            edit_state = 'off'; % show editbox, add and cancel btn
            key_str = {'No project selected'};
            experimenter_str = '';
            description_str = '';
            data.experiment.active = 0;
        elseif numel(data.experiment.id) == 0 % empty table where project_id
            popup_state = 'off';
            edit_state = 'off'; % show editbox, add and cancel btn
            key_str = {'Create new'};
            experimenter_str = '';
            description_str = '';
            data.experiment.active = 0;
        else % populated table
            popup_state = 'on'; % show key select popup
            edit_state = 'off';
            key_str = keystr_zipper(dat.experimenter, id);
            experimenter_str = dat.experimenter(1);
            description_str = dat.desc(1);
            data.experiment.active = dat.id(1);
        end
        
        set(gui.experiment.key_popup, 'Enable', popup_state);
        set(gui.experiment.key_popup, 'String', key_str);
        set(gui.experiment.key_popup, 'Value', 1);
        set(gui.experiment.experimenter_edit, 'Enable', edit_state);
        set(gui.experiment.experimenter_edit, 'String', experimenter_str);
        set(gui.experiment.description_edit, 'Enable', edit_state);
        set(gui.experiment.description_edit, 'String', description_str);
        set(gui.experiment.key_add_btn, 'Enable', popup_state);
        set(gui.experiment.key_rem_btn, 'Enable', popup_state);
        set(gui.experiment.key_cancel_btn, 'Enable', edit_state);
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

