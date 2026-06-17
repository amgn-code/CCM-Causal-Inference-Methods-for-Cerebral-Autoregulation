%% Clean Start

clearvars, clc, close all

project_root = pwd;
addpath(genpath(project_root));
rehash

%% Generate Test Signals
%
% For Testing Purposes Only
%
% fs = 4;
% t = (0:1/fs:300)';
%
% x = sin(2*pi*0.05*t) + 0.5*sin(2*pi*0.13*t);
% y = 0.8*x + 0.2*sin(2*pi*0.02*t);
%
% y = zeros(size(x));
%
% for i = 2:length(x)
%    y(i) = 0.8*y(i-1) + 0.4*x(i-1);
% end
%
% n  = length(x);

%% Load Data From Excel

signalData = createShoMisoSignal();

map = signalData.bp;
co2 = signalData.co2;
cbv = signalData.cbf;
fs = signalData.fs;
t = signalData.t;

n  = length(map);

%% User Editable Parameters
e = 3;
tau = 4;  

% Dependent Parameter
firstEmbeddingIndex = 1 +(e-1) * tau;

%% Find Embeddings

M_map = findEmbedding(map, firstEmbeddingIndex, tau, e);
M_co2 = findEmbedding(co2, firstEmbeddingIndex, tau, e);
M_cbv = findEmbedding(cbv, firstEmbeddingIndex, tau, e);

%% Plot Embedding Manifolds

figure()
subplot(1,3,1)
plotDelayEmbedding(M_map, 'MAP')

subplot(1,3,2)
plotDelayEmbedding(M_co2, 'CO2')

subplot(1,3,3)
plotDelayEmbedding(M_cbv, 'CBV')

%% User editable experimental parameters

maxEmbeddingSize = n - firstEmbeddingIndex + 1;
EmbeddingSizes = [50 75 100 150 200 300 450 600 800 1000 maxEmbeddingSize];
numTrials = 3;

%% Run Pairwise CCM

cmResults = struct();
ccmResults.EmbeddingSizes = EmbeddingSizes;

ccmResults.M_CBV_estimates_MAP = runCCMPair( ...
    M_cbv, map, e, tau, firstEmbeddingIndex, EmbeddingSizes, numTrials, ...
    'M_{CBV} estimates MAP');

ccmResults.M_CBV_estimates_CO2 = runCCMPair( ...
    M_cbv, co2, e, tau, firstEmbeddingIndex, EmbeddingSizes, numTrials, ...
    'M_{CBV} estimates CO2');

ccmResults.M_MAP_estimates_CBV = runCCMPair( ...
    M_map, cbv, e, tau, firstEmbeddingIndex, EmbeddingSizes, numTrials, ...
    'M_{MAP} estimates CBV');

ccmResults.M_CO2_estimates_CBV = runCCMPair( ...
    M_co2, cbv, e, tau, firstEmbeddingIndex, EmbeddingSizes, numTrials, ...
    'M_{CO2} estimates CBV');

ccmResults.M_MAP_estimates_CO2 = runCCMPair( ...
    M_map, co2, e, tau, firstEmbeddingIndex, EmbeddingSizes, numTrials, ...
    'M_{MAP} estimates CO2');

ccmResults.M_CO2_estimates_MAP = runCCMPair( ...
    M_co2, map, e, tau, firstEmbeddingIndex, EmbeddingSizes, numTrials, ...
    'M_{CO2} estimates MAP');


%% Plot Pairwise CCM Convergence

figure()

subplot(1,3,1)
plotCCMConvergencePair( ...
    ccmResults.M_CBV_estimates_MAP, ...
    ccmResults.M_MAP_estimates_CBV, ...
    ccmResults.EmbeddingSizes, ...
    'MAP ↔ CBV')

subplot(1,3,2)
plotCCMConvergencePair( ...
    ccmResults.M_CBV_estimates_CO2, ...
    ccmResults.M_CO2_estimates_CBV, ...
    ccmResults.EmbeddingSizes, ...
    'CO2 ↔ CBV')

subplot(1,3,3)
plotCCMConvergencePair( ...
    ccmResults.M_MAP_estimates_CO2, ...
    ccmResults.M_CO2_estimates_MAP, ...
    ccmResults.EmbeddingSizes, ...
    'MAP ↔ CO2')

%% Diagnostic Plots at Largest Library Size

selectedL = ccmResults.EmbeddingSizes(end);

figure()
plotCCMDiagnostic( ...
    ccmResults.M_CBV_estimates_MAP, ...
    map, t, 'MAP', ccmResults.EmbeddingSizes, selectedL)

figure()
plotCCMDiagnostic( ...
    ccmResults.M_CBV_estimates_CO2, ...
    co2, t, 'CO2', ccmResults.EmbeddingSizes, selectedL)

%% Notes

%{
Panel A: MAP ↔ CBFV convergence curves
Panel B: CO2 ↔ CBFV convergence curves
Panel C: MAP ↔ CO2 convergence curves
Panel D: summary heatmap of max-L rho or convergence slope
%}