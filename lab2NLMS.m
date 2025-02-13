[dry_signal, fs] = audioread('dry2.wav');  % Dry signal (clean guitar)
[echo_signal, ~] = audioread('wet2.wav');  % Echo signal (noisy guitar with echo)

dry_signal = mean(dry_signal, 2);  
echo_signal = mean(echo_signal, 2);

mu = 0.1;
filter_order = 50;
epsilon = 1e-6;

n_samples = length(echo_signal);
weights = zeros(1, filter_order);
filtered_signal = zeros(n_samples, 1);
error_signal = zeros(n_samples, 1);

for n = filter_order+1:n_samples
    x = echo_signal(n-filter_order:n-1);
    y = sum(weights .* x.');
    error = dry_signal(n) - y;
    
    norm_factor = sum(x.^2) + epsilon;

    weights = weights + (2 * mu * error * x.') / norm_factor;  

    filtered_signal(n) = y;
    error_signal(n) = error;
end

output_filename = 'filtered2_nlms.wav';
audiowrite(output_filename, filtered_signal, fs);

disp(['Filtered signal saved to ', output_filename]);

figure;

subplot(4,1,1);
plot((1:n_samples)/fs, dry_signal, 'b', 'LineWidth', 1.5);
title('Desired Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4,1,2);
plot((1:n_samples)/fs, echo_signal, 'b', 'LineWidth', 1.5);
hold on;
plot((1:n_samples)/fs, filtered_signal, 'r', 'LineWidth', 1.5);
legend('Echo Signal', 'Filtered Signal (NLMS)');
title('Echo Signal and NLMS Filtered Signal. 𝛍:0.01, Filter order:50');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4,1,3);
plot((1:n_samples)/fs, error_signal, 'g', 'LineWidth', 1.5);
title('Error Signal');
xlabel('Time (s)');
ylabel('Error');

subplot(4,1,4);
plot((1:10000)/fs, error_signal(1:10000), 'g', 'LineWidth', 1.5);
title('Error Signal - First 10,000 Samples');
xlabel('Time (s)');
ylabel('Error');
