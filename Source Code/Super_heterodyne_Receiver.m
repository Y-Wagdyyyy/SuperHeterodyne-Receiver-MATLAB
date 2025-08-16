clear
clc
close all

% Correct base path
basePath = 'C:\Users\HP\Desktop\Super-heterodyne-Receiver-master\Super-heterodyne-Receiver-master\Audio signals\';

% Use curly braces when indexing cell arrays
filename = { ...
    [basePath 'Short_BBCArabic2.wav'], ...
    [basePath 'Short_FM9090.wav'], ...
    [basePath 'Short_QuranPalestine.wav'], ...
    [basePath 'Short_RussianVoice.wav'], ...
    [basePath 'Short_SkyNewsArabia.wav'] ...
};

sum_signals = 0;

for i = 1 : 5
    %%%%%%%%%% Reading monophonic audio signals into MATLAB %%%%%%%%%%
    [auido_signal, Fs] = audioread(filename{i});   % use curly braces!
    auido_signal = sum(auido_signal.');            % stereo to mono
    auido_signal = auido_signal';                  
    max_audio_length = 740544;                     
    auido_signal(end + max_audio_length - length(auido_signal) , 1) = 0;
    
    subplot(3,5,i)                                                        
    plot(auido_signal, 'b');
    title(['Signal ' num2str(i) ' in Time Domain'])
    xlabel('Time (s)')
    ylabel('Volts')
    grid on 
    ylim([-3 3])

    %%%%%%%%%% FFT of Audio signal %%%%%%%%%%
    AUDIO_SIGNAL = fft(auido_signal, length(auido_signal));
    f_Y = (-length(AUDIO_SIGNAL)/2:1:length(AUDIO_SIGNAL)/2-1)';
    subplot(3,5,5 + i)
    plot(f_Y*(Fs/length(AUDIO_SIGNAL)), fftshift(abs(AUDIO_SIGNAL)), 'r')
    title('Frequency Spectrum of Signal')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    grid on 
    
    auido_signal = interp(auido_signal, 15);
    %%%%%%%%%% Local Oscillator (Carrier) %%%%%%%%%%
    n = (i-1);
    delta_f = 50000;                 
    f_o = 100000;                    
    fn = f_o + n*delta_f;            
    Fs_carrier = 15*Fs;              
    t = (1:1:length(auido_signal))'; 
    carrier_signal = cos(2*pi*fn*t*(1/(15*Fs)))/15;

    %%%%%%%%%% AM-SC modulation %%%%%%%%%%
    modulating_signal = interp(auido_signal, 1);
    carrier_signal(end + length(modulating_signal) - length(carrier_signal), 1) = 0;
    modulated_signal = carrier_signal.*modulating_signal; 
    MODULATED_SIGNAL = fftshift(fft(modulated_signal));
    
    %%%%%%%%%% Addition of the modulated signals %%%%%%%%%%
    sum_signals = sum_signals + modulated_signal;

    f_MODULATED_SIGNAL = (-length(MODULATED_SIGNAL)/2:1:length(MODULATED_SIGNAL)/2-1)';
        %%%%%%%%%% Addition of the modulated signals %%%%%%%%%%
    sum_signals = sum_signals + modulated_signal;

    % Compute frequency axis for plotting
    f_MODULATED_SIGNAL = (-length(MODULATED_SIGNAL)/2:1:length(MODULATED_SIGNAL)/2-1)';

    % === PLOT the modulated signal spectrum ===
    subplot(3,5,10 + i)
    plot(f_MODULATED_SIGNAL*Fs_carrier/length(MODULATED_SIGNAL), abs(MODULATED_SIGNAL), 'g')
    [~, nameOnly, ~] = fileparts(filename{i});
    title(['Modulated ' nameOnly ' signal'], 'Interpreter', 'none');
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    grid on 
    xlim([-1.5*fn 1.5*fn])

end

%% RF Stage
SUM_SIGNALS = fftshift(fft(sum_signals));
f_MODULATED_SIGNAL = (-length(SUM_SIGNALS)/2:1:length(SUM_SIGNALS)-length(SUM_SIGNALS)/2-1)';
figure('Name', 'RF stage')
subplot(2,1,1)
plot(f_MODULATED_SIGNAL*Fs_carrier/length(SUM_SIGNALS),abs(SUM_SIGNALS), 'g')
title('Transmitted Signals')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on 

fprintf('Choose one of these channels:\n');
fprintf('1. Short_BBCArabic2\n');
fprintf('2. Short_FM9090\n');
fprintf('3. Short_QuranPalestine\n');
fprintf('4. Short_RussianVoice\n');
fprintf('5. Short_SkyNewsArabia\n');
choose_signal = input('Choose: '); 

signal_number = 0.5*choose_signal+0.5;
BW = 30000;
A_stop1 = 60;                           
F_stop1 = signal_number*100000-BW;      
F_pass1 = signal_number*100000-BW/2;    
F_pass2 = signal_number*100000+BW/2;    
F_stop2 = signal_number*100000+BW;      
A_stop2 = 60;                           
A_pass = 1;                             

band_pass_filter = fdesign.bandpass(F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, A_stop2, 15*Fs);
band_pass_filter = design(band_pass_filter, 'equiripple');
sum_signals_BPF  = filter(band_pass_filter, sum_signals);
SUM_SIGNALS_BPF  = fftshift(fft(sum_signals_BPF));
f_MODULATED_SIGNAL = (-length(SUM_SIGNALS_BPF)/2:1:length(SUM_SIGNALS_BPF)/2-1)';
subplot(2,1,2)
plot(f_MODULATED_SIGNAL*Fs_carrier/length(SUM_SIGNALS_BPF), abs(SUM_SIGNALS_BPF), 'r')
title('RF stage after BPF')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on

%% IF Stage
fc = signal_number*100000;       
IF = 25000;                      
f_carrier = fc + IF;             
Fs_carrier = 15*Fs;              
t = (1:1:length(sum_signals_BPF))';
carrier_signal_IF = cos(2*pi*f_carrier*t*(1/(15*Fs)));
carrier_signal_IF(end + length(sum_signals_BPF) - length(carrier_signal_IF), 1) = 0;
IF_received_signal = sum_signals_BPF.*carrier_signal_IF;
IF_RECEIVED_SIGNAL = fftshift(fft(IF_received_signal));
f_RECEIVED_SIGNAL = (-length(IF_RECEIVED_SIGNAL)/2:1:length(IF_RECEIVED_SIGNAL)/2-1)';
figure('Name', 'If stage')
subplot(2,1,1)
[~, nameOnly, ~] = fileparts(filename{choose_signal});
title(['IF stage of ' nameOnly ' channel']);
plot(f_RECEIVED_SIGNAL*Fs_carrier/length(IF_RECEIVED_SIGNAL),abs(IF_RECEIVED_SIGNAL), 'g')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on 

BW = 30000;
A_stop1 = 60;                           
F_stop1 = BW - IF;                      
F_pass1 = IF-BW/2;                      
F_pass2 = IF+BW/2;                      
F_stop2 = BW + IF;                      
A_stop2 = 60;                           
A_pass = 1;                             

band_pass_filter = fdesign.bandpass(F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, A_stop2, 15*Fs);
band_pass_filter = design(band_pass_filter, 'equiripple');
IF_received_signal_BPF  = filter(band_pass_filter, IF_received_signal);
IF_RECEIVED_SIGNAL_BPF  = fftshift(fft(IF_received_signal_BPF));
f_RECEIVED_SIGNAL_BPF = (-length(IF_RECEIVED_SIGNAL_BPF)/2:1:length(IF_RECEIVED_SIGNAL_BPF)/2-1)';
subplot(2,1,2)
plot(f_RECEIVED_SIGNAL_BPF*Fs_carrier/length(IF_RECEIVED_SIGNAL_BPF), abs(IF_RECEIVED_SIGNAL_BPF), 'r')
title('IF stage after BPF')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on

%% Baseband Stage
fc = signal_number*100000;       
Base_Band_freq = 25000;          
f_carrier = Base_Band_freq;      
Fs_carrier = 15*Fs;              
t = (1:1:length(IF_received_signal_BPF))';
carrier_signal_Base_Band = cos(2*pi*f_carrier*t*(1/(15*Fs)));
carrier_signal_Base_Band(end + length(sum_signals_BPF) - length(carrier_signal_Base_Band), 1) = 0;
Base_Band_received_signal = IF_received_signal_BPF.*carrier_signal_Base_Band;
BASE_BAND_RECEIVED_SIGNAL = fftshift(fft(Base_Band_received_signal));
f_RECEIVED_SIGNAL_BASE_BAND = (-length(BASE_BAND_RECEIVED_SIGNAL)/2:1:length(BASE_BAND_RECEIVED_SIGNAL)/2-1)';
figure('Name', 'Base Band stage')
subplot(2,1,1)
[~, nameOnly, ~] = fileparts(filename{choose_signal});
title(['Base Band stage of ' nameOnly ' channel']);
plot(f_RECEIVED_SIGNAL_BASE_BAND*Fs_carrier/length(BASE_BAND_RECEIVED_SIGNAL),abs(BASE_BAND_RECEIVED_SIGNAL), 'g')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on 

BW = 30000;
F_stop = BW/2+20000;              
F_pass = BW/2;                    
A_stop = 60;                      
A_pass = 1;                       

low_pass_filter = fdesign.lowpass(F_pass, F_stop, A_pass, A_stop, 15*Fs);
low_pass_filter = design(low_pass_filter, 'butter');
Base_Band_received_signal_LPF  = filter(low_pass_filter, Base_Band_received_signal);
BASE_BAND_RECEIVED_SIGNAL_LPF  = fftshift(fft(Base_Band_received_signal_LPF));
f_RECEIVED_SIGNAL_LPF = (-length(BASE_BAND_RECEIVED_SIGNAL_LPF)/2:1:length(BASE_BAND_RECEIVED_SIGNAL_LPF)/2-1)';
subplot(2,1,2)
plot(f_RECEIVED_SIGNAL_LPF*Fs_carrier/length(BASE_BAND_RECEIVED_SIGNAL_LPF), abs(BASE_BAND_RECEIVED_SIGNAL_LPF), 'r')
title('Base Band stage after LPF')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
grid on

% Resample and play audio
Base_Band_received_signal_LPF = 4*resample(Base_Band_received_signal_LPF, 1, 15);
sound(Base_Band_received_signal_LPF, Fs)
