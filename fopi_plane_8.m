% -------------------------------------------------------------
%                       FoPi demo
% Formant-Pitch Decomposition, Formant-Pitch Plane
% -------------------------------------------------------------
% Fo-Pi plane = weighted sum of Pitch candidate vectors, 
%    Formant-position based selection of pitch candidates.
%
% F1 = <100; 1000Hz>;
% F2 = <1000, 2500Hz>

% May 5: first version of unwarping to compensate the effect of pitch synchronous formant sampling
% F0min set to 50, fopi_width calculated till ...
% -------------------------------------------------------------
% here run "rec_waves_01" to record S1 and S2
disp ('----------- May 09--------------')
% -------------------------------------------------------------
% 	Load Data
% -------------------------------------------------------------
% loading example waves, also present on https://github.com/m-r-n > wavesurfing.
%load "eioua_mrn.wav"
%freqStep = 8.5

Fs = 22050
Nfft = 4096
freqPerBin = Fs/Nfft

% MALE
% si1=wavread("eioua_mrn.wav");
si1=audioread("eioua_mrn.wav");

%FEMALE
si2=audioread("aeiou_anyag_1.wav");


%------------- O -------------------
%vowel ="O"
%startInd=30130; %"i"   25.000-35.000
%segLen=1850
%freqStep = 17.2;       % 16 bins step corresponds to apps.86Ht freq shift, 

%------------- E -------------------
if 0
vowel ="E"
startInd=5100; %"e"     5.000-..
segLen=1900
freqStep = 17.00;       % 16 bins step corresponds to apps.86Ht freq shift, 


%------------- I -------------------
vowel ="I"
startInd=25850; %"x"     40.000-...
segLen=1850
freqStep = 17.13;       % 16 bins step corresponds to apps.86Ht freq shift, 

%------------- U -------------------
vowel ="U"
startInd=50050; %"x"     40.000-...
segLen=1850
freqStep = 17.13;       % 16 bins step corresponds to apps.86Ht freq shift, 
end
%------------- A -------------------
%vowel ="A"
%startInd=62050; %"x"     40.000-...
%segLen=1850
%freqStep = 17.13;       % 16 bins step corresponds to apps.86Ht freq shift, 

%========= cut & process =========
vowel1 ="E" % male
vowel2 ="-" % female


segLen=1850

startInd1=63000    %MALE: E:5000, I: 25850,      40.000-...
startInd2 =25850

endInd1=startInd1+segLen-1
endInd2=startInd2+segLen-1


ss1=si1(startInd1:endInd1);
ss2=si2(startInd2:endInd2);

%ss= ss1+ss2;
ss=ss2;

sound(si1(startInd1:startInd1+Fs), Fs); % we have to play a sec or so to be recognizable
sound(si2(startInd2:startInd2+Fs), Fs); % we have to play a sec or so to be recognizable

figure (100); clf
subplot(211); plot(ss2)
title(["vowel1 ", vowel1])

noHarmonics = 5;  % number of harmonix used for reindexing
maxFormFr = 5500 % in Hz
minF0 = 50
maxF0 = 249

noFormCandid = ceil(maxFormFr/freqPerBin) % number of formant candidates.

% which is exactly F0!!!, otherwice the space would be warped.

% ================== Reindexing LUTs=================
howMuchToMirror = Nfft/2  % ... mert a harmonikusok +/- tükrözest kapnak

  shiftBy =2

    % --- reindexing LUT preparaion ---
    pitchAxis= minF0:maxF0;
    pitchAxis = pitchAxis/freqPerBin;
    %pitchAxis(pitchAxis<1)=1;
    pitAxis1 = -2 *pitchAxis + howMuchToMirror +shiftBy;
    pitAxis2 = -1 *pitchAxis + howMuchToMirror +shiftBy;
    pitAxis3 =  0 *pitchAxis + howMuchToMirror +shiftBy;
    pitAxis4 =  1 *pitchAxis + howMuchToMirror +shiftBy;
    pitAxis5 =  2 *pitchAxis + howMuchToMirror +shiftBy;


    pitAxis1n = -1.5 *pitchAxis + howMuchToMirror +shiftBy;
    pitAxis2n = -0.5 *pitchAxis + howMuchToMirror +shiftBy;
    pitAxis3n =  0.5 *pitchAxis + howMuchToMirror +shiftBy;
    pitAxis4n =  1.5 *pitchAxis + howMuchToMirror +shiftBy;

    if 0
    % plot the scanning curves
    figure 102; clf; 
    hold on
    xlabel(["f0-", num2str(minF0), "[Hz]"])
    ylabel("corresponding spectral bin index")
    title(["freqPerBin: ", num2str(freqPerBin)]);
    grid
    plot(pitAxis1, 'r')
    plot(pitAxis2, 'g')
    plot(pitAxis3, 'c')
    plot(pitAxis4, 'k')
    plot(pitAxis5, 'b')

    plot(pitAxis1n, 'r-.')
    plot(pitAxis2n, 'g-.')
    plot(pitAxis3n, 'c-.')
    plot(pitAxis4n, 'k-.')
    %plot(pitAxis5n, 'r-.')
  end % if 0
%=================== FoPi plane =================

% initialize the weighting curves
%formant_weighting;

fopi_plane = zeros (200, noFormCandid);
%spec_plane = zeros (400, noFormCandid);
% --- spectrum of a frame --- 
spOrig = 0.0001+ abs(fft(ss.*hamming(segLen), Nfft));
spZ=20*log (spOrig);

