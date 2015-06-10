%% Init Si4
si4 = Si4();
si4.windowOffset = 150;

%%
sigma_n = 1;
sigma_x = 3; %10 * sigma_n;
theta = deg2rad(37);
N = 1000; % measured signal (y) length is samples

si4.sigma_n = sigma_n;

% Lag in samples.
tau = round(signal_lag(si4.r_rec, theta) * si4.fs / si4.v);

% Generate source signal.
j = 1 - max(tau) : N - min(tau);
% x = normrnd(0, sigma_x, 1, length(j));
%x = sigma_x * sin(2 * pi * j / 20).';
x = zeros(1, length(j));
x(abs(j - N / 2) < 5) = 1;
x = x * (sigma_x / sqrt(sum(x.^2) / N));

% Generate output signal.
K = length(tau);
y = zeros(K, N);
for k = 1 : K
    y(k, :) = x(max(tau) - tau(k) + (1 : N)) + normrnd(0, sigma_n, 1, N);
end

subplot(2, 2, 1);
plot(x.'); grid('on');

subplot(2, 2, 3);
plot(y.'); grid('on');

%% Load data from a file
[y, fs] = read_data('data/raw/ak-47-left-100m'); 
y = y(:, 100000 : 140000);
si4.sigma_n = 0.01;

subplot(2, 2, 3);
plot(y.'); grid('on');

%% Calculate result

% profile on;
logL = si4.LogL(y);
%logL = log_lik_mex(y, int16(si4.tau), sigma_n);
% profile off;

% subplot(2, 2, 2);
% plot(si4.theta, logL); grid('on');

subplot(2, 2, 4);
imagesc((0 : size(logL, 2) - 1) * si4.windowOffset + 1, rad2deg(si4.theta), logL);
axis xy;

% profile viewer;

%% Animated polar plot.
make_video = true;

if make_video
    vw = VideoWriter('out.avi');
    vw.FrameRate = 10;
    vw.open();
end

subplot(2, 2, 4);
hold off;
for i = 1 : size(logL, 2)
    polar(si4.theta.', exp(logL(:, i)));
    drawnow();
    if make_video
        vw.writeVideo(getframe(gca()));
    end
end

if make_video
    vw.close();
end