% script runs offline ep inference for the sparse spatio-temporal
% structured model on the EEG data (to reproduce the results from the
% paper)
diary on;

root_path = '../';
src_path = [root_path, 'src/offline/'];
addpath(genpath(src_path));

load([root_path, 'data/eeg/data_4_event.mat']);

[N] = size(X, 2);
[K, T] = size(y);

sigma2_beta = 400000;
sigma2 = 0.001;
epseps = 0.0001;
eta = 0.9;
eta_multiplier = 0.8;
scalar_for_mu0 = 3;
mu0 = scalar_for_mu0 * ones(N, 1);
s1 = 0.1; 
s2 = 0.001;
p = (norm(max(grid) - min(grid)))^2;
a1 = 0.01;
a2 = 0.05;

jitter = 1e-9;

% use multiple dimensional data. N - is the number of points * 3
% dimensions. Distance between N(i) is based on distance between points,
% i.e. i -> (x_k, y_k, z_k); j -> (x_l, y_l, z_l) and dist(i, j) =
% dist((x_k, y_k, z_k), (x_l, y_l, z_l))
W=zeros(N,N);
for i=1:N
    for j=1:N
        distance = get_distance_between_points(i, j, grid);
        W(i,j) = a1 * exp(-(distance)/(2*s1^2 * p)); % 1 * ... 
    end
end

W = (W + W')/2;
W = W + jitter * eye(size(W));

Sigma = zeros(N, N);
for i=1:N
    for j=1:N
        distance = get_distance_between_points(i, j, grid);
        Sigma(i,j) = a2*exp(-distance/(2*s2^2 * p)); % 10 * ...
    end
end

Sigma = (Sigma + Sigma') / 2;
Sigma = Sigma + jitter * eye(size(Sigma));


max_iter_num = 10000;

available_beta = false;
available_omega = false;
eta_alls = zeros(1, max_iter_num);

run_checks = false;

results = ep_func(Sigma, W, N, T, X, y, ...
             run_checks, sigma2_beta, K, sigma2, epseps, eta, eta_multiplier, ...
             available_omega, available_beta, eta_alls, max_iter_num, []);

results_path = [root_path, 'results/offline/eeg/'];
mkdir(results_path)
save([results_path, 'results.mat'], 'results', '-v7.3');

disp('finish!')
