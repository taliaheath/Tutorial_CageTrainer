% =========================================================================
% STEP 1: DATA LOADING TUTORIAL — Cage Trainer (Time-Delay Task)
% =========================================================================
% Author: Xuefei Yu
% Purpose:
%   In this step you will learn how to:
%       (1) Locate raw JSON trial files exported from the cage trainer
%       (2) Read each JSON file and parse it into a MATLAB struct/table
%       (3) Handle empty/null fields gracefully
%       (4) Concatenate all single-trial entries into one master table
%       (5) Export the master table as a CSV ready for analysis
%
%   This file is a GUIDED TEMPLATE. Read each section, follow the
%   "GUIDELINE" comments to understand WHY, and use the "AI PROMPT"
%   comments to ask an AI assistant (Claude / Copilot) for help if
%   you get stuck.
%
% Folder layout expected (relative to this tutorial folder):
%   Toturial_CageTrainer/
%       ├── data/                <- raw JSON trial files (input)
%       ├── exported_data/       <- combined CSV will be saved here
%       ├── figures/             <- analysis figures go here (Step 2)
%       ├── Step1_DataLoading.m  <- this script
%       ├── Step2_PsychometricAnalysis.m
%       └── VisPsychometricFunction.m
% =========================================================================

clc; clear;

%% -----------------------------------------------------------------------
%  SECTION 0 — Set up paths
%  -----------------------------------------------------------------------
%  GUIDELINE:
%      Always parameterize your paths at the top of the script so the same
%      code works on any computer / any subject / any session.
%      Use fullfile() (NOT hard-coded slashes) so the script works on
%      Mac, Linux, and Windows.
%
%  AI PROMPT (if stuck):
%      "Write MATLAB code that builds an absolute path to a folder using
%       fullfile(), given a monkey name, a task type, and a date string."
% -----------------------------------------------------------------------

% --- tutorial-relative paths (do NOT need to edit if you keep the folder layout) ---
tutorial_root = fileparts(mfilename('fullpath'));   % folder containing this script
data_folder    = fullfile(tutorial_root, 'data');           % JSON files live here
export_folder  = fullfile(tutorial_root, 'exported_data');  % CSV output goes here

% --- session metadata (edit these for your own session) ---
monkey      = 'Monkey Porthos';
task_type   = 'cage_training/timedelay';
data_date   = '2026-04-01';   % yyyy-mm-dd

% --- make sure the export folder exists ---
if ~exist(export_folder, 'dir')
    mkdir(export_folder);
end

% --- name of the output CSV ---
output_csv  = sprintf('all_trials_%s.csv', data_date);
output_file = fullfile(export_folder, output_csv);

fprintf('Reading JSON files from: %s\n', data_folder);
fprintf('Will write combined CSV to: %s\n', output_file);


%% -----------------------------------------------------------------------
%  SECTION 1 — List every JSON file in the data folder
%  -----------------------------------------------------------------------
%  GUIDELINE:
%      Each behavioral trial is saved as one JSON file with a unix-time
%      stamp in the filename. We want every "*.json" in the data folder.
%      ALWAYS check that the folder isn't empty before continuing — a
%      silent empty result is the #1 source of "why is my plot blank?"
%      bugs.
%
%  AI PROMPT (if stuck):
%      "In MATLAB, how do I get a list of every .json file in a folder,
%       and stop the script with an informative error if none are found?"
% -----------------------------------------------------------------------

files = dir(fullfile(data_folder, '*.json'));

if isempty(files)
    error('No JSON files were found in %s. Check the data folder.', data_folder);
end
fprintf('Found %d JSON files.\n', length(files));


%% -----------------------------------------------------------------------
%  SECTION 2 — Read every JSON, flatten, and stack into one table
%  -----------------------------------------------------------------------
%  GUIDELINE:
%      • fileread() returns the raw text of the file.
%      • jsondecode() converts it into a MATLAB struct (or array of structs).
%      • Some fields can be empty ([]); empty values break struct2table
%        when other rows have a value for the same field. Replace [] with
%        NaN so every row has a consistent shape.
%      • Append the source filename as an extra column so you can trace
%        any row back to its origin if you need to debug.
%      • Some JSON files contain MORE THAN ONE trial — loop the inner
%        struct array, don't assume size==1.
%
%  AI PROMPT (if stuck):
%      "In MATLAB, how do I read a JSON file into a struct, 
%       replace empty fields with NaN, and convert it to a table? 
%       Then, how do I loop over multiple JSON files and concatenate the results into one big table?"
%   
% -----------------------------------------------------------------------

allData = table();        % master table that will grow row-by-row

for i = 1:length(files)
    filename = files(i).name;
    filepath = fullfile(data_folder, filename);

    % --- read & decode the JSON ---
    jsonText   = fileread(filepath);
    dataStruct = jsondecode(jsonText);   % struct array, 1 element per trial


    % --- usually, dataStruct is size 1x1, but sometimes (though rarely) it's 2+ when the file contains multiple trials ---
    for j = 1:size(dataStruct, 1)

        % Replace empty fields with NaN so struct2table doesn't choke.
        dataStruct(j) = structfun(@(x) fillEmptyWithNaN(x), ...
                                  dataStruct(j), ...
                                  'UniformOutput', false);

        % Warn if the file unexpectedly contains > 1 trial (rare but happens).
        if j > 1
            fprintf('Note: file %s contains more than one trial.\n', filename);
        end

        % Flatten the struct into a 1-row table.
        T = struct2table(dataStruct(j));

        % Provenance: which JSON did this row come from?
        T.trial_file = string(filename);

        % Force "response" to a string so MATLAB doesn't infer mixed types
        % later (e.g. 'left' vs 'right' as char vs string).
        T.response = string(T.response);

        % Append to the master table.
        allData = [allData; T];   %#ok<AGROW>  (small loop, OK)
    end
end

fprintf('Combined %d trials from %d files.\n', height(allData), length(files));


%% -----------------------------------------------------------------------
%  SECTION 3 — Quick sanity peek
%  -----------------------------------------------------------------------
%  GUIDELINE:
%      Before exporting, ALWAYS look at the first few rows. You're
%      checking that:
%          • Column names look right (no weird "Var1" placeholders)
%          • dr_InitialTargetDuration, direction, response are present
%          • response is "left"/"right" strings
%          • accuracy is 0/1
%
%  AI PROMPT (if stuck):
%      "Show me the first 5 rows of a MATLAB table and print its column
%       names."
% -----------------------------------------------------------------------

disp('--- First 5 rows of the combined table ---');
disp(head(allData, 5));
disp('--- Column names ---');
disp(allData.Properties.VariableNames');


%% -----------------------------------------------------------------------
%  SECTION 4 — Save the master table as CSV
%  -----------------------------------------------------------------------
%  GUIDELINE:
%      Use writetable(). CSV is the lingua franca of analysis — Step 2
%      will load this exact file.
%      Print the absolute path so you can copy-paste it to open in
%      Excel / Python / etc.
%
%  AI PROMPT (if stuck):
%      "How do I write a MATLAB table to a CSV file and print confirmation?"
% -----------------------------------------------------------------------

writetable(allData, output_file);
fprintf('Saved combined CSV to:\n   %s\n', output_file);


%% -----------------------------------------------------------------------
%  Helper: replace [] with NaN inside structfun
%  -----------------------------------------------------------------------
function y = fillEmptyWithNaN(x)
    if isempty(x)
        y = NaN;
    else
        y = x;
    end
end
