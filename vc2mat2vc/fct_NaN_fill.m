function [H0, U0, V0, W0] = fct_NaN_fill(H0, U0, V0, W0)
% fill in-mask nans ===================================================== %
% Apply inpaint_nans

    method = 3;
    h0 = H0;
    u0 = U0;
    v0 = V0;
    w0 = W0;
    
    % Apply inpaint_nans
    h0 = fct_inpaint_NaNs(double(h0),method);
    u0 = fct_inpaint_NaNs(double(u0),method);
    v0 = fct_inpaint_NaNs(double(v0),method);
    w0 = fct_inpaint_NaNs(double(w0),method);
    
    % check for existing NaN values
    
    while sum(sum(isnan(u0))) ~= 0
        %disp('remaining nans --> reapply inpaint_nans')
        h0 = fct_inpaint_NaNs(double(h0),method);
        u0 = fct_inpaint_NaNs(double(u0),method);
        v0 = fct_inpaint_NaNs(double(v0),method);
        w0 = fct_inpaint_NaNs(double(w0),method);
    end
    
    %disp('no remaining nans')
    
    H0 = h0;
    U0 = u0;
    V0 = v0;
    W0 = w0;
    
end

