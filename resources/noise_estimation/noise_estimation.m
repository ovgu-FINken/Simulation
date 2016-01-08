%script to estimate the magnitude of the noise from the
%velocity/acceleration sensor

%needs: data array with evenly sampled values 
%               x,y,z-acceleration, pitch, roll, yaw-rate
%sampling rate should be as high as possible, the motor controller operates
%at 100Hz (?), so we can expect oscillations of up to ~50Hz (?) to be real
%measurements and not noise (lower than controller operating rate due to
%inertia) the cutoff frequency should then be slightly higher than the
%highest frequency expected to be measured (so ~55Hz?). However, the
%highest sampling frequency available (when saving to SD card) is 100Hz.
%This means the Nyquist frequency is too low for us to be able to
%meaningfully detect the noise amplitude.

%ADD CODE HERE TO LOAD/PREPROCESS DATA
data = [];
time = [];

%set this correctly
sampling_rate = 100; %in Hz
%set this as desired
cutoff_frequency = 30; %in Hz

Ws = cutoff_frequency/sampling_rate * 2; %convert to be usable by cheby2()
%design filter:
%parameters: filter order, stopband attenuation, cutoff frequency
%(calculated above), filter type
[b, a] = cheby2(10, 100, Ws, 'high');
%subtract the mean, to minimize artifacts from filtering
noise = filter(b, a, data - repmat(mean(data), length(data)));
%plot the filtered data (i.e. the noise)
plot(time, noise);
%display the standard deviations
std(noise)




