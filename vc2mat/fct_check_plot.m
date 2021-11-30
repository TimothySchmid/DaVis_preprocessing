function fct_check_plot(EXP, H0, H, iRead)
%fct_check_plot --> show control plot to check interpolated data etc.
%   Detailed explanation goes here
  switch EXP.check_plot
      case 'yes'
          clf
          figure(1)
          
          subplot(1,2,1)
          pcolor(H0); shading interp; axis equal; colorbar
          title('raw data')
          axis tight
          
          subplot(1,2,2)
          pcolor(H); shading interp; axis equal; colorbar
          title('corrected data')
          axis tight
          sgtitle(['Time step: ', num2str(iRead)])
          drawnow
      case 'no'
      otherwise
  end
end

