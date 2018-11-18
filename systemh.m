clc
clear all;
% systemh.m - A MATLAB Calculator for the friction losses in pipe systems with any fluid   
% The tool calculates the friction (head) losses in SI Units
% Darcy-Weisbach friction factor was calculated by a function whose using the Colebrook-White algorithm
% This file is written in Turkish, it will be completed soon and translated into English.
% Kerim Kaan Dönmez, github.com/kerimkaan

% Verilenler
g = 9.81;
f_e = 0;
f_b = 0;

% Kullanýcý giriþleri
v   = input('Debi (m3/h) giriniz: ');
v   = v/3600; % Debiyi m3/s cinsine çevir.
y   = input('Akýþkan yoðunluðu giriniz (kg/m3): ');
pe  = input('Emme basýncýný giriniz (bar): ');
pe  = pe*10^5; % Bar -> Pa
pb  = input('Basma basýncýný giriniz (bar): ');
pb  = pb*10^5; % Bar -> Pa
t   = input('Akýþkan sýcaklýðý giriniz (*C): ');
ze  = input('Emme statik yüksekliði giriniz (m): ');
zb  = input('Basma statik yüksekliði giriniz (m): ');
vis = input('Viskozite deðerini giriniz (cSt): ');
vis = vis*10^(-6); % cSt -> m2/s
eps = input('Epsilon(Pürüzlülük katsayýsý) giriniz (mm): ');
eps = eps/1000;
n1   = input('Pompa verimi giriniz (%): ');
n   = n1/100;

% Borularýn fiziksel özellikleri ve sistem komponentleri
l_e = input('Emme hattý uzunluðunu giriniz (m): ');
l_b = input('Basma hattý uzunluðunu giriniz (m): ');
d_e = input('Emme hattý çapýný giriniz (m): ');
d_b = input('Basma hattý çapýný giriniz (m): ');
dirsek_e = input('[EMME] 90*C Dirsek adedi (eðer varsa, yoksa 0 giriniz): ');
surgu_e  = input('[EMME] Sürgülü valf adedi(eðer varsa, yoksa 0 giriniz): ');
konik_e  = input('[EMME] Konik redüksiyon adedi (eðer varsa, yoksa 0 giriniz): ');
checkvalf_e  = input('[EMME] Checkvalf adedi (eðer varsa, yoksa 0 giriniz): ');
dirsek_b = input('[BASMA] 90*C Dirsek adedi (eðer varsa, yoksa 0 giriniz): ');
surgu_b  = input('[BASMA] Sürgülü valf adedi(eðer varsa, yoksa 0 giriniz): ');
konik_b  = input('[BASMA] Konik redüksiyon adedi (eðer varsa, yoksa 0 giriniz): ');
checkvalf_b  = input('[BASMA] Checkvalf adedi (eðer varsa, yoksa 0 giriniz): ');

% Yerel kayýplar için k katsayýlarý
k_d     = 0.39; % 90* dirsek
k_sv    = 0.18; % Sürgülü valf
k_red   = 0.02; % Konik redüksiyon
k_cv    = 0.42; % Çekvalf

% Emme ve basma hatlarý akýþkan hýzý ve Reynolds sayýsý hesabý
u_emme      = (4*v)/(pi*(d_e^2));
u_basma     = (4*v)/(pi*(d_b^2));
re_e        = (u_emme*d_e)/vis; 
re_b        = (u_basma*d_b)/vis;

% Yük kayýplarý
h1 = (pb-pe)/(y*g);
h2 = (u_basma^2 - u_emme^2)/(2*g);
h3 = (zb-ze);

% Boru ve lokal kayýplarýn hesaplanmasý

    % Emme hattý boru sürtünme ve lokal kayýplarý
if re_e > 10000
   % [EMME] Colebrook Denklemi ile friction factor deðerinin bulunmasý
    f_e = moody(eps/d_e,re_e);
else
    f_e = 64/re_e;
end

hb_e = f_e*(l_e/d_e)*((u_emme^2)/(2*g)); % Emme boru sürtünme kayýplarý
hl_e = ((dirsek_e*k_d)+(surgu_e*k_sv)+(konik_e*k_red)+(checkvalf_e*k_cv))*((u_emme^2)/(2*g)) % Emme yerel

    % Basma hattý boru sürtünme ve lokal kayýplarý
if re_b > 10000;
    % [BASMA] Colebrook Denklemi ile friction factor deðerinin bulunmasý
    f_b = moody(eps/d_b,re_b);
else
    f_b = 64/re_b;
end

hb_b = f_b*(l_b/d_b)*((u_basma^2)/(2*g)); % Basma boru sürtünme kayýplarý
hl_b = ((dirsek_b*k_d)+(surgu_b*k_sv)+(konik_b*k_red)+(checkvalf_b*k_cv))*((u_basma^2)/(2*g)) % Basma yerel

% SÝSTEMÝN MANOMETRÝK YÜKSELÝÐÝ VE GEREKLÝ GÜÇ

h_total = h1+h2+h3+hb_e+hl_e+hb_b+hl_b;
p_mil = (y*g*h_total*v)/n;
p_mil_kw = p_mil/1000;

fprintf('Sistemin Manometrik yüksekliði (m): %.2f \n', h_total);
fprintf('Gerekli mil gücü (W): %.2f \n', p_mil);
fprintf('Gerekli mil gücü (kW): %.2f \n', p_mil_kw);
cat=categorical({'Toplam H','Basýnç H','Kinetik H','Statik H','Emme Boru H','Emme Yerel H','Basma Boru H','Basma Yerel H'})
subplot(2,1,1)
bar(cat,[h_total,h1,h2,h3,hb_e,hl_e,hb_b,hl_e])
title('Head Miktarlarý')
subplot(2,1,2)
cat1=categorical({'Toplam H','Gerekli kW','Pompa Verimi'})
bar(cat1,[h_total,p_mil_kw,n1])
title('H/P/N Grafiði')
