function [H0, U0, V0, W0] = fct_NaN_detection(H0, U0, V0, W0)
    % NaN detection ===================================================== %
    % Prepare data for inpaint_nans
    
    h0 = H0;
    u0 = U0;
    v0 = V0;
    w0 = W0;
    
    % Set zero points inside hull to NaN
    h0(h0==0) = NaN;
    u0(h0==0) = NaN;
    v0(h0==0) = NaN;
    w0(h0==0) = NaN;
    
    H0 = h0;
    U0 = u0;
    V0 = v0;
    W0 = w0;
    
end

