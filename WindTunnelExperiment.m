clc; clearvars; close all;

%% 1. Givens
t = 0.12;           % thickness ratio
k = 0.76;           % body shape factor
chord = 0.152;      % m
span = 0.457;       % m
height = 0.457;     % m
x_ref = 0.25;       % Moment reference point (25% chord)

%% 2. Data Importing
% Ensure the filename matches your actual file. Use .xlsx or .csv as needed.
filename = 'cleanDataGroup30.xlsx'; 

% Read the entire block starting from the coordinates row (Row 4)
% We use 'Range','A4' to preserve the column structure (1 to 42)
raw = readmatrix(filename, 'Range', 'A4');

% Extract Coordinates from the first row of the 'raw' matrix
x_u = raw(1, 5:16);   % x/c locations (Upper)
x_l = raw(1, 18:28);  % x/c locations (Lower)
y_w = raw(1, 30:42);  % Wake Pitot positions (mm)

% Extract Data (starts from row 7 in Excel, which is index 4 in our 'raw' matrix)
data  = raw(4:end, :);
aoa   = data(:, 1);
p_inf = data(:, 2);
p_t   = data(:, 3);
p_s_u = data(:, 5:16);
p_s_l = data(:, 18:28);
p_t_w = data(:, 30:42);

%% 3. Data Preprocessing (Averaging 4-point groups)
% Using anonymous functions to average groups of 4 rows instantly
avg_vec = @(v) mean(reshape(v, 4, []), 1)'; 
avg_mat = @(m) squeeze(mean(reshape(m, 4, [], size(m, 2)), 1));

AOA_avg   = avg_vec(aoa);
p_inf_avg = avg_vec(p_inf);
p_t_avg   = avg_vec(p_t);
p_s_u_avg = avg_mat(p_s_u);
p_s_l_avg = avg_mat(p_s_l);
p_t_w_avg = avg_mat(p_t_w);

%% 4. Aerodynamic Calculations (Vectorized)
% q_inf (Dynamic Pressure)
q_inf_avg = p_t_avg - p_inf_avg;

% Pressure Coefficients (Cp)
c_p_u = (p_s_u_avg - p_inf_avg) ./ q_inf_avg;
c_p_l = (p_s_l_avg - p_inf_avg) ./ q_inf_avg;

% Integrated Coefficients (Normal, Lift, and Moment)
cn_u = trapz(x_u, c_p_u, 2);
cn_l = trapz(x_l, c_p_l, 2);
cn   = cn_l - cn_u;
cl   = cn .* cosd(AOA_avg);

cm_u = trapz(x_u, c_p_u .* (x_u - x_ref), 2);
cm_l = trapz(x_l, c_p_l .* (x_l - x_ref), 2);
cm   = cm_u - cm_l;

% Wake and Drag (Cd)
max_p_tw = max(p_t_w_avg, [], 2);
u_y   = sqrt((p_t_w_avg - p_inf_avg) ./ (max_p_tw - p_inf_avg));
c_p_w = (p_t_w_avg - p_inf_avg) ./ q_inf_avg;
cd    = trapz(y_w, u_y .* (1 - u_y), 2) * 2e-3 / chord;

%% 5. Boundary Corrections
sig = (pi^2 / 48) * (chord / height)^2;
epsilon_sb = k * 0.7 * t * chord^2 * span;
epsilon_wb = (chord / (2 * height)) .* cd;
epsilon = epsilon_wb + epsilon_sb;

cl_c = cl .* (1 - sig - 2 * epsilon);
cd_c = cd .* (1 - 3 * epsilon_sb - 2 * epsilon_wb);

%% 6. XFOIL Data
AOA_Xfoil = 0:0.5:15;
cl_xfoil = [0.000, 0.111, 0.207, 0.294, 0.361, 0.404, 0.449, 0.493, 0.535, 0.577, ...
            0.616, 0.654, 0.691, 0.728, 0.766, 0.804, 0.844, 0.884, 0.924, 0.962, ...
            0.991, 1.013, 1.033, 1.040, 1.016, 0.975, 0.695, 0.685, 0.686, 0.665, 0.685];
