pkg load control
pkg load symbolic

clear all
close all

f0 = 50

s = tf('s')
function y = calcularResistencias(Rs)
  w0 = 2*pi*50;
  Q = sqrt(9.869) * 25 / 111;
  
  C_norm = 10e-9;
  
  y(1) = (3/(Rs(2)*C_norm)) - 444;
  y(2) = (1/(C_norm*C_norm*Rs(1)*Rs(2))) - 9.869e+4;

endfunction

#en teoria quiero los valores mas bajos posibles para menor ruido, pero como 
# no convergia fsolve tuve que despejar a mano los valores y usarlos como semilla
[Rs_encontradas,fval,info] = fsolve('calcularResistencias', [149964;675675]); 

Rs_encontradas, fval


function y = errorOmega(Rs)
  C_norm = 10e-9;

  w0_norm = 1/(C_norm*sqrt(Rs(1)*Rs(2)));
  w0 = 2*pi*50;

  y(1) = 100*abs(w0 - w0_norm)/w0;
endfunction

function y = errorQ(Rs)
  Q = sqrt(9.869) * 25 / 111;
  Q_norm = sqrt(Rs(2)/Rs(1))/3;
  y(1) = 100*abs(Q-Q_norm)/Q;
endfunction


errorOmega(Rs_encontradas) #error ideal, con resistencias ideales
errorQ(Rs_encontradas) #idem

#estudiando el resultado, propongo el siguiente par de resistencias
Rs_norm = [150e+3; 681e+3]

#calculo el error y obtengo 0.5% < 1% en ambos ==> utilizare este par
errorOmega(Rs_norm)
errorQ(Rs_norm)

# NUEVA TRANSFERENCIA
C_norm = 10e-9;

w0_norm = 1/(C_norm*sqrt(Rs_norm(1)*Rs_norm(2)));
Q_norm = sqrt(Rs_norm(2)/Rs_norm(1))/3;


h = s*s / ((s^2 + s*(444) + (100*pi)^2))


h_norm = s*s / ((s^2 + s*(w0_norm/Q_norm) + w0_norm^2))

[modulos_ideales, fases_ideales, omegas_ideales] = bode(h);
[modulos_norm, fases_norm, omegas_norm] = bode(h_norm);
dBs_norm = 20*log10(modulos_norm);
dBs_ideales = 20*log10(modulos_ideales);

%
%figure(1)
%hold on
%  semilogx(omegas_norm, dBs_norm, "color", "black", "linewidth", 2)
%  semilogx(omegas_ideales, dBs_ideales, "color", "red", "linewidth", 2, "--")
%  legend('Modulo normalizada', 'Modulo ideal')
%  title('BODE: Modulo de ambas transferencias')
%  xlabel('omega [rad/s]')
%  ylabel('|H(jw)| [dB]')
%  grid on
%  hold off
%    print figure1.jpg
%
%
%figure(2)
%hold on
%  semilogx(omegas_norm, fases_norm, "color", "black", "linewidth", 2)
%  semilogx(omegas_ideales, fases_ideales, "color", "red", "linewidth", 2, "--")
%    legend('Fase normalizada', 'Fase ideal')
%  title('BODE: Fase de ambas transferencias')
%  xlabel('omega [rad/s]')
%  ylabel('Arg(H(jw))')
%  grid on
%  hold off
%  print figure2.jpg
%
%#RESPUESTA NORMALIZADA AL ESCALON
%
[y_step_norm, t_step_norm] = step(h_norm);
%[y_step_ideal, t_step_ideal] = step(h);
%figure(3)
%hold on
%plot(t_step_norm, y_step_norm, "color", "black", "linewidth", 2)
%plot(t_step_ideal, y_step_ideal, "color", "red", "linewidth", 2, "--")
%legend('Rta normalizada','Rta ideal')
%title('Respuesta al escalon, normalizado vs ideal')
%xlabel('tiempo [s]')
%ylabel('tension [V]')
%grid on
%  print figure3.jpg

  
  
# ---------------------------- LTSPICE ---------------------------
  
# CARGO BODE SIMULADO DE LTSPICE
# COMO EL Q ES MAYOR QUE 0.5 TENGO POLOS COMPLEJOS CONJUGADOS == POLO DOBLE EN W0
# PERO COMO ES MENOR QUE 1 NO ESPERO UN SOBREPICO SINO UN ERROR POR DEBAJO
csv_bode = dlmread('BODEsimulado.txt', ',');
omegas_spice = 2*pi*csv_bode(1:end, 1);
decibeles_spice = csv_bode(1:end, 2);
grados_spice = csv_bode(1:end, 3);

