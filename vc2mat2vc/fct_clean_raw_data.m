function [H0, U0, V0, W0] = fct_clean_raw_data(H0, U0, V0, W0, EXP, is_valid)
%UNTITLED Find wholes inside mask and replace them with zero; pre step for
% inpaint_nans. This sets only zero values INSIDE the mask to NaN, which
% drastically reduces computation time. Only after the use of inpaint_nans,
% all values outside the mask are set to NaN.

% input arguments is structure content from davis .vc7 files.
% input order:
% - Arg1 --> height_data
% - Arg2 --> Displacement x (U0)
% - Arg3 --> Displacement y (V0)
% - Arg4 --> Displacement z (W0)
% - Arg5 --> Mask data

% output order:
% - outArg1 --> height_data    (H)
% - outArg2 --> Displacement x (DX)
% - outArg3 --> Displacement y (DY)
% - outArg4 --> Displacement z (DZ)

 
    % outlier detection ================================================= %
    [U0, V0, W0] = fct_outlier_detection(U0, V0, W0, EXP);
    % =================================================================== %

    % NaN detection ===================================================== %
    [H0, U0, V0, W0] = fct_NaN_detection(H0, U0, V0, W0);
    % =================================================================== %
   
    % fill in-mask NaN values =========================================== %
    [H0, U0, V0, W0] = fct_NaN_fill(H0, U0, V0, W0, is_valid);
    % =================================================================== %
    
    % set out-mask values to NaN =========================================== %
    [H0, U0, V0, W0] = fct_outside_NaN(H0, U0, V0, W0, is_valid);
    % =================================================================== %
    
end

