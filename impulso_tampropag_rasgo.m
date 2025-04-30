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
frec_propag = 4;      % Frecuencia del prpágulo
intervalo_introduccion = 100; % Intervalo entre impulsos

tiempo_impulsos = (1:frec_propag) * intervalo_introduccion; % Tiempos de los impulsos

%tamano_propag = 20;  % Incremento en la tercera variable durante cada impulso
%valor_rasgo_propag = 0.5; % valor del rasgos w de los propagulos 

tamano_propag = 0:0.1:30;
valor_rasgo_propag=0:0.01:1;

m1=length(tamano_propag);
m2=length(valor_rasgo_propag);

R1 = zeros(m1, m2);

for k1=1:m1
    for k2=1:m2


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
    estado_actual(3) = estado_actual(3) + tamano_propag(k1);
    %estado_actual(6) =estado_actual(6) + (estado_actual(6)*estado_actual(3) + valor_rasgo_propag*tamano_propag)/(estado_actual(3)+tamano_propag);
    estado_actual(6) = (tamano_propag(k1)/(tamano_propag(k1)+estado_actual(3)))*valor_rasgo_propag(k2)+(1-(tamano_propag(k1)/(tamano_propag(k1)+estado_actual(3))))*estado_actual(6);
 


    % Actualizar el tiempo actual
    tiempo_actual = t_end;
end

% Integrar después del último impulso hasta el tiempo final
if tiempo_actual < tspan(2)
    [tv, Yv] = ode45(@(t, Y) vivi(t, Y, P), [tiempo_actual tspan(2)], estado_actual, options);
    tiempo_acumulado = [tiempo_acumulado; tv];
    Y_acumulado = [Y_acumulado; Yv];
end


R1(k1,k2)=Yv(end,3); % exotico

end
end


min_val1 = min([R1(:)]);
max_val1 = max([R1(:)]);

cmap1 = flipud(jet(2000));

figure(1);
[X, Y] = meshgrid(tamano_propag, valor_rasgo_propag);
contourf(X, Y, R1', 2000, 'LineStyle', 'none');
colormap(cmap1);
caxis([min_val1, max_val1]);
cb = colorbar;
set(cb, 'TickLabelInterpreter', 'latex'); % LaTeX 
ax = gca;
ax.FontSize = 14;
xlim([0, 30]);
ylim([0, 1]);
axis square;
%xticks([0, 1, 2, 3, 4, 5]);
%yticks([0, 1, 2, 3, 4, 5]);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 30);



