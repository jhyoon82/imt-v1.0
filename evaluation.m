%% Evaluation

clc
clear

for EX = 1:16
    if(EX==1)
        seq_name = 'david';
    elseif(EX==2)
        seq_name = 'girl';
    elseif(EX==3)
        seq_name = 'football';
    elseif(EX==4)
        seq_name = 'Oneleave';
    elseif(EX==5)
        seq_name = 'woman';
    elseif(EX==6)
        seq_name = 'singer1';
    elseif(EX==7)
        seq_name = 'sylv';
    elseif(EX==8)
        seq_name = 'trellis';
    elseif(EX==9)
        seq_name = 'tiger1';
    elseif(EX==10)
        seq_name = 'coke';
    elseif(EX==11)
        seq_name = 'startrek';
    elseif(EX==12)
        seq_name = 'starwars';
    elseif(EX==13)
        seq_name = 'deer';
    elseif(EX==14)
        seq_name = 'jumping';
    elseif(EX==15)
        seq_name = 'board';
    elseif(EX==16)
        seq_name = 'lemming';
    end
    data_path = 'data\';
    
    
    gt = load([data_path,seq_name,'\groundtruth_rect.txt']);
    et = load(['result\',seq_name,'_imt_irm.txt']);
    
    nframe = size(gt,1);
    
    ov = [];ff=0;
    for f = 1:nframe
        if(sum(gt(f,:))~=0)
            ff = ff + 1;
            ov(ff) = p_computePascalScore(gt(f,:), et(f,:));
        end
    end
    sr = sum(ov>0.5)/size(ov,2);
    disp([seq_name,' :',num2str(sr)]);
end