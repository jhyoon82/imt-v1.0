function [tmpl] = Tracker_appearance_learning(tmpl,opt,est_index)

for i=1:opt.num_tracker
    if( i~= est_index)
        tmpl(i).Wimgs = [tmpl(i).Wimgs, tmpl(i).wimg(:)];
    end
end
%% Feature Update based on Incremental PCA
for i=1:opt.num_tracker
    if (size(tmpl(i).Wimgs,2) >= opt.batchsize)
        if (~isempty(tmpl(i).coef) )
            if(~isempty(tmpl(i).coef))
                ncoef = size(tmpl(i).coef,2);
                recon = repmat(tmpl(i).mean(:),[1,ncoef]) + tmpl(i).basis * tmpl(i).coef;
                [tmpl(i).basis, tmpl(i).eigval, tmpl(i).mean, tmpl(i).numsample] = ...
                    sklm(tmpl(i).Wimgs, tmpl(i).basis, tmpl(i).eigval, tmpl(i).mean, tmpl(i).numsample, opt.ff);
                tmpl(i).coef = tmpl(i).basis'*(recon - repmat(tmpl(i).mean(:),[1,ncoef]));
                tmpl(i).recon = recon;
            end
        else
            [tmpl(i).basis, tmpl(i).eigval, tmpl(i).mean, tmpl(i).numsample] = ...
                sklm(tmpl(i).Wimgs, tmpl(i).basis, tmpl(i).eigval, tmpl(i).mean, tmpl(i).numsample, opt.ff);
        end
        
        tmpl(i).Wimgs = [];
        
        if (size(tmpl(i).basis,2) > opt.maxbasis)
            tmpl(i).reseig = opt.ff * tmpl(i).reseig + sum(tmpl(i).eigval(opt.maxbasis+1:end));
            tmpl(i).basis  = tmpl(i).basis(:,1:opt.maxbasis);
            tmpl(i).eigval = tmpl(i).eigval(1:opt.maxbasis);
            
            if(~isempty(tmpl(i).coef))
                tmpl(i).coef = tmpl(i).coef(1:opt.maxbasis,:);
            end
            
        end
    end
end