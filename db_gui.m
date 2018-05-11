function db_gui(host, user, password, database)

% parse input arguments
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

% test connector
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
verified = verify_db(db, args);
if ~verified
    error('Database not compatible.')
end

fprintf('Creating main window... ');
[gui, data] = draw_main();
fprintf('Done.\n\n');

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
        gui.project = draw_project(gui.main);
    end

    function project = draw_project(main)
        [id, name] = mysql('select project_id, name from Project;');
        project = struct();
        project.panel = uipanel('Parent', main, ...
            'BorderType', 'line', ...
            'HighlightColor', [0 0 0], ...
            'Units', 'norm', ...
            'Position', [0.025 0.825, 0.475, 0.125]);
        project.title_text = uicontrol('Parent', project.panel, ...
            'Style', 'text', ...
            'Units', 'norm', ...
            'FontSize', 12, ...
            'FontWeight', 'bold', ...
            'String', 'Project', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'on', ...
            'Position', [0.425 0.6 0.2 0.3]);
        project.name_text = uicontrol('Parent', project.panel, ...
            'Style', 'text', ...
            'Units', 'norm', ...
            'FontSize', 10, ...
            'String', 'Name:', ...
            'Enable', 'on', ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'on', ...
            'Position', [0.05 0.25 0.15 0.2]);
        project.name_popup = uicontrol('Parent', project.panel, ...
            'Style', 'popupmenu', ...
            'Units', 'norm', ...
            'Enable', 'on', ...
            'Visible', 'off', ...
            'Position', [0.24 0.45 0.5 0.05], ...
            'FontSize', 10, ...
            'String', {'None', 'Create new'}, ...
            'Value', 1, ...
            'TooltipString', 'Select stimulus', ...
            'Callback', @(x) disp('Test'));
        project.name_edit = uicontrol('Parent', project.panel, ...
            'Style', 'edit', ...
            'Units', 'norm', ...
            'Enable', 'on', ...
            'Visible', 'off', ...
            'Position', [0.24 0.22 0.5 0.25]);
        project.name_add_button = uicontrol('Parent', project.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'norm', ...
            'Enable', 'off', ...
            'String', '+', ...
            'Callback', disp('Test'), ...
            'Position', [0.825 0.225 0.05 0.275]);
        project.name_rem_button = uicontrol('Parent', project.panel, ... 
            'Style', 'pushbutton', ...
            'Units', 'norm', ...
            'Enable', 'off', ...
            'String', '-', ...
            'Callback', disp('Test'), ...
            'Position', [0.9 0.225 0.05 0.275]);
    end

%     function col_cell = htmlCellColor(color, str)
%         if ~isempty(color)
%             col_cell = sprintf('<html><table border=0 bgcolor=%s><TR><TD>%s</TD></TR></table></html>', ...
%                 color, str);
%         end
%     end
end

