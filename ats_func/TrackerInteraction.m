function [tmpl] = TrackerInteraction(tmpl,opt,param)



n =  opt.numsample;
for i=1:opt.num_tracker
    
    %  uniform kernel
    distsample = tmpl(i).sample(1:2,:) - repmat(param.est(1:2),1,n);
    distsample = abs(distsample);
    distsample = sqrt(distsample(1,:).^2+distsample(2,:).^2);
    
    %  Removing out of image and out of kernel in X,Y coordinate
    X_ind1 = find(tmpl(i).sample(1,:)<1);
    Y_ind1 = find(tmpl(i).sample(2,:)<1);
    X_ind2 = find(tmpl(i).sample(1,:)>opt.img_sz(2));
    Y_ind2 = find(tmpl(i).sample(2,:)>opt.img_sz(1));
    Index1 = find(distsample>min(sqrt(opt.affsig1(1)^2+opt.affsig1(2)^2)*2,opt.max_spacing));
    Index = [Index1,X_ind1,Y_ind1,X_ind2,Y_ind2];
    Index1 = unique(Index);
    
    
    Weight = ones(1,n);
    Weight(Index1) = 0;
    tmpl(i).conf = tmpl(i).conf.*Weight(:);
    tmpl(i).conf = tmpl(i).conf/sum(tmpl(i).conf);
end


sample_temp = {};
for i=1:opt.num_tracker
    interacted_tmpl = [];
    for j=1:opt.num_tracker
        Omega_Inter = round(opt.numsample*param.TPM(j,i));
        resampleIndx = resample(tmpl(j).conf,Omega_Inter);
        interacted_tmpl = [interacted_tmpl tmpl(j).sample(:,resampleIndx)];
    end
    if(size(interacted_tmpl,2)>opt.numsample)
        interacted_tmpl(:,end) = [];
    else
        interacted_tmpl(:,opt.numsample) = interacted_tmpl(:,1);
    end
    sample_temp{i} = interacted_tmpl;
     
    
    resample_index = resample(tmpl(i).conf,opt.numsample);
    tmpl(i).sample_before_interaction = tmpl(i).sample(:,resample_index);
end


for i=1:opt.num_tracker
    tmpl(i).sample = sample_temp{i};
    tmpl(i).numparticle = size(tmpl(i).sample,2);
    tmpl(i).conf = (1/tmpl(i).numparticle)*ones(1,tmpl(i).numparticle);
end
