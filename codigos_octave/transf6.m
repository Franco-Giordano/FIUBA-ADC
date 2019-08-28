pkg load control
pkg load symbolic

close all
clear all

f0 = 50
w0 = 2*pi*f0

s = tf('s')

# TRANSFERENCIA 6

#w0 = sqrt(9.869)*100

Q = sqrt(9.869) * 25 / 111
Q = pi/4.44
Q = 0.5

h = s^2 / (s^2 + s*(w0/Q) + w0^2)




# RESPUESTA IDEAL AL ESCALON
[y_step_ideal, t_step_ideal] = step(h);
figure(1)
plot(t_step_ideal, y_step_ideal, "color", "black", "linewidth", 2.5)
title('Respuesta al escalon')
xlabel('tiempo [s]')
ylabel('tension [V]')
grid on

  print figure1.jpg



# RESPUESTA IDEAL AL IMPULSO

% Para que funcione y no explote con frecuencias en infinito, agrego un polo
% en 100*w0 asi filtro las frecs altas (lo transformo en un pasa bandas).  
% La delta me la va a graficar con un poco de error, pero en esencia deberia ver una
% delta casi perfecta (no tanto porque me faltan algunas frecs bajas).

h_impulso = (s^2) / ((s^2 + s*(w0/Q) + w0^2)*(s+10000))

[y_imp, t_imp] = impulse(h_impulso);
figure(2)
hold on
plot(t_imp, y_imp, "color", "black", "linewidth", 2.5)
plot(t_step_ideal, y_step_ideal, "color", "red", "linewidth", 2.5)



title('Respuesta al impulso')
xlabel('tiempo [s]')
ylabel('tension [V]')
grid on
  print figure2.jpg


%
%# RESPUESTA IDEAL A LA CUADRADA, con f0
%[cuad, t] = gensig('SQUARE', 1/f0, 5/f0);
%[rta_cuadrada, tiempos] = lsim(h,cuad,t);
%figure(3)
%hold on
%  plot(tiempos, rta_cuadrada, "color", "black", "linewidth", 2.5)
%  plot(t,cuad, "color", "black", "linewidth", 1.5, '--');
%  legend('Salida','Entrada')
%  title('Respuesta a onda cuadrada, frecuencia f0')
%  xlabel('tiempo [s]')
%  ylabel('tension [V]')
%  grid on
%  hold off
%  print figure3.jpg
%  
%#                               con f0/10
%[rta_cuadrada2, tiempos2] = lsim(h,cuad2,t2);
%figure(4)
%hold on
%  plot(tiempos2, rta_cuadrada2, "color", "black", "linewidth", 2.5)
%  plot(t2,cuad2, "color", "black", "linewidth", 1.5, '--');
%  legend('Salida','Entrada')
%  title('Respuesta a onda cuadrada, frecuencia f0/10')
%  xlabel('tiempo [s]')
%  ylabel('tension [V]')
%  grid on
%  hold off
%  print figure4.jpg
%
%  
%#                               con 10*f0
%[cuad3, t3] = gensig('SQUARE', 1/(10*f0), 5/(10*f0));
%[rta_cuadrada3, tiempos3] = lsim(h,cuad3,t3);
%figure(5)
%hold on
%  plot(tiempos3, rta_cuadrada3, "color", "black", "linewidth", 2.5)
%  plot(t3,cuad3, "color", "black", "linewidth", 1.5, '--');
%  legend('Salida','Entrada')
%  title('Respuesta a onda cuadrada, frecuencia 10*f0')
%  xlabel('tiempo [s]')
%  ylabel('tension [V]')
%  hold off
%  grid on
%  print figure5.jpg
%

# BODE
[modulos_ideales, fases_ideales, omegas] = bode(h);
dBs = 20*log10(modulos_ideales);

figure(6)
hold on
  semilogx(omegas, dBs, "color", "black", "linewidth", 2.5)
  plot([314,314],[-60,10], "color", "black", "linewidth", 1.5, '--');
  plot([8722,8722],[-60,10], "color", "red", "linewidth", 1.5, '--');
  title('BODE: Modulo')
  xlabel('omega [rad/s]')
  ylabel('|H(jw)| [dB]')
legend('Modulo', 'w = w0', 'w=wd');
  grid on
  hold off
  print figure6.png

figure(7)
hold on
  semilogx(omegas, fases_ideales, "color", "black", "linewidth", 2.5)
  title('BODE: Fase')
  xlabel('omega [rad/s]')
  ylabel('Arg(H(jw))')
  plot([314,314],[0,200], "color", "black", "linewidth", 1.5, '--');
legend('Fase', 'w = w0');

  grid on
  print figure7.jpg

  
  
  