freqStep80 = round(80*Nfft/Fs)
%mirroting part of the spectrum, by reusing the last few 100 samples.
howMuchToMirror = Nfft/2  % azert 3, mert 5 harmonikust hasznalunk
%howMuchToMirror = 325; % must be fixed
spZ1=[spZ((4096-howMuchToMirror):4096);spZ];

    figure (100)
    subplot(212); hold on
    % plotting till 4000Hz, minF0 = 50Hz, therefore xWidth FoPi is 80, 
    % therefore to Disp the Spectrum till 4kHz, ...
    % >> 4000Hz/freqPerBin = 743.04
    plot(spZ1(1:743),'r');grid
    xlabel(["freq.bin index, Nfft=", num2str(Nfft    )])
    title (["logSpectr, Hz/Bin: ", num2str(freqPerBin )])

    
     pitLUT = define_pitLUT(Nfft, Fs, minF0, maxF0);
    
for i=1:85 
 
    %spec_plane (:, i) = spZ1(1:400);
    
    freqStepV = pitLUT';

    
pitAxis1 = pitAxis1+freqStepV;
pitAxis2 = pitAxis2+freqStepV;
pitAxis3 = pitAxis3+freqStepV;
pitAxis4 = pitAxis4+freqStepV;
pitAxis5 = pitAxis5+freqStepV;

pitAxis1n = pitAxis1n+freqStepV;
pitAxis2n = pitAxis2n+freqStepV;
pitAxis3n = pitAxis3n+freqStepV;
pitAxis4n = pitAxis4n+freqStepV;
%pitAxis5n = pitAxis5n+freqStepV;

if (i==0)
figure 10
    clf; 
    hold on
    xlabel(["f0-", num2str(minF0), "[Hz]"])
    ylabel("corresponding spectral bin index")
    title(["freqPerBin: ", num2str(freqPerBin)]);
    grid
    plot(pitAxis1, 'r')
    plot(pitAxis2, 'g')
    plot(pitAxis3, 'c')
    plot(pitAxis4, 'k')
    plot(pitAxis5, 'r')

    plot(pitAxis1n, 'r-.')
    plot(pitAxis2n, 'g-.')
    plot(pitAxis3n, 'c-.')
    plot(pitAxis4n, 'k-.')
%    plot(pitAxis5n, 'r-.')
%plot_fopi_lut;
end;

    % positive Spectral components
    reindSpec1 = spZ1(round(pitAxis1));
    reindSpec2 = spZ1(round(pitAxis2));
    reindSpec3 = spZ1(round(pitAxis3));
    reindSpec4 = spZ1(round(pitAxis4));
    reindSpec5 = spZ1(round(pitAxis5));

    % negative Spectral components
    reindSpec1n = spZ1(round(pitAxis1n));
    reindSpec2n = spZ1(round(pitAxis2n));
    reindSpec3n = spZ1(round(pitAxis3n));
    reindSpec4n = spZ1(round(pitAxis4n));



    % ---- fast Reindexing ----
    sumReindPlus = reindSpec1 + 1.5* reindSpec2 + 2*reindSpec3 + 1.5* reindSpec4 + reindSpec5;
    %sumReindPlus = sumReindPlus +  reindSpec6 + reindSpec7 + reindSpec8 + reindSpec9 + reindSpec10;
    
    sumReindMinus = reindSpec1n + reindSpec2n + reindSpec3n + reindSpec4n;
    %sumReindMinus = sumReindMinus + reindSpec6n + reindSpec7n + reindSpec8n + reindSpec9n + reindSpec10n;
    
    sumReind = sumReindPlus - sumReindMinus/3;
    
    
    fopi_plane (:, i) = (sumReind);
    %Check Planes of the LUT.
    %fopi_plane (:, i) = (reindSpec4);
    
    %fopi_plane (:, i) = (reindSpec1+reindSpec2+reindSpec3 -reindSpec1n/2 -reindSpec2n/2);
    
end % formant Loop

fopi_plane(fopi_plane<-300)=-300;

figure (300)
clf;
imagesc(fopi_plane(:, 1:100))
%title(['FormantWidth=', num2str(5), "harmonics, freqPerBin: ", num2str(freqPerBin, 3), "Hz/bin"])

freqStep = pitchAxis(1); % the first line is the result of sampling the spectrum at this stepSize 
pitchVal = freqPerBin*freqStep
title(["Fo=", num2str(round(pitchVal)), "Hz, vowels: male-", vowel1, " female-", vowel2])
xlabel (["formantFreq / ", num2str(round(pitchVal), 3), "[Hz]"])
ylabel (["f0-", num2str(minF0), "[Hz]"])
colorbar
%figure 301
%clf;
%imagesc(spec_plane)
%colorbar;
%title(["freqPerBin: ", num2str(freqPerBin), "Hz/bin"])
%xlabel (["f0-", num2str(minF0), "[Hz]"])

% ---- plot  results ----
 
if 0
    figure 101; clf;
    subplot(211);     hold on; 
    plot(reindSpec1,'r')
    plot(reindSpec2,'b')
    plot(reindSpec3,'c')
    plot(reindSpec4,'k')
    plot(reindSpec5,'r')

    plot(reindSpec1n,'r-.')
    plot(reindSpec2n,'b-.')
    plot(reindSpec3n,'c-.')
    plot(reindSpec4n,'k-.')
    plot(reindSpec5n,'r-.')
    grid on;
    xlabel(["f0-", num2str(minF0), "[Hz]"])
    ylabel("lo-spectral enery")

    figure 101; 
    subplot(212); hold on
    title(["Reind +/-(red/black) an final (blue)freqPerBin: ", num2str(freqPerBin)]);
    xlabel (["f0-", num2str(minF0), "[Hz]"])
    plot(sumReindPlus, 'r')
    plot(sumReindMinus, 'k')
    plot(sumReind, 'b')
    grid
end;


postProcFoPi_V03