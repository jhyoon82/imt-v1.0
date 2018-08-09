function [tmpl] = Tracking_Object(tmpl,opt,GrayFrame)

for j = 1:opt.num_tracker
    n = tmpl(j).numparticle;
    sz = size(tmpl(j).mean); % 'i'th template size
    N = sz(1)*sz(2);  % Template Size
    
    % Cropped Tempalte by i-th feature sample
    Gwimgs = warpimg(GrayFrame, affparam2mat(tmpl(j).sample), opt.tmplsize);
    if(j==1) % HOG
        hogwimgs = zeros(tmpl(j).sz,n);
        for i=1:n
            if(opt.feat_fast==0)
                Feature = hogcalculator(Gwimgs(:,:,i),4,4,4,4,9,0.5,'localinterpolate','unsigned','l2hys');
            else
                Feature = hog(Gwimgs(:,:,i),4,9,1);
            end
            hogwimgs(:,i) = Feature(:)/(norm(Feature(:))+ opt.offset);
        end
        wimgs = hogwimgs;
    elseif(j==2) % Intensity
        Gwimgs = reshape(Gwimgs,N,n);
        intenwimgs = zeros(tmpl(j).sz,n);
        for i=1:n
            intenwimgs(:,i) = Gwimgs(:,i)/(norm(Gwimgs(:,i))+ opt.offset);
        end
        wimgs = intenwimgs;
    elseif(j==3) % Haar
        haarwimgs = zeros(tmpl(j).sz,n);
        for i=1:n
            gwimg = Gwimgs(:,:,i);
            [IntegImg]=GenerateIntImage(gwimg);
            Feature = Haar_Feat_ver1(IntegImg,opt.haar_rect);
            haarwimgs(:,i) = Feature(:)/(norm(Feature(:))+ opt.offset);
        end
        wimgs = haarwimgs;
    end
    
    % Compute sample likelihood of each feature
    diff = repmat(tmpl(j).mean(:),[1,n]) - wimgs;
    if (size(tmpl(j).basis,2) > 0)
        coef = tmpl(j).basis'*diff;
        diff = diff - tmpl(j).basis*coef;
        tmpl(j).coef = coef;
    end
 
    
    tmpl(j).conf = exp(-sum(diff.^2)/(tmpl(j).condenssig))';
    tmpl(j).confsum = sum(tmpl(j).conf);
     tmpl(j).conf  =  tmpl(j).conf/tmpl(j).confsum;
    % Estimated Result of each feature tracker
    [maxprob,maxidx] = max(tmpl(j).conf);
    tmpl(j).est = affparam2mat(tmpl(j).sample(:,maxidx));
end