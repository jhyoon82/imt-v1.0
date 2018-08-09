function [IntegImg]=GenerateIntImage(IMG)
% Generate Integral Image

% Compute Integral Image
IntegImg =cumsum(cumsum(IMG,2),1);
% IntegImg=padarray(IntegImg,[1 1], 0, 'pre');