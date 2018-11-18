clc
clear all;
% systemh.m - A MATLAB Calculator for the friction losses in pipe systems with any fluid   
% The tool calculates the friction (head) losses in SI Units
% Darcy-Weisbach friction factor was calculated by a function whose using the Colebrook-White algorithm
% This file is written in Turkish, it will be completed soon and translated into English.
% Kerim Kaan D�nmez, github.com/kerimkaan

% Verilenler
g = 9.81;
f_e = 0;
f_b = 0;

% Kullan�c� giri�leri
v   = input('Debi (m3/h) giriniz: ');
v   = v/3600; % Debiyi m3/s cinsine �evir.
y   = input('Ak��kan yo�unlu�u giriniz (kg/m3): ');
pe  = input('Emme bas�nc�n� giriniz (bar): ');
pe  = pe*10^5; % Bar -> Pa
pb  = input('Basma bas�nc�n� giriniz (bar): ');
pb  = pb*10^5; % Bar -> Pa
t   = input('Ak��kan s�cakl��� giriniz (*C): ');
ze  = input('Emme statik y�ksekli�i giriniz (m): ');
zb  = input('Basma statik y�ksekli�i giriniz (m): ');
vis = input('Viskozite de�erini giriniz (cSt): ');
vis = vis*10^(-6); % cSt -> m2/s
eps = input('Epsilon(P�r�zl�l�k katsay�s�) giriniz (mm): ');
eps = eps/1000;
n1   = input('Pompa verimi giriniz (%): ');
n   = n1/100;

% Borular�n fiziksel �zellikleri ve sistem komponentleri
l_e = input('Emme hatt� uzunlu�unu giriniz (m): ');
l_b = input('Basma hatt� uzunlu�unu giriniz (m): ');
d_e = input('Emme hatt� �ap�n� giriniz (m): ');
d_b = input('Basma hatt� �ap�n� giriniz (m): ');
dirsek_e = input('[EMME] 90*C Dirsek adedi (e�er varsa, yoksa 0 giriniz): ');
surgu_e  = input('[EMME] S�rg�l� valf adedi(e�er varsa, yoksa 0 giriniz): ');
konik_e  = input('[EMME] Konik red�ksiyon adedi (e�er varsa, yoksa 0 giriniz): ');
checkvalf_e  = input('[EMME] Checkvalf adedi (e�er varsa, yoksa 0 giriniz): ');
dirsek_b = input('[BASMA] 90*C Dirsek adedi (e�er varsa, yoksa 0 giriniz): ');
surgu_b  = input('[BASMA] S�rg�l� valf adedi(e�er varsa, yoksa 0 giriniz): ');
konik_b  = input('[BASMA] Konik red�ksiyon adedi (e�er varsa, yoksa 0 giriniz): ');
checkvalf_b  = input('[BASMA] Checkvalf adedi (e�er varsa, yoksa 0 giriniz): ');

% Yerel kay�plar i�in k katsay�lar�
k_d     = 0.39; % 90* dirsek
k_sv    = 0.18; % S�rg�l� valf
k_red   = 0.02; % Konik red�ksiyon
k_cv    = 0.42; % �ekvalf

% Emme ve basma hatlar� ak��kan h�z� ve Reynolds say�s� hesab�
u_emme      = (4*v)/(pi*(d_e^2));
u_basma     = (4*v)/(pi*(d_b^2));
re_e        = (u_emme*d_e)/vis; 
re_b        = (u_basma*d_b)/vis;

% Y�k kay�plar�
h1 = (pb-pe)/(y*g);
h2 = (u_basma^2 - u_emme^2)/(2*g);
h3 = (zb-ze);

% Boru ve lokal kay�plar�n hesaplanmas�

    % Emme hatt� boru s�rt�nme ve lokal kay�plar�
if re_e > 10000
   % [EMME] Colebrook Denklemi ile friction factor de�erinin bulunmas�
    f_e = moody(eps/d_e,re_e);
else
    f_e = 64/re_e;
end

hb_e = f_e*(l_e/d_e)*((u_emme^2)/(2*g)); % Emme boru s�rt�nme kay�plar�
hl_e = ((dirsek_e*k_d)+(surgu_e*k_sv)+(konik_e*k_red)+(checkvalf_e*k_cv))*((u_emme^2)/(2*g)) % Emme yerel

    % Basma hatt� boru s�rt�nme ve lokal kay�plar�
if re_b > 10000;
    % [BASMA] Colebrook Denklemi ile friction factor de�erinin bulunmas�
    f_b = moody(eps/d_b,re_b);
else
    f_b = 64/re_b;
end

hb_b = f_b*(l_b/d_b)*((u_basma^2)/(2*g)); % Basma boru s�rt�nme kay�plar�
hl_b = ((dirsek_b*k_d)+(surgu_b*k_sv)+(konik_b*k_red)+(checkvalf_b*k_cv))*((u_basma^2)/(2*g)) % Basma yerel

% S�STEM�N MANOMETR�K Y�KSEL��� VE GEREKL� G��

h_total = h1+h2+h3+hb_e+hl_e+hb_b+hl_b;
p_mil = (y*g*h_total*v)/n;
p_mil_kw = p_mil/1000;

fprintf('Sistemin Manometrik y�ksekli�i (m): %.2f \n', h_total);
fprintf('Gerekli mil g�c� (W): %.2f \n', p_mil);
fprintf('Gerekli mil g�c� (kW): %.2f \n', p_mil_kw);
cat=categorical({'Toplam H','Bas�n� H','Kinetik H','Statik H','Emme Boru H','Emme Yerel H','Basma Boru H','Basma Yerel H'})
subplot(2,1,1)
bar(cat,[h_total,h1,h2,h3,hb_e,hl_e,hb_b,hl_e])
title('Head Miktarlar�')
subplot(2,1,2)
cat1=categorical({'Toplam H','Gerekli kW','Pompa Verimi'})
bar(cat1,[h_total,p_mil_kw,n1])
title('H/P/N Grafi�i')
