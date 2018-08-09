
function [tmpl] = Tracker_Likelihood_Function(tmpl,opt,GrayFrame)


for i=1:opt.num_tracker
    Gwimgs = warpimg(GrayFrame, tmpl(i).est, opt.tmplsize);
    LikeliCost = 1;
    if opt.irm == 1
        for j=1:opt.num_tracker
            if(j==1)
                if(opt.feat_fast==0)
                    Feature = hogcalculator(Gwimgs,4,4,4,4,9,0.5,'localinterpolate','unsigned','l2hys');
                else
                    Feature = hog(Gwimgs,4,9,1);
                end
                Tmpl_Est = Feature(:)/(norm(Feature(:)) + opt.offset);
                Ref_Est = tmpl(j).wimg_local(:)/(norm(tmpl(j).wimg_local(:) ));
                diff = Ref_Est(:) - Tmpl_Est(:);
            elseif(j==2)
                Tmpl_Est = Gwimgs(:)/(norm(Gwimgs(:)) + opt.offset);
                Ref_Est = tmpl(j).wimg_local(:)/(norm(tmpl(j).wimg_local(:) ));
                diff = Ref_Est(:) - Tmpl_Est(:);
            elseif(j==3)
                [IntegImg]=GenerateIntImage(Gwimgs);
                Feature = Haar_Feat_ver1(IntegImg,opt.haar_rect);
                Tmpl_Est = Feature(:)/(norm(Feature(:))  + opt.offset);
                Ref_Est = tmpl(j).wimg_local(:)/(norm(tmpl(j).wimg_local(:) ));
                diff = Ref_Est(:) - Tmpl_Est(:);
            end
            Likeli = exp(-sum(diff.^2)/opt.cov_tlf(j));
            LikeliCost = LikeliCost*Likeli;
        end
    end
    % To reduce computational time, a template is divided into 4 sub-templates.
    if opt.rm == 1
        Gwimgs_Sub{1} = Gwimgs(1:opt.subwin,1:opt.subwin);
        Gwimgs_Sub{2} = Gwimgs(opt.subwin+1:opt.tmplsize(1),1:opt.subwin);
        Gwimgs_Sub{3} = Gwimgs(1:opt.subwin,opt.subwin+1:opt.tmplsize(1));
        Gwimgs_Sub{4} = Gwimgs(opt.subwin+1:opt.tmplsize(1),opt.subwin+1:opt.tmplsize(1));
        for j=1:opt.num_tracker
            DistCost = 0;
            for qq = 1:opt.numsubwin;
                Gwimgs_In = Gwimgs_Sub{qq};
                if(j==1)
                    if(opt.feat_fast==0)
                        Feature = hogcalculator(Gwimgs_In,4,4,4,4,9,0.5,'localinterpolate','unsigned','l2hys');
                    else
                        Feature = hog(Gwimgs_In,4,9,1);
                    end
                elseif(j==2)
                    Feature = Gwimgs_In;
                elseif(j==3)
                    IntegImg = GenerateIntImage(Gwimgs_In);
                    Feature = Haar_Feat_ver1(IntegImg,opt.haar_rect2);
                end
                [FeatNorm] = gly_zmuv(Feature(:));
                gly_crop_norm = norm(FeatNorm);
                FeatNorm = FeatNorm/(gly_crop_norm + opt.offset );
                
                
                L1Temp = tmpl(j).L1TempSet{qq};
                OCCTemp = tmpl(j).occtmpl;
                FixT = tmpl(j).fixT{qq}/size(L1Temp,2);
                
                % L1 Solver
                %             l1param.numThreads = 4;
                %             l1param.pos = 'ture';
                l1param.lambda = 0.01;
                l1param.lambda2 = 1;
                l1param.mode = 1;
                l1param.L = length(FeatNorm(:));
                
                InputTemp = [L1Temp OCCTemp FixT];
                coeff = mexLasso(FeatNorm(:), InputTemp, l1param);
                coeff = full(coeff);
                tmpl(i).L1coeff{j,qq} = coeff;
                Cost = (FeatNorm(:) - [L1Temp FixT]*[coeff(1:size(L1Temp,2));coeff(end)]).^2;
                DistCost = DistCost+(sum(Cost));
            end
            Likeli = exp(-DistCost/opt.cov_tlf(j));
            LikeliCost = LikeliCost*Likeli;
            %         Likeli
        end
    end
    tmpl(i).cost =  LikeliCost; % Likelihood
end