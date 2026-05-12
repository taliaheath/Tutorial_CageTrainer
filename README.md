# Cage Trainer Data Analysis Tutorial

A hands-on tutorial for lab members. The goal is to take raw JSON trial files exported from the cage trainer (time-delay task) and end up with a fitted psychometric function — PSE (bias) and threshold (sensitivity).

## What you will learn

1. How the cage trainer stores trial data (one JSON file per trial).
2. How to combine many JSON files into one clean CSV.
3. How to build a signed stimulus axis from `direction` + `dr_InitialTargetDuration`.
4. How to aggregate trials, fit a logistic regression psychometric curve, and extract PSE and threshold.

## Folder layout

```
Toturial_CageTrainer/
├── data/                                 # raw JSON trial files (one per trial)
├── exported_data/                        # combined CSV will be written here
├── figures/                              # analysis figures will be saved here
├── Step1_DataLoading.m                   # combine JSON → CSV
├── Step2_PsychometricAnalysis.m          # CSV → psychometric function
├── VisPsychometricFunction.m             # FILL-IN TEMPLATE (you write the code)
└── README.md                             # this file
```

The example data in `data/` is one full session from `Monkey Porthos` on `2026-04-01`.

## How to run the tutorial

1. Open MATLAB and `cd` into the `Tutorial_CageTrainer` folder (or right-click the folder in MATLAB and choose "Add to Path > Selected Folders").
2. Run `Step1_DataLoading.m`. It will read every `.json` in `data/`, fill missing fields with `NaN`, stack everything into one table, and write `exported_data/all_trials_2026-04-01.csv`.
3. Open `VisPsychometricFunction.m` and complete the four numbered TODO sections (see the next subsection).
4. Run `Step2_PsychometricAnalysis.m`. It loads the CSV, find out the relavant parameters from the data, calls *your* `VisPsychometricFunction` by passing the parameters to fit and plot, and saves the figure under `figures/`.

You should end up with a figure that looks like a smooth S-curve plus dots whose sizes scale with trial count, and console output that reports the fitted **PSE** and **threshold**.

## The fill-in exercise: (1)`Step2_PsychometricAnalysis.m.m` (2)`VisPsychometricFunction.m`


## Key concepts

- **Stimulus magnitude**: `dr_InitialTargetDuration` — the requested delay (ms) between Target1 onset and Target2 onset.
- **Direction**: `direction` in the JSON — `0` means Target1 appeared on the LEFT (left-first), `1` means RIGHT (right-first). We turn this into a sign (`-1` / `+1`) so we can combine it with magnitude into one signed axis.
- **Response**: `"left"` or `"right"`. The psychometric function plots **P(right | signed delay)**.
- **PSE** (Point of Subjective Equality): the signed delay at which the subject chooses "right" 50% of the time. PSE ≈ 0 means no bias.
- **Threshold**: s of the logistic curve — how steep the curve is. Smaller s = sharper discrimination.

## How to use this tutorial with an AI coding assistant

Each `.m` file contains two kinds of comments:

- **GUIDELINE** — explains *why* the step exists. Read these first.
- **AI PROMPT** — a ready-to-copy prompt you can paste into Claude / Copilot / ChatGPT if you get stuck on a step. Try writing the code yourself first; only fall back to the prompt if you're stuck for more than ~10 minutes.