cm_xfoil = [0.0000, -0.0097, -0.0164, -0.0215, -0.0235, -0.0211, -0.0188, -0.0166, ...
            -0.0142, -0.0116, -0.0089, -0.0059, -0.0027, 0.0004, 0.0035, 0.0064, ...
            0.0089, 0.0111, 0.0135, 0.0157, 0.0186, 0.0224, 0.0255, 0.0290, ...
            0.0339, 0.0359, -0.0063, -0.0125, -0.0154, -0.0255, -0.0261];
cd_xfoil = [0.0130, 0.0128, 0.0125, 0.0122, 0.0120, 0.0120, 0.0121, 0.0125, ...
            0.0129, 0.0135, 0.0143, 0.0154, 0.0168, 0.0183, 0.0198, 0.0217, ...
            0.0239, 0.0260, 0.0287, 0.0315, 0.0366, 0.0399, 0.0434, 0.0486, ...
            0.0558, 0.0638, 0.1307, 0.1476, 0.1591, 0.1684, 0.1749];

%% 7. Plotting

% --- Pressure Coefficient Distributions ---
figure;
for n = 1:length(AOA_avg)
    subplot(2, 3, n); 
    plot(x_u, c_p_u(n, :), 'o-', 'DisplayName', 'Upper'); hold on;
    plot(x_l, c_p_l(n, :), 's-', 'DisplayName', 'Lower');
    set(gca, 'YDir', 'reverse');
    title(['AOA = ', num2str(AOA_avg(n), '%.2f'), '°']);
    grid on; legend('Location', 'best');
end
sgtitle('Pressure Coefficient Distributions');

% --- Wake Pressure Profiles ---
figure;
for n = 1:length(AOA_avg)
    subplot(2, 3, n);
    plot(y_w, c_p_w(n, :), 'LineWidth', 1.5);
    title(['Wake AOA ', num2str(AOA_avg(n), '%.1f')]);
    xlabel('y (mm)'); ylabel('C_{p,w}'); grid on;
end
sgtitle('Wake Pressure Coefficient Profiles');

% --- Coefficients vs Alpha ---
figure;
subplot(1,3,1);
plot(AOA_avg, cl, 'o-', 'DisplayName', 'Exp'); hold on;
plot(AOA_avg, cl_c, 's-', 'DisplayName', 'Corr');
plot(AOA_Xfoil, cl_xfoil, 'DisplayName', 'XFOIL');
xlabel('\alpha'); ylabel('C_l'); grid on; legend; title('Lift');

subplot(1,3,2);
plot(AOA_avg, cd, 'o-', 'DisplayName', 'Exp'); hold on;
plot(AOA_avg, cd_c, 's-', 'DisplayName', 'Corr');
plot(AOA_Xfoil, cd_xfoil, 'DisplayName', 'XFOIL');
xlabel('\alpha'); ylabel('C_d'); grid on; legend; title('Drag');

subplot(1,3,3);
plot(AOA_avg, cm, 'o-', 'DisplayName', 'Exp'); hold on;
plot(AOA_Xfoil, cm_xfoil, 'DisplayName', 'XFOIL');
xlabel('\alpha'); ylabel('C_m'); grid on; legend; title('Moment');

% --- Glide Ratio (L/D) vs Alpha ---
glide_ratio = cl ./ cd;
glide_ratio_c = cl_c ./ cd_c;
glide_ratio_xfoil = cl_xfoil' ./ cd_xfoil'; % Ensuring column orientation

figure;
plot(AOA_avg, glide_ratio, 'LineWidth', 1.5, 'DisplayName', 'L/D, Experimental');
hold on;
plot(AOA_Xfoil, glide_ratio_xfoil, 'LineWidth', 1.5, 'DisplayName', 'L/D, XFOIL');
plot(AOA_avg, glide_ratio_c, 'LineWidth', 1.5, 'DisplayName', 'L/D, Corrected');
xlabel('\alpha (Angle of Attack)');
ylabel('Glide Ratio, L/D');
title('Glide Ratio (L/D) vs. \alpha');
grid on;
legend('show', 'Location', 'best');