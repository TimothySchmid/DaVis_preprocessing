function [U0, V0, W0] = fct_outlier_detection(U0, V0, W0, EXP)
    % outlier detection ================================================= %
    % After Westerweel & Scarano 2005
    
    threshmed = EXP.outlier.threshmed;  % threshold value for detection
    eps       = EXP.outlier.eps;        % estimated measurement noise level
    b         = EXP.outlier.neighbour;  % neighborhood radius: 1 = 3x3, 2 = 5x5 etc.
        
    % assign variables
    u0 = U0;
    v0 = V0;
    w0 = W0;
    
    [nx,ny] = size(u0);
    
        normfluct = zeros(nx,ny,3);     % normalised fluctuation
        
        for c = 1:3
            if c ==1
                dispcomp = u0;
            elseif c==2
                dispcomp = v0;
            else
                dispcomp = w0;
            end

            for iy = 1+b:1:ny-b
                for ix = 1+b:1:nx-b
                    neigh     = dispcomp(ix-b:ix+b,iy-b:iy+b); % get neigbours
                    neighcol  = neigh(:);                      % in column
                    neighcol2 =[neighcol(1:(2*b+1)*b+b); ...   % exclude center-point
                                neighcol((2*b+1)*b+b+2:end)];  % from neighborhood
                            
                    med   = median(neighcol2);      % get median from neighborhood
                    res   = neighcol2 - med;        % get residuals
                    fluct = dispcomp(ix,iy) - med;  % fluctuations
                    
                    medianres = median(abs(res));   % abs. median of residuals
                    
                    normfluct(ix,iy,c) = abs(fluct/(medianres+eps)); % normalised fluctuation
                end
            end
        end

        % logical mask for outliers
        info = (sqrt(normfluct(:,:,1).^2 + ...
                     normfluct(:,:,2).^2 + ...
                     normfluct(:,:,3).^2) > threshmed);
        
        % set outliers to NaN
        u0(info==1) = NaN;
        v0(info==1) = NaN;
        w0(info==1) = NaN;
       
        U0 = u0;
        V0 = v0;
        W0 = w0;
        
    % outlier detection ================================================= %
end

