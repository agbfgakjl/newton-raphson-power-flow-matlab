%% START_HERE
% One-click entry point for the Newton-Raphson power-flow project.

projectRoot = fileparts(mfilename('fullpath'));
cd(projectRoot);
addpath(projectRoot);
addpath(fullfile(projectRoot, 'scripts'));
rehash;

fprintf('Project root: %s\n', projectRoot);
fprintf('MATLAB release: %s\n', version('-release'));

inputFile = fullfile(projectRoot, 'data', 'ieee14_power_flow_data.xlsx');
results = run_power_flow(inputFile); %#ok<NASGU>
