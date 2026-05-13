% =========================================================================
% STEP 2: PSYCHOMETRIC FUNCTION ANALYSIS — Cage Trainer (Time-Delay Task)
% =========================================================================
% Author: Xuefei Yu
% Purpose:
%   Build and visualize a psychometric function from the combined CSV and extract two summary parameters:
%       • PSE       — Point of Subjective Equality (50% right-choice point)
%       • Threshold — discrimination sensitivity (slope of the curve)
%
%   Proposed steps:
%       (1) Loading the cleaned CSV
%       (2) Choosing the right stimulus and response variables
%       Inside a helper function
%       (3) Signing the stimulus by direction (left-first / right-first)
%       (4) Aggregating rightward responses into P(right) per stimulus condition
%       (5) Fit with logistic regression
%       (6) Plotting data + fit and reporting PSE / threshold
%
% ---- BACKGROUND: what is a psychometric function? ----------------------
% A psychometric function maps a physical stimulus dimension (here, the
% signed temporal delay between Target1 and Target2) to the proportion of
% "right" choices the subject makes.
%   • Horzontal axis       -> Onset Asynchrony (ms, signed by direction, eg, -200 to 200 in ms)  
%   •  Negative signed delay  -> Right target appeared later/Left target appeared first
%   • Positive signed delay  -> Right target appeared first/Left target appeared later
%   • Vertical axis         -> P(right) (proportion of trials where the subject chose the rightward target)
%   
%   
%
% Two standard fits:
%   • Cumulative Gaussian:   p = normcdf(x, mu, sigma)
%   • Logistic:              p = 1 ./ (1 + exp(-bx)

%
% Reported parameters:
%   • PSE       = mu          (stimulus value where p(right) = 0.5)
%   • Threshold = sigma (Gaussian) or sd (logistic) or others. 
% =========================================================================

close all; clear;


%% -----------------------------------------------------------------------
%  SECTION 0 — Paths
%  -----------------------------------------------------------------------
%  GUIDELINE:
%      Build paths from the script's location so the tutorial is portable.
%      The CSV is whatever Step1_DataLoading.m produced in exported_data/.
%
%  AI PROMPT (if stuck):
%      "How do I get the folder containing the current MATLAB script and
%       build a path to a sibling subfolder?"
% -----------------------------------------------------------------------

tutorial_root = fileparts(mfilename('fullpath'));
export_folder = fullfile(tutorial_root, 'exported_data');
figure_folder = fullfile(tutorial_root, 'figures');
if ~exist(figure_folder, 'dir'); mkdir(figure_folder); end

data_date = '2026-04-01';                          % match the date in Step 1 as this is the only file in the toturial
data_csv  = sprintf('all_trials_%s.csv', data_date);
data_path = fullfile(export_folder, data_csv);

if ~exist(data_path, 'file')
    error(['CSV not found: %s\n' ...
           'Run Step1_DataLoading.m first.'], data_path);
end

%Add the helper function into path
addpath(genpath(tutorial_root));

%% -----------------------------------------------------------------------
%  SECTION 1 — Load the combined CSV
%  -----------------------------------------------------------------------
%  GUIDELINE:
%      readtable() will infer column types. Always print head(data) and
%      check that:
%          • dr_InitialTargetDuration is numeric (the delay magnitude, ms)
%          • direction is logical/0-1 (Target1 side: 0=left, 1=right)
%          • response is "left"/"right" string
%          • accuracy is 0/1
%
%  AI PROMPT (if stuck):
%      "How do I load a CSV into MATLAB as a table and inspect the column
%       data types?"
% -----------------------------------------------------------------------

data = readtable(data_path);
fprintf('Loaded %d trials from %s\n', height(data), data_csv);
disp(head(data, 3));

% What parameters are related to the stimulus and response?

%{
%% -----------------------------------------------------------------------
%  SECTION 2 — (OPTIONAL) Quality check: requested vs. actual delay
%  -----------------------------------------------------------------------
%  GUIDELINE:
%      The cage trainer schedules a target delay (dr_InitialTargetDuration)
%      but the *measured* on-screen delay (dm_Target1ToTarget2) can drift
%      because of monitor refresh. Plot one against the other to confirm
%      the hardware is honest. If the points lie on the unity line, you
%      are safe to treat the requested value as the stimulus.
%
%  AI PROMPT (if stuck):
%      "Make a MATLAB scatter plot of two numeric vectors with a y=x
%       reference line, equal axes, and proper labels."
% -----------------------------------------------------------------------

do_quality_check = true;
if do_quality_check
    figure('Name', 'Requested vs Actual Delay');
    scatter(data.dr_InitialTargetDuration, data.dm_Target1ToTarget2, ...
            20, 'r', 'filled', 'MarkerFaceAlpha', 0.4);
    hold on;
    lo = 0;
    hi = max([data.dr_InitialTargetDuration; data.dm_Target1ToTarget2]) + 30;
    plot([lo hi], [lo hi], '--k');
    axis equal; xlim([lo hi]); ylim([lo hi]);
    xlabel('Requested delay (ms)');
    ylabel('Actual delay (ms)');
    title('Hardware timing check');
    saveas(gcf, fullfile(figure_folder, 'delay_check.png'));
end
%}

%% -----------------------------------------------------------------------
%% ------------------------------------------------------------------------
%  SECTION 3 (TO-DO)— Build the (stimulus_mag, direction_sign, response_right) matrix
%  -----------------------------------------------------------------------
%  GUIDELINE:
%  In this section, we need to build prepare the data for psychometric function:
%  |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
%  Step 1: Get the Onset Asychomy maglitude, direction, response from the data, where
%            * Onset Asychomy maglitude(dr_InitialTargetDuration): usually 0 to 200 in ms
%            * Direction(direction): left or right. 
%            * Response (response): left or right choice
%  =========TO-DO=======
stimulus_mag = data.dr_InitialTargetDuration;     % stimulus onset asychrony magnitude (ms)
direction =  data.direction;
response = data.response;

%  ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
%  Step 2: Drop invalid trials (e.g. unsucessfully finished? Time out/ Broke touching?) 
%  Remove all trials in which any NaNs contains in "stimulus_mag" or
%  "direction_sign" or "response_right"
%  AI PROMPT (if stuck):
%      "How could I remove the NaN values from a column?"

keep = ~isnan(stimulus_mag) & ~isnan(direction) & ...
       (data.response == "left" | data.response == "right");
stimulus_mag    = stimulus_mag(keep);
direction  = direction(keep);
response  = response(keep);

fprintf('Using %d valid trials for the psychometric fit.\n', sum(keep));

%  ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
%  Step 3: Change the (1) sign of the direction into -1(left-first) 1 (right-first)
%                     (2) response representation into 0(left) 1(right)
%  AI PROMPT (if stuck):
%      "I have a MATLAB table column 'response' with values 'left' and
%       'right'. How do I turn it into a logical vector that is true when
%       the response was 'right'?"
%
%  =========TO-DO=======
direction_sign            = direction;
direction_sign(direction_sign == 0) = -1;          % left-first => -1, right-first => +1

response_right = strcmp(response, 'right');        % 1 if chose right, 0 if otherwise


% Put them into a matrix for passing to the helper function for psychometric function 
psymat = [stimulus_mag, direction_sign, response_right];


%% -----------------------------------------------------------------------
%  SECTION 4(TO-DO) — Fit + visualize the psychometric function
%  -----------------------------------------------------------------------
%  GUIDELINE:
%      VisPsychometricFunction.m does four things:
%         (a) signs the stimulus axis: signed_stimulus = magnitude .* direction
%         (b) aggregates trials into proportion_right per signed_stimulus
%         (c) fits a Logistic Regression psychometric curve
%         (d) plots proportion of rightward choices as a function of signed_stimulus  + smooth fit, and
%             shows and returns PSE and threshold.
%
%      It returns:
%         pse        — stimulus value where p(right) = 0.5  (≈ bias)
%         threshold  — standard deviation of binomial distribution    (≈ sensitivity)
%
%  AI PROMPT (if stuck):
%      "How do I fit a cumulative Gaussian psychometric function in MATLAB
%       using fminsearch or fitnlm? What's the negative-log-likelihood
%       objective for binary responses?"
% -----------------------------------------------------------------------

% ==============TO-DO: Complete the VisPsychometricFunction=============

 
[pse, threshold] = VisPsychometricFunction_Solution(psymat);

fprintf('\n=========================================\n');
fprintf('  PSE       = %.2f ms  (bias)\n', pse);
fprintf('  Threshold = %.2f ms  (sensitivity, sigma)\n', threshold);
fprintf('=========================================\n');

% Save the current figure.
saveas(gcf, fullfile(figure_folder, sprintf('psychometric_%s.png', data_date)));


%% -----------------------------------------------------------------------
%  SECTION 5 — (HOMEWORK) Extensions to try
%  -----------------------------------------------------------------------
%  Once the baseline works, try these on your own:
%   1. Test the pipeline on other sessions in porthos or from other monkeys
%   2. Split the data by session block (early vs late trials) and refit
%      to see whether the animal's bias drifts within a session. Further,
%      plot the change of pse and threshold as a function of session
%      number.
%
%   3. Check how reaction time changes under each stimulus condition
%   4. Change the pipeline for batch analysis
%   5. Modify the script as an exercise for object-oriented programming
%   6. Try to implement the same thing in Python
% -----------------------------------------------------------------------
