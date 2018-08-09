function [param] = TPM_Initialization(A1,A2,A3,param)

% Intial TPM
NumberOfSamples = size(A1,2)*size(A2,2)*size(A3,2);
ijz = 0;
EstTrans = zeros(3,3);
for i=1:size(A1,2)
    for j=1:size(A2,2)
        for z=1:size(A3,2)
            ijz = ijz + 1;
            tpm_basis = [A1(:,i)  A2(:,j) A3(:,z)];
%             tpm_basis = [A1(:,i)  A2(:,j) A3(:,z)]';
            sample_trans{ijz} = tpm_basis;
            EstTrans = EstTrans + (1/NumberOfSamples)*1*tpm_basis;
        end
    end
end
param.SampleProb = (1/NumberOfSamples)*ones(1,NumberOfSamples); % Sample Probability
param.TPM_Sample = sample_trans;  % Grid Samples
param.TPM = EstTrans; % Initial TPM
% param.TPM = (1/3)*ones(3,3);
param.num_sample = NumberOfSamples;