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
mag        = psymat(:, 1);
dir_sign   = psymat(:, 2);
resp_right = psymat(:, 3);

signed_x = mag .* dir_sign;        % signed stimulus axis


%% ---- TO-DO 2. aggregate by unique signed_x: ----------------------------------
% Find all unique values of signed stimulus, then calculated how many rightward
% choices for each signed stimulus: p_right
[uniq_x, ~, idx] = unique(signed_x);   
p_right = accumarray(idx, resp_right==1, [], @mean);


%% ---- TO-DO 3. fit with Logistic Regression --------------------------------
%% p_choice = 1/(1+exp(-(b0+b1*signed_stimulus)))
% Get the b0 and b1 from the fitting
psy = table(signed_x(:), resp_right(:), ...
            'VariableNames', {'stimulus_dir','response'});
    fitted_psy = fitglm(psy, 'response ~ stimulus_dir', 'Distribution', 'binomial');
b0 = fitted_psy.Coefficients.Estimate(1);
b1 = fitted_psy.Coefficients.Estimate(2);

%% ---TO-DO 4. Calculate bias and threshold
% pse/bias = -b0 / b1;
% threshold =  1/b1;

pse = -b0 / b1;
threshold = 1/b1;

TotalTrials = size(psymat,1); %Get the number of total trials to show on the plot

%% ----TO-DO 5. visualize the psychometric function ----------------------------------------------------------
figure('Name', 'Psychometric Function', 'Color', 'w');
hold on; 

%========TO-DO==========================
% now you need to plot two things overlay on one figure

% (a) Proportion of rightward choices as a function of each signed stimulus 
% raw data points: each dots corresponding to one signed
% stimulus-proportion of righward choices

plot(uniq_x,p_right,'.r','MarkerSize',20); %Raw data


% (b) the fitted curve
xx = linspace(min(uniq_x), max(uniq_x), 100); % a series value from the minimum value of the signed_stimulus to the max, with 100 values in between
yy = 1./(1+exp(-(b0 + b1*xx)));      % fitted psy

hold on 
plot(xx, yy, 'r-', 'LineWidth', 2);  % fitted line

%(c) add reference lines at 0(x) and 0.5(y) 
plot([min(xx),max(xx)],[0.5,0.5],'--k');
plot([0,0],[0,1],'--k');

%(d) add xlabel and ylabel and other cosmetics
xlabel('Target Asychrony (ms)');
ylabel('Proportion of rightward choices)');
ylim([0 1]);
yticks([0,0.5,1]);
    
xlim([min(uniq_x)-10,max(uniq_x)+10]);
set(gca,'LineWidth',1,'FontSize',15);

%(e) add textbox to show pse and threshold, total trials on the plot
% get the range of current axis
 ax = gca;
 xlim_vals = ax.XLim;
 ylim_vals = ax.YLim;

 % setup the textbox location
 x_pos = xlim_vals(2) - 0.05*(xlim_vals(2)-xlim_vals(1));
 y_pos = ylim_vals(1) + 0.05*(ylim_vals(2)-ylim_vals(1));

 % add the text for bias and threshold
 text(x_pos, y_pos, sprintf('PSE = %.2f\nThreshold = %.2f\nN=%d', pse, threshold,TotalTrials), ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'FontSize', 12);



end
