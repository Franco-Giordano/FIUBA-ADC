pkg load control
pkg load symbolic

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

Rs_encontradas


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


h_norm = s*s / ((s^2 + s*(w0_norm/Q_norm) + w0_norm^2))


[modulos_norm, fases_norm, omegas_norm] = bode(h_norm);
dBs_norm = 20*log10(modulos_norm);

figure(1)
hold on
  semilogx(omegas_norm, modulos_norm)
  semilogx(omegas, modulos_ideales)
  title('BODE: Modulo TRANSF NORMALIZADA vs ideal')
  xlabel('omega [rad/s]')
  ylabel('|H(jw)| [dB]')
  grid on
  hold off

figure(2)
hold on
  semilogx(omegas_norm, fases_norm)
  semilogx(omegas, fases_ideales)
  title('BODE: Fase TRANSF NORMALIZADA vs ideal')
  xlabel('omega [rad/s]')
  ylabel('Arg(H(jw))')
  grid on
  hold off

#RESPUESTA NORMALIZADA AL ESCALON

[y_step_norm, t_step_norm] = step(h_norm);
figure(2)
plot(t_step_norm, y_step_norm)
title('Respuesta al escalon, normalizado')
xlabel('tiempo [s]')
ylabel('tension [V]')
grid on
  
  