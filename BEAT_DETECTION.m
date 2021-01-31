%DEFAULT SETTINGS
for c=0:0
%https://it.mathworks.com/videos/determining-signal-similarities-97063.html
close all;
clear;
clc;
printAudio=true;
printAutoCorr=false;
printCorr=true;
soundOn=true;
end

% DECLARATIONS
for c=0:0
%SIGNALS
imposed_length=10; %seconds
[y, fs]=audioread('Groove1.wav');
y=y(1:imposed_length*fs,:);
y=0.5.*(y(:,1)+y(:,2));
t=0:1/fs:(length(y)-1)/fs;
threshold=max(y)-0.3; %dynamic range for onset detection

%AUTO-CORRELATION (parametri da twiccare all'uso)
lowestBPM=75;
longestMETER=7;
lag=round(60/lowestBPM*longestMETER,0); 
time_precision=60/lowestBPM/8;       %unwanted peaks
end

%ONSET DETECTOR
for c=0:0
%ABSOLUTE VALUE OF INPUT
yMod=abs(y);
%GATED INPUT
yGated=yMod;
yGated(yMod<threshold)=0;
%CLIPPED INPUT
yClipped=yGated;
yClipped(yGated>threshold)=1;
end

%AUTO-CORRELATION 
for c=0:0
[autocor,lags] = xcorr(yGated,lag*fs);

if printAutoCorr
    figure()
    findpeaks(autocor,lags/fs,'MinPeakProminence',0.5,'MinPeakDistance',time_precision)
    xlabel('Autocorrelation (s)')
    ylabel('Autocorrelation')
end

[valPeaks,locPeaks]=findpeaks(autocor,lags/fs,'MinPeakProminence',0.5,'MinPeakDistance',time_precision);
normal=max(valPeaks);
noise_level=min(valPeaks);
ascendingOrder=sort(valPeaks);
noise_floor=noise_level+(normal/50);   %unwanted peaks
detection_thresholdLong=ascendingOrder(length(ascendingOrder)-3);    %long period detection threshold
detection_thresholdShort=ascendingOrder(5);
prominance=mean(autocor);
if prominance < 1
    prominance = prominance*10;
end

end

%DETECTING PEAKS OF AUTO-CORRELATION
for c=0:0
%LONG PERIOD
if printCorr
    figure()
    findpeaks(autocor,lags/fs,'MinPeakHeight',detection_thresholdLong,'MinPeakProminence',prominance,'MinPeakDistance',time_precision)
    xlabel('LongPeriod (s)')
    ylabel('Autocorrelation - Peaks For Long Period Estimation')
end

[valPeaksLong,locPeaksLong]=findpeaks(autocor,lags/fs,'MinPeakHeight',detection_thresholdLong,'MinPeakProminence',prominance,'MinPeakDistance',time_precision);
LL=length(locPeaksLong);
LLPointer=((LL+1)/2)+1;
longLenght=locPeaksLong(LLPointer);


%SHORT PERIOD
if printCorr
    figure()
    findpeaks(autocor,lags/fs,'MinPeakHeight',detection_thresholdShort,'MinPeakProminence',prominance,'MinPeakDistance',time_precision)
    xlabel('ShortPeriod (s)')
    ylabel('Autocorrelation - Peaks For Short Period Estimation')
end

[valPeaksShort,locPeaksShort]=findpeaks(autocor,lags/fs,'MinPeakHeight',detection_thresholdShort,'MinPeakProminence',prominance,'MinPeakDistance',time_precision);
LS=length(locPeaksShort);
LSPointer=((LS+1)/2)+1;
shortLenght=locPeaksShort(LSPointer);

end

%METRIC ESTIMATION
for c=0:0
subdivision_wrong=longLenght/shortLenght;
subdivision=round(subdivision_wrong,0);

bpm_hypothesis=60/(longLenght/subdivision);
    while (bpm_hypothesis>=lowestBPM*2)
        bpm_hypothesis=bpm_hypothesis/2;
    end
    while (bpm_hypothesis<lowestBPM)
        bpm_hypothesis=bpm_hypothesis*2;
    end
    
a=subdivision/3;
out=floor(a);
remainder=a-out;

if remainder==0
    integer=true;
else
    integer=false;
end

%disp(integer);
if integer==0
    meter=subdivision;
    %bpm=bpm_hypothesis;
    bpm=round(bpm_hypothesis,1);
    disp('Binary Subdivision');
else
    bpmNOW=round(bpm_hypothesis/3*2,1);
    outB=floor(bpmNOW);
    remainderB=bpmNOW-outB;
    if remainderB==0
        bpm=bpmNOW;
        meter=subdivision/3*2;
        disp('Ternary Subdivision');
    else
        bpm=round(bpm_hypothesis,1);
        meter=3;
        disp('Binary Subdivision');
    end
    
    %bpm=bpm_hypothesis/3*2;
   
end

while (bpm>=lowestBPM*2)
        bpm=bpm/2;
end
while (bpm<lowestBPM)
        bpm=bpm*2;
end
    
while (meter>=8)
        meter=meter/2;
end
while (meter<=2)
        meter=meter*2;
end

disp('bpm is:');
disp(bpm);
disp('meter is:');
disp(meter);
end

%METRONOME
for c=0:0
[yvalPeaks,ylocPeaks]=findpeaks(yGated,t,'MinPeakDistance',time_precision);

%bpm=bpmSUM/2;
clickPeriod=60/bpm;
offset=ylocPeaks(1);
metroFreq=440;
metroPeriod=1/metroFreq;
duration=0.1;
tLocal=0:1/fs:duration-(1/fs);
dLocal=0:1/metroFreq:duration;
x = tripuls(tLocal,metroPeriod*2,-1);
signal=pulstran(tLocal,dLocal,x,fs);
metroSound=(signal*4)-1;
clickFreq=1/clickPeriod;
d = 0+offset:1/clickFreq:imposed_length;   
metro = pulstran(t,d,metroSound,fs);
metro=metro';
end


%PLOTTING AUDIO
for c=0:0
if printAudio
    figure();
    plot(t,y, t,metro/10); grid; title('Test track');
    xlabel('Time (s)')
    ylabel('Waveform')
end


mix=y+(metro/10);
if soundOn
    soundsc(mix,fs);
end

end

