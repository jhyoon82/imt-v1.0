function [tmpl,param] = TPM_TrackerProb_Update(tmpl, opt, param)


% TPM and Tracker Probability Update
LikeliSet = [tmpl(1).cost, tmpl(2).cost, tmpl(3).cost]';
Model_prob_prev = [tmpl(1).tracker_prob, tmpl(2).tracker_prob, tmpl(3).tracker_prob]';
EstTrans = param.TPM;

% Tracker probability update
for j=1:opt.num_tracker
    SumModeProb(j) = 0;
    for i=1:opt.num_tracker
        SumModeProb(j) = SumModeProb(j) + EstTrans(i,j)*tmpl(i).tracker_prob;
    end
end
for j=1:opt.num_tracker
    SumModeProb(j) = SumModeProb(j)*tmpl(j).cost+10^-50;
end
SumModeProb = SumModeProb/sum(SumModeProb);
for j=1:opt.num_tracker
    tmpl(j).tracker_prob = SumModeProb(j);
end

% Transition probability matrix update
SampleProb = zeros(param.num_sample,1);
for i=1:param.num_sample
    basis_prob = ((Model_prob_prev'*param.TPM_Sample{i}*LikeliSet)*(param.SampleProb(i)))/(Model_prob_prev'*EstTrans*LikeliSet);
    SampleProb(i) = max(0.1*(1/param.num_sample),basis_prob); % Minimum sample probability is set to 0.1*(1/param.num_sample)
end
param.SampleProb = SampleProb/sum(SampleProb);
EstTrans = zeros(3,3);
for i=1:param.num_sample
    EstTrans = EstTrans + param.SampleProb(i)*param.TPM_Sample{i};
end
param.TPM = EstTrans;