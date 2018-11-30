function [Vfilt] = filter_speed(T,x_raw,y_raw) 

%% apply a different Gaussian smoothing to tracking data 
    %make a gaussian filter
         sigma = 50; %half a second at 100Hz sampling rate; based on Kemere et al. Frank2013
         size = 600; %6s window size; based on Kemere et al. Frank2013
   % sigma = 12;     % sd for Gaussian, 120ms based on Chen et al. Mehta2011 mouse freely moving gamma paper    
    %size = 200;     % window size for Gaussian
    pos = linspace(-size / 2, size / 2, size);
    gaussFilter = exp(-pos .^ 2 / (2 * sigma ^ 2));
    gaussFilter = gaussFilter / sum (gaussFilter);
    
    %create padding to reduce edge effects
    startpadX = x_raw(1).*ones(size,1);
    endpadX = x_raw(end).*ones(size,1);
    Xextended = [startpadX; x_raw; endpadX];
    %apply Gaussian filter to padded data
    Xfilt = conv(Xextended, gaussFilter, 'same');
    %remove padding
    ind = true(length(Xextended),1);
    ind(1:size)=0;
    ind(end-size+1:end)=0;
    Xfilt = Xfilt(ind); 
    
    startpadY = y_raw(1).*ones(size,1);
    endpadY = y_raw(end).*ones(size,1);
    Yextended = [startpadY;y_raw;endpadY];
    Yfilt = conv(Yextended, gaussFilter, 'same');
    Yfilt = Yfilt(ind);  %remove padding  
    

     Vfilt = sqrt(diff(Xfilt).^2 + diff(Yfilt).^2)./diff(T);  
    Vfilt = [Vfilt;Vfilt(end)]; %copy last point to keep nr of pnts same