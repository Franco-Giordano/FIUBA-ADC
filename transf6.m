pkg load control
pkg load symbolic

f0 = 50
w0 = 2*pi*f0
Tau = 1/w0


s = tf('s')

# TRANSFERENCIA 6

#w0 = sqrt(9.869)*100

Q = sqrt(9.869) * 25 / 111

h = s*s / ((s^2 + s*(w0/Q) + w0^2))




# RESPUESTA IDEAL AL ESCALON
[y_step_ideal, t_step_ideal] = step(h);
figure(1)
plot(t_step_ideal, y_step_ideal)
title('Respuesta al escalon')
xlabel('tiempo [s]')
ylabel('tension [V]')
grid on



# RESPUESTA IDEAL AL IMPULSO

% Para que funcione y no explote con frecuencias en infinito, agrego un polo
% en 100*w0 asi filtro las frecs altas (lo transformo en un pasa bandas).  
% La delta me la va a graficar con un poco de error, pero en esencia deberia ver una
% delta casi perfecta (no tanto porque me faltan algunas frecs bajas).

tarado = s*s / ((s^2 + s*(w0/Q) + w0^2)*(s+100*w0))

[y_imp, t_imp] = impulse(tarado);
figure(2)
plot(t_imp, y_imp)
title('Respuesta al impulso')
xlabel('tiempo [s]')
ylabel('tension [V]')
grid on



# RESPUESTA IDEAL A LA CUADRADA
[cuad, t] = gensig('SQUARE', 1/f0, 5/f0); #no se si va w0 o que
[rta_cuadrada, tiempos] = lsim(h,cuad,t);
figure(3)
  plot(tiempos, rta_cuadrada)
  title('Respuesta a onda cuadrada')
  xlabel('tiempo [s]')
  ylabel('tension [V]')
  grid on



# BODE
[modulos_ideales, fases_ideales, omegas] = bode(h);
dBs = 20*log10(modulos_ideales);

figure(4)
  semilogx(omegas, modulos_ideales)
  title('BODE: Modulo')
  xlabel('omega [rad/s]')
  ylabel('|H(jw)| [dB]')
  grid on

figure(5)
  semilogx(omegas, fases_ideales)
  title('BODE: Fase')
  xlabel('omega [rad/s]')
  ylabel('Arg(H(jw))')
  grid on

  
  
  




