%% preprocess_videotracking


function preprocess_videotracking(filebase,colorvec,trackcoord,savematfile)

% convert .tsp file to .whl file. Requires the .meta file
% then upsamples data to desired frequency (20 or 1 kHz)

% INPUT:
% 'fbasename': the file base names ('fbasename.tsp', etc.)
% 'colorvec': a 2 value vector [colFront colRear] which defines which
% color from [R G B] is the front and rear LEDs. Default: [1 3]
% savematfile, default = 1


whl10k = AlignTsp2Whl(filebase,colorvec,trackcoord);

%% the upsampling part

% load "standard" 40Hz file
a=load([filebase  '.whl']);

% upsample file to 20 kHz

for i=1:size(a,2)

whl20k(:,i)=resample(a(:,i),512,1);


end

clear a i

if savematfile
    save('whl10k_test', 'whl10k', '-v7.3');   %saves tracking data in same folder with identifying info.
    save('whl20k_test', 'whl20k', '-v7.3');   %saves tracking data in same folder with identifying info.
end
end