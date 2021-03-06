function [Qr, Qr_joint] = update_r(Qh, Qh_joint, Qr, Qr_joint, Qu, Qu_joint, Sigma, min_var, max_var, eta, run_checks)

T = size(Qr, 2);

for t=1:T-1
    [Qr(t), Qr_joint] = update_r_single_timestamp(t, Qh(t), Qh_joint, Qr(t), Qr_joint, Qu(t), Qu(t+1), Qu_joint, Sigma, ...
        min_var, max_var, eta, T, run_checks);
end

[Qr(T), Qr_joint] = update_r_single_timestamp(T, Qh(T), Qh_joint, Qr(T), Qr_joint, Qu(T), [], Qu_joint, Sigma, ...
        min_var, max_var, eta, T, run_checks);