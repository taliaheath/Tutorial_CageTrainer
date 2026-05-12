function [pse, threshold] = VisPsychometricFunction_Solution(psymat)
% =========================================================================
% VisPsychometricFunction_Solution — REFERENCE SOLUTION
% =========================================================================
% Complete working version of VisPsychometricFunction.m.
% Use this only AFTER attempting the fill-in template on your own.
%
% To run Step2_PsychometricAnalysis.m with this solution instead of the
% template, either:
%   (a) Rename this file to VisPsychometricFunction.m (back up the
%       template first), OR
%   (b) Open Step2_PsychometricAnalysis.m and replace the call
%             VisPsychometricFunction(psymat)
%       with  VisPsychometricFunction_Solution(psymat).
% =========================================================================
% INPUT
%   psymat : N-by-3 matrix
%       column 1: stimulus magnitude (delay in ms; non-negative)
%       column 2: direction sign     (-1 = left-first, +1 = right-first)
%       column 3: response           ( 0 = chose left,  1 = chose right)
%
% OUTPUT
%   pse        : Point of Subjective Equality (where the proportion of rightward choices is 0.5).
%   threshold  : sigma of the cumulative Gaussian (sensitivity).
% =========================================================================

%% ---- TO-DO: 1. unpack & build signed stimulus asychronmy: ---------------------------
% Unpack the psymat to get the magnitude, direction, binary responses back
% Then construct the signed_stimulus by element_wise multiplication between
% maglitude and signed_direction
% 


%% ---- TO-DO 2. aggregate by unique signed_x: ----------------------------------
% Find all unique values of signed stimulus, then calculated how many rightward
% choices for each signed stimulus: p_right



%% ---- TO-DO 3. fit with Logistic Regression --------------------------------
%% p_choice = 1/(1+exp(-(b0+b1*signed_stimulus)))
% Get the b0 and b1 from the fitting



%% ---TO-DO 4. Calculate bias and threshold
% pse/bias = -b0 / b1;
% threshold =  1/b1;


TotalTrials = size(psymat,1); %Get the number of total trials to show on the plot

%% ----TO-DO 5. visualize the psychometric function ----------------------------------------------------------
figure('Name', 'Psychometric Function', 'Color', 'w');
hold on; 

%========TO-DO==========================
% now you need to plot two things overlay on one figure

% (a) Proportion of rightward choices as a function of each signed stimulus 
% raw data points: each dots corresponding to one signed
% stimulus-proportion of righward choices




% (b) the fitted curve


%Plot the fitted curve


%(c) add reference lines at 0(x) and 0.5(y) 



%(d) add xlabel and ylabel and other cosmetics


%(e) add textbox to show pse and threshold, total trials on the plot
% get the range of current axis
 


 

end
