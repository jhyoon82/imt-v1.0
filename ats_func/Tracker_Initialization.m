function [tmpl,param] = Tracker_Initialization3(GrayFrame, Initial_state,opt,param,tmpl)


u_r = opt.u_r;
v_r = opt.v_r;
% Initialize Each Tracker
Initial_state_m(1) = Initial_state(1)/u_r; Initial_state_m(3) = Initial_state(3)/u_r;
Initial_state_m(2) = Initial_state(2)/v_r; Initial_state_m(4) = Initial_state(4)/v_r;
Initial_state_m(5) = Initial_state(5);
param0 = [Initial_state_m(1), Initial_state_m(2), Initial_state_m(3)/opt.tmplsize(1), Initial_state_m(5), Initial_state_m(4)/Initial_state_m(3), 0];
param0 = affparam2mat(param0);
param.est = param0';
param.translation = [0;0;0;0;0;0];
InitialTemplate = warpimg(GrayFrame, param0, opt.tmplsize); % Current Raw Template
for i=1:opt.num_tracker
    if(i==1)%HOG
        if(opt.feat_fast==0)
            Feature  = hogcalculator(InitialTemplate,4,4,4,4,9,0.5,'localinterpolate','unsigned','l2hys');
        else
            Feature = hog(InitialTemplate,4,9,1);
        end         
        
    elseif(i==2)%Intensity
        Feature = InitialTemplate;
    elseif(i==3)%Haar
        IntegImg = GenerateIntImage(InitialTemplate);
        Feature = Haar_Feat_ver1(IntegImg,opt.haar_rect);
    end
    tmpl(i).mean = Feature(:)/(norm(Feature(:))); % Mean Feature
    tmpl(i).est = param0; % Estimated State Vector
    tmpl(i).wimg = tmpl(i).mean;
    tmpl(i).wimg_local = Feature(:);
    tmpl(i).init_temp = Feature(:);
    tmpl(i).numsample = 0;
    tmpl(i).reseig = 0;
    tmpl(i).basis = [];
    tmpl(i).eigval = [];
    tmpl(i).coef = [];
    sz = size(tmpl(i).mean);  N = sz(1)*sz(2);
    tmpl(i).sz = N; % Template size
    tmpl(i).numparticle = round(opt.numsample); % The number of samples
    tmpl(i).conf = (1/tmpl(i).numparticle)*ones(1,tmpl(i).numparticle);
    tmpl(i).Wimgs = []; % The set of estimated templates
    if(i==3)
        tmpl(i).condenssig = 0.1; % Feature Likelihood Covaraince
        tmpl(i).batchsize = 3;
    elseif(i==2)
        tmpl(i).condenssig = 0.1; % Feature Likelihood Covaraince
        tmpl(i).batchsize = 3;
    elseif(i==1)
        tmpl(i).condenssig = 0.1; % Feature Likelihood Covaraince
        tmpl(i).batchsize = 3;
    end
    tmpl(i).tracker_prob = 1/3;
    tmpl(i).inst_refset = Feature(:);
    %     tmpl(i).setlikelihood = [];
end

 


% Model Selection Initial Template into 4 subparts
estsubTemp{1} = InitialTemplate(1:opt.subwin,1:opt.subwin);
estsubTemp{2} = InitialTemplate(opt.subwin+1:opt.tmplsize(1),1:opt.subwin);
estsubTemp{3} = InitialTemplate(1:opt.subwin,opt.subwin+1:opt.tmplsize(1));
estsubTemp{4} = InitialTemplate(opt.subwin+1:opt.tmplsize(1),opt.subwin+1:opt.tmplsize(1));
for i=1:opt.num_tracker
    for j=1:opt.numsubwin
        EstTemp = estsubTemp{j};
        if(i==1)% HOG
%             Feature = hogcalculator(EstTemp,4,4,4,4,9,0.5,'localinterpolate','unsigned','l2hys');
            Feature = hog(EstTemp, 4, 9, 1);
        elseif(i==2)% Intensity
            Feature = EstTemp;
        elseif(i==3)% Haar
            IntegImg = GenerateIntImage(EstTemp);
            Feature = Haar_Feat_ver1(IntegImg,opt.haar_rect2);
        end
        [FeatNorm] = gly_zmuv(Feature(:));
        gly_crop_norm = norm(FeatNorm) + opt.offset;
        FeatNorm = FeatNorm/gly_crop_norm;
        tmpl(i).L1TempSet{j} = FeatNorm(:);
        tmpl(i).fixT{j} = FeatNorm(:);
        
    end
    SizeSubTemp = size(FeatNorm,1);
    tmpl(i).occtmpl = eye(SizeSubTemp);
end