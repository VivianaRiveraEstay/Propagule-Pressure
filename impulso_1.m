clc 
close all
clear all
tic;

format long
r0=1.2;
s0=0.2;
K=100;
n=10;
c=5;
d1=0.8;
d2=0.2;
b=0.0125;
theta1=3;
theta2=3;
theta3=3;
theta4=3;
p=0.1;
q0=0.05;
e=0.001;
cx=1;
cy=1;
cz=1;
G1=0.01;
G2=0.01;
G3=0.01;

P=[r0 s0 K n c d1 d2 b theta1 theta2 theta3 theta4 p q0 e cx cy cz G1 G2 G3];

x1=15;
x2=9;
x3=6;
x4=0.01;
x5=0.01;
x6=0.01;

x0=[x1 x2 x3 x4 x5 x6];

     
impulse_interval = 100; % Intervalo entre impulsos
num_impulses = 3;     % Número total de impulsos
impulse_value = 5;     % Magnitud del impulso en la tercera variable

tspan = [0, 10000];      % Intervalo total de tiempo
impulse_time = 50;     % Tiempo en el que ocurre el impulso
impulse_value = 5;     % Magnitud del impulso en la tercera variable

% Configuración del solver
options = odeset('RelTol',1e-6,'AbsTol',1e-8);

% Primera integración antes del impulso
[t1, Y1] = ode45(@(t, Y) vivi(t, Y, P), [tspan(1) impulse_time], x0, options);

% Aplicar el impulso solo a la tercera variable
Y_after_impulse = Y1(end, :);  % Estado al final del primer intervalo
Y_after_impulse(3) = Y_after_impulse(3) + impulse_value;  % Agregar impulso

% Continuar la integración después del impulso
[t2, Y2] = ode45(@(t, Y) vivi(t, Y, P), [impulse_time tspan(2)], Y_after_impulse, options);


% Inicialización de variables
current_state = x0;    % Estado inicial
t_combined = [];       % Tiempo combinado
Y_combined = [];       % Solución combinada

% Bucle para cada intervalo entre impulsos
for i = 1:num_impulses
    t_start = (i-1) * impulse_interval;  % Tiempo de inicio del intervalo
    t_end = i * impulse_interval;        % Tiempo de fin del intervalo
    
    % Resolver el sistema hasta el próximo impulso
    [t_temp, Y_temp] = ode45(@(t, Y) vivi(t, Y, P), [t_start t_end], current_state, options);
    
    % Almacenar resultados
    t_combined = [t_combined; t_temp];
    Y_combined = [Y_combined; Y_temp];
    
    % Aplicar el impulso solo a la tercera variable
    current_state = Y_temp(end, :);      % Último estado
    current_state(3) = current_state(3) + impulse_value;  % Impulso en la tercera variable
end




% Gráfica de las variables
figure;
plot(t_combined, Y_combined(:, 1), '-b', 'DisplayName', 'Native prey');
hold on;
plot(t_combined, Y_combined(:, 2), '-g', 'DisplayName', 'Native predator');
hold on;
plot(t_combined, Y_combined(:, 3), '-r', 'DisplayName', 'Exotic predator');
legend;
xlim([0,4000]);
xlabel('Tiempo');
ylabel('Valor');


