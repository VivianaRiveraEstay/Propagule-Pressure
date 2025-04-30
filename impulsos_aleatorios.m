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
frec_propag = 5;     % Frecuencia del prpágulo
intervalo_introduccion = 200; % Intervalo entre impulsos
t_inicial = 100;

tiempo_impulsos = t_inicial + (0:frec_propag) * intervalo_introduccion; % Tiempos de los impulsos

% El tamaño del propágulo ahora se generará aleatoriamente
valor_rasgo_propag = 0.33;

% Opciones para el solver
options = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);

%% Simulación con impulsos
estado_actual = x0; % Estado inicial
tiempo_actual = tspan(1); % Tiempo inicial

tiempo_acumulado = []; % Tiempo acumulado
Y_acumulado = []; % Soluciones acumuladas

for i = 1:frec_propag
    % Tiempo final para este intervalo
    t_end = tiempo_impulsos(i);
    
    % Integrar hasta el próximo impulso
    [tv, Yv] = ode45(@(t, Y) vivi(t, Y, P), [tiempo_actual t_end], estado_actual, options);
    
    % Actualizar las soluciones combinadas
    tiempo_acumulado = [tiempo_acumulado; tv];
    Y_acumulado = [Y_acumulado; Yv];
    
    % Aplicar el impulso en la tercera variable
    estado_actual = Y_acumulado(end, :);
    
    % Generar tamaño_propag aleatorio entre 0 y 30
    tamano_propag = 30 * rand;  % Valor aleatorio entre 0 y 30
    
    estado_actual(3) = estado_actual(3) + tamano_propag;
    
    % Actualización de la sexta variable
    estado_actual(6) = (tamano_propag/(tamano_propag + estado_actual(3))) * valor_rasgo_propag + ...
        (1 - (tamano_propag/(tamano_propag + estado_actual(3)))) * estado_actual(6);

    % Actualizar el tiempo actual
    tiempo_actual = t_end;
end

% Integrar después del último impulso hasta el tiempo final
if tiempo_actual < tspan(2)
    [tv, Yv] = ode45(@(t, Y) vivi(t, Y, P), [tiempo_actual tspan(2)], estado_actual, options);
    tiempo_acumulado = [tiempo_acumulado; tv];
    Y_acumulado = [Y_acumulado; Yv];
end

% Gráfica 
figure(1);
plot(tiempo_acumulado, Y_acumulado(:, 1), '-b', 'LineWidth', 2, 'DisplayName', 'Native prey'); % Línea azul más gruesa
hold on;
plot(tiempo_acumulado, Y_acumulado(:, 2), '-g', 'LineWidth', 2, 'DisplayName', 'Native predator'); % Línea verde más gruesa
plot(tiempo_acumulado, Y_acumulado(:, 3), '-r', 'LineWidth', 2, 'DisplayName', 'Exotic predator'); % Línea roja más gruesa
legend;
xlim([0, 8000]);
ylim([0, 60]);
xlabel('Tiempo');
ylabel('Density');
set(gca, 'FontSize', 20);

% Gráfica 
figure(2);
plot(tiempo_acumulado, Y_acumulado(:, 4), '-b', 'LineWidth', 2, 'DisplayName', 'Native prey'); % Línea azul más gruesa
hold on;
plot(tiempo_acumulado, Y_acumulado(:, 5), '-g', 'LineWidth', 2, 'DisplayName', 'Native predator'); % Línea verde más gruesa
plot(tiempo_acumulado, Y_acumulado(:, 6), '-r', 'LineWidth', 2, 'DisplayName', 'Exotic predator'); % Línea roja más gruesa
legend;
xlim([0, 8000]);
ylim([0, 2]);
xlabel('Tiempo');
ylabel('Trait');
set(gca, 'FontSize', 20);
