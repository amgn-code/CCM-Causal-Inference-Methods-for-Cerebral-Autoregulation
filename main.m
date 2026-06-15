%% Generate Test Signals
fs = 4;
t = (0:1/fs:300)';

x = sin(2*pi*0.05*t) + 0.5*sin(2*pi*0.13*t);

e = 3;
tau = 4;  % 1 second delay at fs = 4 Hz

[mx, timeIndices] = buildDelayEmbedding(x, e, tau);

%% Plot Embedding

figure()
plot3(mx(:,1), mx(:,2), mx(:,3), '.')
xlabel('x(t)')
ylabel('x(t - tau)')
zlabel('x(t - 2tau)')
title('Delay Embedding of x')
grid on

%% 