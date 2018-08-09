function [tmpl] = sampling_state(tmpl,opt,param)


for i=1:opt.num_tracker
    % Method 3
    IND_Dynamic = [];
    IND_RandomWalk = [];
    for j=1:tmpl(i).numparticle
        if(rand>=.5)
            IND_Dynamic = [IND_Dynamic j];
        else
            IND_RandomWalk = [IND_RandomWalk j];
        end
    end
    Siz_Dynamic = size(IND_Dynamic,2);
    tmpl(i).sample(:,IND_Dynamic) = tmpl(i).sample(:,IND_Dynamic) + repmat(param.translation,1,Siz_Dynamic) + diag([opt.affsig2]')*randn(6,Siz_Dynamic);
    Siz_RandomWalk = size(IND_RandomWalk,2);
    tmpl(i).sample(:,IND_RandomWalk) = tmpl(i).sample(:,IND_RandomWalk) + diag([opt.affsig1]')*randn(6,Siz_RandomWalk);
    
    % relocate samples out of image
    X_ind1 = find(tmpl(i).sample(1,:)<1); tmpl(i).sample(1,X_ind1) = 1;
    Y_ind1 = find(tmpl(i).sample(2,:)<1); tmpl(i).sample(2,Y_ind1) = 1;    
    X_ind2 = find(tmpl(i).sample(1,:)>320); tmpl(i).sample(1,X_ind2) = 320;
    Y_ind2 = find(tmpl(i).sample(2,:)>240); tmpl(i).sample(2,Y_ind2) = 240;
end