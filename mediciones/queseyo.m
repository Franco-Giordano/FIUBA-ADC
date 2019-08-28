pkg load control
pkg load symbolic

clear all
close all

f0 = 50;


csv_escalon = dlmread('PARTE 2 - MEDICIONES/mediciones ADC.csv', ',');
frecs = csv_escalon(1:end, 1);
vpico = csv_escalon(1:end, 2);


pulsacion = 2*pi*(frecs);
loglog = log10(pulsacion)
vpico = vpico/1000;
dbs = 20*log10(vpico)



csv_bode = dlmread('BODEsimulado.txt', ',');
omegas_spice = 2*pi*csv_bode(1:end, 1);
decibeles_spice = csv_bode(1:end, 2);
grados_spice = csv_bode(1:end, 3);



semilogx(pulsacion, dbs,"color", "red", "linewidth", 2.3, 'o--');
grid on


figure(1)
hold on
  semilogx(omegas_spice, decibeles_spice, "color", "black", "linewidth", 2)
  plot([314.16,314.16],[-80,20],"color", "black", "linewidth", 1.3, '--' );
  legend('Modulo mediciones', 'Modulo simulado (LTSpice)', 'w0 = 314.16', 'location', 'southeast');
  title('BODE: Modulo de transferencia simulada vs. mediciones')
  xlabel('omega [rad/s]')
  ylabel('|H(jw)| [dB]')
  grid on
  print moduloMediciones.jpg
  hold off

