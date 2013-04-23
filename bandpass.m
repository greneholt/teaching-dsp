[y, Fs] = wavread('atlys.wav');

Fl = 800;
Fh = 2000;
Ft = 200;

M = 700;

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

yf = yf(1:length(y));

figure(3);
freqz(yf);

%sound(yf, Fs);

F = [0 (Fl-2*Ft)/Fs*2 (Fl-Ft)/Fs*2 (Fh+Ft)/Fs*2 (Fh+2*Ft)/Fs*2 1];
A = [1 1 0 0 1 1];
hn = firpm(M, F, A);

noise = wgn(length(y),1,10);

noise = conv(noise, hn);

noise = noise(1:length(y));

figure(4);
freqz(noise);

t = 0:length(y)-1;

tones = zeros(size(y));

tone_freqs = [700 800 900];
for f = tone_freqs
    tones = tones + rot90(3*sin(f/Fs*2*pi*t));
end

out = y + noise + tones;

figure(5);
freqz(out);

wavwrite(out, Fs, 'noisy.wav');

sound(out, Fs);

filtered = conv(out, h);

for f = tone_freqs
    % filter parameters
    w0 = f/Fs*2*pi;
    r = 0.999;

    % filter coefficients
    B = [1, -2*cos(w0), 1];
    A = [1, -2*r*cos(w0), r^2];
    
%     q = zeros(10000,1);
%     q(1) = 1;
%     q = filter(B, A, q);
%     
%     filtered = conv(filtered, q);
    
    filtered = filter(B, A, filtered);
end

figure(6);
freqz(filtered);

wavwrite(filtered, Fs, 'filtered.wav');

sound(filtered, Fs);

%figure(2);
%specgram(y, [], Fs);

%figure(3);
%specgram(yf, [], Fs);

%figure(4);
%specgram(ys, [], Fs);

