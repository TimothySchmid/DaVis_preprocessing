function [H0, U0, V0, W0, M0] = fct_outside_NaN(H0,U0,V0,W0,bhull)
% set out-mask values to NaN ============================================ %

    %define mask size
    M0 = zeros(size(H0));
    
    % set in-data field -1
    M0(bhull(1):bhull(2),bhull(3):bhull(4)) = -1;
    
    % add +1 so that in-data = 0 & out-data = 1
    M0 = M0 + 1;
    
    % set out-mask values to NaN
    H0(M0==1) = NaN;
    U0(M0==1) = NaN;
    V0(M0==1) = NaN;
    W0(M0==1) = NaN;
end