#     comparo
figure(4)
hold on
  semilogx(omegas_spice, decibeles_spice, "color", "black", "linewidth", 2)
  semilogx(omegas_norm, dBs_norm, "color", "red", "linewidth", 2, "--")
  legend('Modulo normalizado', 'Modulo simulado')
  title('BODE: Modulo segun Octave y Spice')
  xlabel('omega [rad/s]')
  ylabel('|H(jw)| [dB]')
  grid on
print figure4.jpg

  hold off

figure(5)
hold on
  semilogx(omegas_spice, grados_spice, "color", "black", "linewidth", 2)
  semilogx(omegas_norm, fases_norm, "color", "red", "linewidth", 2, "--")
  legend('Fase normalizada', 'Fase simulado')
  title('BODE: Fase segun Octave y Spice')
  xlabel('omega [rad/s]')
  ylabel('Arg(H(jw))')
  grid on
  hold off
print figure5.jpg


# CARGO ESCALON SIMULADO EN SPICE

csv_escalon = dlmread('ESCALONsimulado.txt', ',');
tiempos_spice = csv_escalon(1:end, 1);
tensiones_spice = csv_escalon(1:end, 2);

chiqui_v_spice = tensiones_spice(1:(length(tensiones_spice)/3));
chiqui_t_spice = tiempos_spice(1:(length(tiempos_spice)/3));
figure(6)
hold on
plot(tiempos_spice, tensiones_spice, "color", "black", "linewidth", 2)
plot(t_step_norm, y_step_norm, "color", "red", "linewidth", 2, '--')
 legend('Tension simulada', 'Tension normalizada')
title('Respuesta al escalon, Octave vs Spice')
xlabel('tiempo [s]')
ylabel('tension [V]')
hold off
grid on
axes('position', [0.25 0.6 0.35 0.3])
plot(chiqui_t_spice, chiqui_v_spice, "color", "black", "linewidth", 1.5)
print figure6.jpg


#CARGO CUADRADAS SIMULADAS

#   con f0

csv_cuad_1 = dlmread('CUADRADA-1.txt', ',');
t_cuad_1 = csv_cuad_1(1:end, 1);
tensiones_cuad_1 = csv_cuad_1(1:end,2);

[cuad, t] = gensig('SQUARE', 1/f0, 5/f0);
[rta_cuadrada, tiempos] = lsim(h_norm,cuad,t);
figure(7)
hold on
  plot(t_cuad_1, tensiones_cuad_1, "color", "red", "linewidth", 2)
  plot(t,cuad, "color", "black", "linewidth", 1.5,'--')
  legend('Tension simulada','Tension de entrada')
  title('Respuesta a onda cuadrada, frecuencia f0')
  xlabel('tiempo [s]')
  ylabel('tension [V]')
  hold off
  grid on
print figure7.jpg

  # con f0/10
  
 
csv_cuad_2 = dlmread('CUADRADA-0,1.txt', ',');
t_cuad_2 = csv_cuad_2(1:end, 1);
tensiones_cuad_2 = csv_cuad_2(1:end,2);

[cuad2, t2] = gensig('SQUARE', 1/25, 5/25);
[rta_cuadrada2, tiempos2] = lsim(h_norm,cuad2,t2);
figure(8)
hold on
  plot(tiempos2, rta_cuadrada2, "color", "red", "linewidth", 2)
  plot(t2,cuad2, "color", "black", "linewidth", 1.5, '--')
  legend('Tension simulada', 'Tension de entrada')
  title('Respuesta a onda cuadrada, frecuencia f0/10')
  xlabel('tiempo [s]')
  ylabel('tension [V]')
  hold off
  grid on
  print figure8.jpg

  
# con 10*f0


csv_cuad_3 = dlmread('CUADRADA-10.txt', ',');
t_cuad_3 = csv_cuad_3(1:end, 1);
tensiones_cuad_3 = csv_cuad_3(1:end,2);

[cuad3, t3] = gensig('SQUARE', 0.1/f0, 0.5/f0);
[rta_cuadrada3, tiempos3] = lsim(h_norm,cuad3,t3);
figure(9)
hold on
  plot(t_cuad_3, tensiones_cuad_3, "color", "red", "linewidth", 2)
  plot(t3,cuad3, "color", "black", "linewidth", 1.5, '--')
  legend('Tension simulada', 'Tension de entrada')
  title('Respuesta a onda cuadrada, frecuencia 10*f0')
  xlabel('tiempo [s]')
  ylabel('tension [V]')
  hold off
  grid on
  print figure9.jpg














