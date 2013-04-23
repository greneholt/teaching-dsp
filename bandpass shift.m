[y, Fs] = wavread('atlys.wav');

Fl = 800;
Fh = 2500;
Ft = 300;

shift = 3000;
M = 1000;

% kVec = [0:M-1];
% omegak = 2*pi*kVec/M;
% omegakEquiv = mod(omegak + pi, 2*pi) - pi;
% Hd = 1*(abs(omegakEquiv) >= 2*pi*Fl/Fs) .* (abs(omegakEquiv) <= 2*pi*Fh/Fs);
% h = real(ifft(Hd));

F = [0 (Fl-Ft)/Fs*2 Fl/Fs*2 Fh/Fs*2 (Fh+Ft)/Fs*2 1];
A = [0 0 1 1 0 0];
h = firpm(M, F, A);

figure(1);
freqz(h);

figure(2);
freqz(y);

yf = conv(y, h);

figure(3);
freqz(yf);

omega_shift = shift/Fs*2*pi;
s = rot90(cos(omega_shift * (0:length(yf)-1)));

ys = yf .* s;

figure(4);
freqz(ys);

F = [0 (Fl+shift-Ft)/Fs*2 (Fl+shift)/Fs*2 (Fh+shift)/Fs*2 (Fh+shift+Ft)/Fs*2 1];
A = [0 0 1 1 0 0];
h = firpm(M, F, A);

figure(5);
freqz(h);

ys = conv(ys, h);

figure(6);
freqz(ys);

sound(ys, Fs);

%figure(2);
%specgram(y, [], Fs);

%figure(3);
%specgram(yf, [], Fs);

%figure(4);
%specgram(ys, [], Fs);

