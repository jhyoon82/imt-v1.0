function [tmpl] = TLF_appearance_learning(tmpl, opt, param, GrayFrame,f,est_index)


Gwimgs = warpimg(GrayFrame, param.est, opt.tmplsize);
estsubTemp{1} = Gwimgs(1:opt.subwin,1:opt.subwin);
estsubTemp{2} = Gwimgs(opt.subwin+1:opt.tmplsize(1),1:opt.subwin);
estsubTemp{3} = Gwimgs(1:opt.subwin,opt.subwin+1:opt.tmplsize(1));
estsubTemp{4} = Gwimgs(opt.subwin+1:opt.tmplsize(1),opt.subwin+1:opt.tmplsize(1));

for i=1:opt.num_tracker
    if(i==1)
        %         Feature = hogcalculator(Gwimgs,4,4,4,4,9,0.5,'localinterpolate','unsigned','l2hys');
        %         Feature = hog(Gwimgs,4,9,1);
        if(opt.feat_fast==0)
            Feature = hogcalculator(Gwimgs,4,4,4,4,9,0.5,'localinterpolate','unsigned','l2hys');
        else
            Feature = hog(Gwimgs,4,9,1);
        end
        
        Tmpl_Est = Feature(:)/(norm(Feature(:)) + opt.offset);
        diff = tmpl(i).mean(:) - Tmpl_Est(:);
        sz = size(tmpl(i).mean);
    elseif(i==2)
        Feature = Gwimgs;
        Tmpl_Est = Gwimgs(:)/(norm(Gwimgs(:)) + opt.offset);
        diff = tmpl(i).mean(:) - Tmpl_Est(:);
        sz = size(tmpl(i).mean);
    elseif(i==3)
        [IntegImg]=GenerateIntImage(Gwimgs);
        Feature = Haar_Feat_ver1(IntegImg,opt.haar_rect);
        Tmpl_Est = Feature(:)/(norm(Feature(:)) + opt.offset);
        diff = tmpl(i).mean(:) - Tmpl_Est(:);
        sz = size(tmpl(i).mean);
    end
    if(size(tmpl(i).inst_refset,2)<opt.delta)
        ANGLE = images_angle(tmpl(i).wimg_local, Feature(:));
        lear_wei = min(0.3*(ANGLE/100), 0.1);
        tmpl(i).wimg_local = (1-lear_wei)*tmpl(i).wimg_local + lear_wei*Feature(:);
        tmpl(i).inst_refset = [tmpl(i).inst_refset,  Feature(:)];
    else
        tmpl(i).inst_refset = [tmpl(i).inst_refset, Feature(:)];
        Mean_Set = tmpl(i).inst_refset(:,size(tmpl(i).inst_refset,2)-opt.delta:size(tmpl(i).inst_refset,2));
        tmpl(i).wimg_local = mean(Mean_Set,2);
        
    end
    tmpl(i).wimg = Tmpl_Est;
    tmpl(i).err = reshape(diff, sz);
    tmpl(i).recon = tmpl(i).wimg + tmpl(i).err;
    
    if opt.rm == 1
        for j=1:opt.numsubwin
            EstTemp = estsubTemp{j};
            if(i==1)%HOG
                %             Feature = hogcalculator(EstTemp,4,4,4,4,9,0.5,'localinterpolate','unsigned','l2hys');
                Feature = hog(EstTemp,4,9,1);
            elseif(i==2)%Intensity
                Feature = EstTemp;
            elseif(i==3)%Haar
                IntegImg = GenerateIntImage(EstTemp);
                Feature = Haar_Feat_ver1(IntegImg,opt.haar_rect2);
            end
            [FeatNorm] = gly_zmuv(Feature(:));
            gly_crop_norm = norm(FeatNorm(:)) + opt.offset;
            FeatNorm = FeatNorm(:)/gly_crop_norm;
            
            
            if(size(tmpl(i).L1TempSet{j},2)<opt.nT)
                tmpl(i).L1TempSet{j} = [tmpl(i).L1TempSet{j} FeatNorm(:)];
                
            else
                % Method 1
                All_Coeff = abs(tmpl(est_index).L1coeff{i,j});
                OCC_Map = All_Coeff(size(tmpl(i).L1TempSet{j},2)+2:end);
                OCC_NO = sum(OCC_Map<0.0001);
                OCC_YES = sum(OCC_Map>0.0001);
                OCC_Ratio = OCC_NO/(OCC_NO+OCC_YES);
                if(OCC_Ratio > 0.7)
                    TCoeff = All_Coeff(1:size(tmpl(i).L1TempSet{j},2));
                    [MinVal MinIndex] = min(TCoeff);
                    tmpl(i).L1TempSet{j}(:,MinIndex) = FeatNorm(:);
                    
                end
            end
        end
    end
end