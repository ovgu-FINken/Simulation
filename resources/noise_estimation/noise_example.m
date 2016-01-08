%this is the code where the noise estimation was done for the "original"
%velocity log data. This file is only for reference, as the data is not
%usable, because the sampling rate is too small

% load csv file
newData1 = importdata('copter_log.csv');
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end

%get actual values for the time
times = textdata(2:end, 1);
times = sprintf('%s*', times{:});
times = sscanf(times, '%f*');

%separate the data into the different flights
[jumpValues, jumpIndices] = sort(diff(times), 'descend');

%there are 3 jumps
time_a = times(1:jumpIndices(3));
data_a = data(1:jumpIndices(3), :);

time_b = times(jumpIndices(3)+1:jumpIndices(2));
data_b = data(jumpIndices(3)+1:jumpIndices(2), :);

time_c = times(jumpIndices(2)+1:jumpIndices(1));
data_c = data(jumpIndices(2)+1:jumpIndices(1), :);

time_d = times(jumpIndices(1)+1:end);
data_d = data(jumpIndices(1)+1:end, :);

%we resample with 100Hz
re_time_a = time_a(1):0.01:time_a(end);
re_time_b = time_b(1):0.01:time_b(end);
re_time_c = time_c(1):0.01:time_c(end);
re_time_d = time_d(1):0.01:time_d(end);

%resample data, so that it can be filtered and stuff
re_data_a = interp1q(time_a, data_a, re_time_a');
re_data_b = interp1q(time_b, data_b, re_time_b');
re_data_c = interp1q(time_c, data_c, re_time_c');
re_data_d = interp1q(time_d, data_d, re_time_d');

%using high pass chebyshev II 
%cutoff frequency should be slightly higher than the highest frequency 
%that the system can create: motor controller operates at 100 Hz
[b, a] = cheby2(9, 100, 0.3, 'high');
aznoise = filter(b, a, re_data_a - repmat(mean(re_data_a), length(re_data_a), 1));
plot(re_time_a, aznoise)



