% Created by Angie Wang on Oct. 11 2019
% Adapted from K2Lochy_GenerateStims.m
% =========================================================================
%
% Generates .jpg images with grey background and black text printed in size
% 188 Courier New or BACS2serif font.
%
% Given a list words in English in an Excel file, this script outputs and
% saves .jpg images for each word. Images are currently set to be of
% dimension 680x680 pixels; this size can accomodate strings of lengths 1 -
% 5. Images are saved in a folder called "Images" and named
% 'W_[string].jpg', 'PF_[string].jpg' etc.
%
% How to use: 
%    (1) Prepare an Excel file with the stimulus strings. Column A must be 
%    named "Strings", and put one word on each row in Column A. You can 
%    have multiple sheets.
%    (2) Run the script and follow the prompts in the Command Window.
%
% !! Must have Courier New and BACS2serif installed on your computer as
% True Type Fonts (.ttf)!! 
%
% =========================================================================

clear all; close all;

%% Check for BACS2

systemFonts = listfonts;
message = ['BACS2 does not appear in the list of available system fonts!', ...
           '\nCheck to see if you have BACS2serif installed on your computer before you run the script.',...
           '\n\t- Must be installed as a True Type Font (.tff)',...
           '\n\t- Must be installed under "Computer", not "User"\n'];

if (~any(strcmp(systemFonts, 'BACS2'))) % if BACS2 not installed
    warning off backtrace
    warning(sprintf(message)); % display warning message
    
    while 1 % present option to bypass warning or quit script
        bypass = input('Enter 1 to continue running the script, and 2 to quit the script: ' , 's');
        if strcmp(bypass, '1')
            warning(sprintf('The script will continue, but you may encounter an error later on.'));
            break;
        elseif strcmp(bypass, '2')
            fprintf('\n*** Script terminated by user. ***\n');
            return;
        else
            disp('Only 1 or 2 is allowed, try again.')
        end
    end   
end


%% Create directory for generated images

[projPath, ~, ~] = fileparts(mfilename('fullpath'));

imagePath = fullfile(projPath, 'Images');

if (~exist('Images', 'dir'))
    mkdir(imagePath);
end


%% Get info from Excel file

% select and read excel file
disp(' '); disp('ACTION: Please select your Excel file.');
excelFile = uigetfile('*.xlsx');

% get sheet number
while true
    currentSheet = input('ACTION: Enter the Excel Sheet number: ');
    
    if isnumeric(currentSheet) % if user entered a number
       break;
    else
       disp('Must be a number, try again.');
    end
end

% read Excel file
stimParameters = readtable(excelFile, 'Sheet', currentSheet);

% Words or PFs
while true
    type = input('ACTION: Enter 0 for Courier New and 1 for BACS2serif: ');

    if (type == 0 || type == 1)
       break;
    else
       disp('Only a 0 or 1 is allowed, try again.');
    end
end

while true
    typeString = input('ACTION: Enter the condition name (W, PF, OLN, OIN, etc): ', 's');

    if ~(isempty(typeString))
       break;
    else
       disp('Must have a name, please try again.');
    end
end

%% Image dimensions

% Adjust image dimensions here!
nRows	= 680; 
nCols	= 680;


%% Make Images
% using insertText function

% put words into cell array
words = cellstr(transpose(splitlines(lower(string(stimParameters.Strings)))));
[~, nmbWords] = size( words );

% set grey background
imgBackground = uint8( zeros( nRows, nCols, 1, 1)) + 128; 

disp(' '); disp('Creating images...');

for iWord = 1:nmbWords % for each word
    
    currentWord     = words{iWord};
    currentFullFile = strcat(imagePath, '/', typeString, '_', currentWord, '.jpg');
    
    % In Matlab version < 8.6 'insertText() does not have 'Font' parameter, FontSize <= 72
    % Starting with version 8.6, 'insertText() takes 'Font' parameter, 'FontSize' <= 200
    % Some version numbers: 8.2 (R2013b), 8.6 (R2015b), 9.3 (R2017b)
    if verLessThan('matlab', '8.6')
        xypos = [ 10 100];
        tmpImg = uint8( insertText( imgBackground, xypos, currentWord, 'FontSize', 70, 'TextColor', 'black', 'BoxOpacity', 0.0));
        disp('There might be an issue with generating images. You will need Matlab version 8.6 or higher.');
    else
        xypos = [ nCols/2 nRows/2 ]; % anchor point (center)
        if type == 0 % type is W  
            tmpImg = insertText( imgBackground, xypos, currentWord, 'Font', 'Courier New', 'FontSize', 188, 'TextColor', 'black', 'BoxOpacity', 0.0, 'AnchorPoint', 'Center');
        else % type is PF  
            tmpImg = insertText( imgBackground, xypos, currentWord, 'Font', 'BACS2serif', 'FontSize', 188, 'TextColor', 'black', 'BoxOpacity', 0.0, 'AnchorPoint', 'Center');
        end
    end

	currentImage = uint8( tmpImg(:,:, 1));
    
    % write to .jpg and save
    imwrite(currentImage, currentFullFile, 'jpg'); 

	figure(1);
	imshow( currentImage, 'InitialMagnification', 200); % show image
	
end
   
disp(' ');
disp(['*** Complete! You have generated ', num2str(nmbWords), ' new image files. ***']);

