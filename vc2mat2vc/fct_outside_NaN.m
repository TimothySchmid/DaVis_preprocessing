function [H0, U0, V0, W0] = fct_outside_NaN(H0, U0, V0, W0, is_valid)
% set out-mask values to NaN ============================================ %

    % set out-mask values to NaN
    H0(is_valid==0) = NaN;
    U0(is_valid==0) = NaN;
    V0(is_valid==0) = NaN;
    W0(is_valid==0) = NaN;
end

