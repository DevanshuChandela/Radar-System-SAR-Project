clc; clear;

%% --- Load and Process DEM ---
filename = 'olympex_ASO_USWA_OL_20140904_f1a1_mcc_bareDEM_3p0m_despiked.tif';
DEM_raw = double(imread(filename));
DEM_raw(DEM_raw < 0) = NaN;

% Extract center 128x128 region
[Nrows, Ncols] = size(DEM_raw);
center_row = round(Nrows / 2);
center_col = round(Ncols / 2);
half_size = 64;
DEM = DEM_raw(center_row-half_size+1:center_row+half_size, ...
              center_col-half_size+1:center_col+half_size);
DEM(isnan(DEM)) = 0;
DEM = DEM / max(DEM(:)) * 300;  % Scale to [0, 300] m

%% --- Radar Parameters ---
c = 3e8;
fc = 10e9;
lambda = c / fc;
B = 20e6;
T_p = 1e-5;
PRI = 1e-4;
Fs = 2 * B;
K = B / T_p;
v = 150;
h = 5000;

%% --- Time and Grid Setup ---
t_range = -T_p/2 : 1/Fs : T_p/2 - 1/Fs;
n_samples = length(t_range);
n_pulses = 256;
t_slow = (0:n_pulses-1) * PRI;

dx = 3; dy = 3;
[x_idx, y_idx] = meshgrid(1:128, 1:128);
x_target_grid = (x_idx - 64) * dx;
y_target_grid = (y_idx - 64) * dy;
z_target_grid = DEM;

%% --- Transmit Chirp ---
tx_window = hamming(n_samples).';
s_tx = exp(1j * pi * K * t_range.^2) .* tx_window;

%% --- Environmental Conditions ---
conditions = {'Fog', 'Rain', 'Snow'};
alphas_dB = [0.007, 0.03, 0.015]* 10;  % dB/km
alphas_dB = alphas_dB * 5;         % exaggerate for visibility
alphas_np = log10(exp(1)) * alphas_dB / 10;

max_magnitude_global = -inf;
sar_images = cell(3,1);

%% --- SAR Simulation Loop ---
for cond = 1:3
    alpha = alphas_np(cond);
    disp(['Simulating: ' conditions{cond} ' (α = ' num2str(alphas_dB(cond)) ' dB/km)']);
    s_rx = zeros(n_pulses, n_samples);

    for n = 1:n_pulses
        t = t_slow(n);
        x_radar = v * t;
        y_radar = 0;
        echo_sum = zeros(1, n_samples);

        for ix = 1:128
            for iy = 1:128
                x_t = x_target_grid(iy, ix);
                y_t = y_target_grid(iy, ix);
                z_t = z_target_grid(iy, ix);

                R = sqrt((x_t - x_radar)^2 + (y_t - y_radar)^2 + (h - z_t)^2);
                tau = 2 * R / c;
                attenuation = exp(-alpha * 2 * R / 1000);  % 2-way attenuation

                delayed = exp(1j * pi * K * (t_range - tau).^2);
                phase = exp(-1j * 4 * pi * fc * R / c);
                echo = delayed .* phase * attenuation;

                echo_sum = echo_sum + echo;
            end
        end

        s_rx(n, :) = echo_sum;
    end

    %% --- Compression ---
    s_range = conv2(s_rx, conj(fliplr(s_tx)), 'same');
    ref_idx = round(n_samples / 2);
    s_focused = conv2(s_range, conj(flipud(s_range(:, ref_idx))), 'same');

    % Track max
    current_max = max(abs(s_focused(:)));
    if current_max > max_magnitude_global
        max_magnitude_global = current_max;
    end

    sar_images{cond} = s_focused;
end

%% --- Plot All Images with Zero-Padding in Cross-Range ---
range_axis = ((0:n_samples-1) - n_samples/2) / Fs * c / 2;
pad_size = 128;  % padding in slow-time (vertical) direction

for cond = 1:3
    s_focused = sar_images{cond};

    % Pad with zeros vertically
    s_padded = padarray(s_focused, [pad_size 0], 0, 'both');

    % Updated cross-range axis
    n_padded = size(s_padded, 1);
    cross_range_axis = ((0:n_padded-1) - n_padded/2) * v * PRI;

    % Normalize and plot
    image_dB = 20 * log10(abs(s_padded) / max_magnitude_global);

    figure;
    imagesc(range_axis, cross_range_axis, image_dB);
    xlabel('Range (m)'); ylabel('Cross-Range (m)');
    title(['SAR Stripmap with ' conditions{cond} ' Attenuation (Padded View)']);
    colormap(jet); colorbar;
    caxis([-40 0]); axis tight;
end
