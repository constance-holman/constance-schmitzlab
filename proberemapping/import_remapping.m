function [shank,probe,connector,headstage,x,y] = import_remapping(filename, startRow, endRow)
%import_remapping Import numeric data from a probe remapping CSV file as column vectors.
%   [shank,probe,connector,headstage,x,y] = import_remapping(FILENAME)
%   Reads data from text file FILENAME for the default selection.
%
%   [shank,probe,connector,headstage,x,y] = import_remapping(FILENAME,
%   STARTROW, ENDROW) Reads data from rows STARTROW through ENDROW of text
%   file FILENAME.
%
% Example:
%   [shank,probe,connector,headstage,x,y] = import_remapping('ProbeRemapping_CNT32_Edge2x16_Amplipex.csv',7, 38);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2018/04/01 19:43:02

%% Initialize variables.
delimiter = ';';
if nargin<=2
    startRow = 7;
    endRow = inf;
end

%% Format for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
shank = dataArray{:, 1};
probe = dataArray{:, 2};
connector = dataArray{:, 3};
headstage = dataArray{:, 4};
x = dataArray{:, 5};
y = dataArray{:, 6};


