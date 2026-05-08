function PlotSpectrum(Freq,Amp,fileName)

figure('Name', 'Spectrum', 'NumberTitle', 'off');
scatter(Freq(2:end,:), Amp(2:end,:), 50,'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.8);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title(['Spectrum Plot for ', fileName]);
grid on;