clc;
close all;
clear all;

%% Parametros
r0 = 1.2;
s0 = 0.2;
K = 100;
n = 10;
c = 5;
d1 = 0.4;
d2 = 0.2;
b = 0.0125;
theta1 = 3;
theta2 = 3;
theta3 = 3;
theta4 = 3;
p = 0.1;
q0 = 0.05;
e = 0.001;
cx = 1;
cy = 1;
cz = 1;
G1 = 0.01;
G2 = 0.01;
G3 = 0.01;

P = [r0 s0 K n c d1 d2 b theta1 theta2 theta3 theta4 p q0 e cx cy cz G1 G2 G3];

%% Condiciones iniciales:
x1 = 15;
x2 = 9;
x3 = 6;
x4 = 0.01;
x5 = 0.01;
x6 = 0.01;

x0 = [x1 x2 x3 x4 x5 x6];

% Definir intervalo de tiempo
tspan = [0 10000];

%% Impulso
num_impulses = 30;      % Número de impulsos
impulse_interval = 200; % Intervalo entre impulsos

t_impulses = (1:num_impulses) * impulse_interval; % Tiempos de los impulsos

impulse_strength = 10;  % Incremento en la tercera variable durante cada impulso

% Opciones para el solver
options = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);

%% Simulación con impulsos
current_state = x0; % Estado inicial
current_time = tspan(1); % Tiempo inicial

t_combined = []; % Tiempo acumulado
Y_combined = []; % Soluciones acumuladas

for i = 1:num_impulses
    % Tiempo final para este intervalo
    t_end = t_impulses(i);
    
    % Integrar hasta el próximo impulso
    [t_temp, Y_temp] = ode45(@(t, Y) vivi(t, Y, P), [current_time t_end], current_state, options);
    
    % Actualizar las soluciones combinadas
    t_combined = [t_combined; t_temp];
    Y_combined = [Y_combined; Y_temp];
    
    % Aplicar el impulso en la tercera variable
    current_state = Y_temp(end, :);
    current_state(3) = current_state(3) + impulse_strength;
    
    % Actualizar el tiempo actual
    current_time = t_end;
end

% Integrar después del último impulso hasta el tiempo final
if current_time < tspan(2)
    [t_temp, Y_temp] = ode45(@(t, Y) vivi(t, Y, P), [current_time tspan(2)], current_state, options);
    t_combined = [t_combined; t_temp];
    Y_combined = [Y_combined; Y_temp];
end

% Gráfica 
figure;
plot(t_combined, Y_combined(:, 1), '-b', 'LineWidth', 2, 'DisplayName', 'Native prey'); % Línea azul más gruesa
hold on;
plot(t_combined, Y_combined(:, 2), '-g', 'LineWidth', 2, 'DisplayName', 'Native predator'); % Línea verde más gruesa
plot(t_combined, Y_combined(:, 3), '-r', 'LineWidth', 2, 'DisplayName', 'Exotic predator'); % Línea roja más gruesa
legend;
xlim([0, 8000]);
ylim([0, 60]);
xlabel('Tiempo');
ylabel('Density');
set(gca, 'FontSize', 20);


