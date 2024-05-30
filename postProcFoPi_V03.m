%postProcFoPi, used with fopi_plane6+!
% developed for fopi_plane_5.m, and define_pitLUT

% same result, as postProc _v01, but much faster.
% this is only the sampling at F0 multiplies part, but
% still missing the unwarping of ... part.
%----------------howTo:-------------------
% 1. run fopi decomposition, with freqRes = 1 (init shifting formants by 1Hz)
%     scan formant candidates till 3000Hz 
% 2. run  pitLUT = define_pitLUT(Nfft, Fs, minF0, maxF0);
% 3. run this post Proc routine to "smooth" the sampling over formant axis
% 4
%-----------------------------------------
clear fopiProc
clear coordPlane
clear coordPlane2

% fopi ... original unwarped FoPi plane
fopiProc = zeros(200,300); %...processed, warped plane

coordPlane1 = zeros(200,300);
coordPlane2 = zeros(200,300);
fopi_warp_LUT = zeros(200,300); % the LUT to see where do the original fopi smple belong to in the new plane

numHarmonicPassed = 0;  % in every freq axis we pass the first, sec harmonics at diff times.
  % offset = 1;
% thi is going go the the spepsize of the X axis (scanning the formants in Hz)
  binDist1 =pitLUT(1)       % this leads to minF0 resolution of X axis
  %binDist1 = 10/freqPerBin % this leads to 10 Hz resolution
% ----------------- loop of freq lines -------------
for i=1:200
  % tilting the fopi plane
  % offset =(112-i)/1.9;
  % offset =1; % NOT ook, there is always offset!!
  % first stepping through columns, ie. pitch lag.
  binDist =pitLUT(i);  % dist between harmonic components in 4096fft at 22kHz sampling
  offset =0; %binDist/3;
  
  % this is going to be the new reference x-scale:
  %formantAxis = (1:30:3000);
  
  if ((i>85) && (i<95)), 
    disp (["i=", num2str(i), " binDist=", num2str(binDist)]);
    end; 
    
  
  numHarmonicPassed=1;
  % ------------ loop of the Formant positions -----------
  prevNewXcoor = 0;
  for j=1:300
   
   % we will step 10 freq bins in the original fopiGram, ie.10x5.38 Hz.
   newXcoor = floor(j/10)+1;
    
   if j< 100, 
    xCoord1 = round(j*binDist+offset);
    end;
   xCoord2 = round(numHarmonicPassed*binDist/binDist1+offset);
    
   if j< 100,
    coordPlane1(i,j)=xCoord1;  
    end;  
    coordPlane2(i,j)=xCoord2; 
    fopi_warp_LUT(i,j) = numHarmonicPassed;
    %fopi_warp_LUT(i,j) = xCoord2;
    
    %jj=1;
    %while jj<40
      %coordCand = j*10; % bin nr. stepsize of Formant axis
      %xCoord = round(numHarmonicPassed*binDist+offset);
      %xCoord = max(1, xCoord);
      %coordPlane(i,j)=xCoord;
   %if (prevNewXcoor!=newXcoor),
    % fopiProc(i,newXcoor)=fopi_plane(i, xCoord2);   
    %end;  
      if (j<xCoord2),
          % we step till j reaches the NEXT harmonic at a given pitch line
      else%if (j<xCoord2),
          numHarmonicPassed = numHarmonicPassed+1; % get the next harmonic position at given pitch line
        end;
     % j++;     
      end %of j
  end % of i
  
  % ---------------- unWarp the plane ------------------------
  
  %fopProc = fopi_plane(fopi_warp_LUT);
  for i=1:200
    for j=1:300
    fopiProc(i,j) = fopi_plane(i,fopi_warp_LUT(i,j));
    end
    end
  
  %-----------------------------------------
  % disp Fopi before and after processing
  figure(282)
  
  subplot (211)
  imagesc(fopi_plane(:, (1:80)))
  colorbar
  title ("Raw FoPi")
  xlabel (["formantFreq / ", num2str(round(minF0), 3), "[Hz]"])
  ylabel (["f0-", num2str(minF0), "[Hz]"])
  
  subplot (212)
  imagesc(fopiProc(:, (1:80))); colorbar
  title ("Postprocessed FoPi")
  xlabel (["formantFreq / ", num2str(round(minF0), 3), "[Hz]"])
  ylabel (["f0-", num2str(minF0), "[Hz]"])
  
  
  % ---------- disp CoordPlanes ----------
  
  if 0 
  
  figure 283
  clf;
  subplot (311)
  imagesc(coordPlane1)
  title("coordPlane1")
  colorbar
  
 subplot (312)
  imagesc(coordPlane2)
  title("coordPlane2")
  colorbar
 subplot(313) 
  imagesc(fopi_warp_LUT)
  title("fopi_warp_LUT")
  colorbar
  
  end; % if 0
  
  
  
  

