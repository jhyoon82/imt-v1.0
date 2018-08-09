% ========================= Last Updated Code 20131110
% Ju Hong Yoon
% Gwangju Institute of Science and Technology (GIST)
% jhyoon@gist.ac.kr // jh.yoon82@gmail.com
% cvl.gist.ac.kr

clc
clear all
warning off


for EX = 14:16
   
    
    
    % path
    addpath('ats_func');
    addpath('ats_func\ivt');
    addpath('ats_func\features');
    addpath('ats_func\features\HOG_Lib\piotr_toolbox_V2.60\toolbox\images');
    
    
    if(EX==1)
        seq_name = 'david';
        Init = [122, 58, 75, 97, 0];
    elseif(EX==2)
        seq_name = 'girl';
        Init = [128, 46, 104, 127, 0];
    elseif(EX==3)
        seq_name = 'football';
        Init = [310, 102, 39, 50, 0];
    elseif(EX==4)
        seq_name = 'Oneleave';
        Init = [130, 132, 31, 115, 0];
    elseif(EX==5)
        seq_name = 'woman';
        Init = [203, 107, 30, 92, 0];
    elseif(EX==6)
        seq_name = 'singer1';
        Init = [51, 53, 87, 290, 0];
    elseif(EX==7)
        seq_name = 'sylv';
        Init = [121, 58, 51, 50, 0];
    elseif(EX==8)
        seq_name = 'trellis';
        Init = [146, 54, 68, 101, 0];
    elseif(EX==9)
        seq_name = 'tiger1';
          Init = [116, 43, 42, 46, 0];
    elseif(EX==10)
        seq_name = 'coke';
        Init = [149, 80, 24, 40, 0];
    elseif(EX==11)
        seq_name = 'startrek';
        Init = [21, 33, 40, 30];
    elseif(EX==12)
        seq_name = 'starwars';
        Init = [400, 50, 40, 50, 0];
    elseif(EX==13)
        seq_name = 'deer';
        Init = [306, 5, 95, 65, 0];
    elseif(EX==14)
        seq_name = 'jumping';
        Init = [147, 110, 34, 33];
    elseif(EX==15)
        seq_name = 'board';
        Init = [57,167,190,148, 0];
    elseif(EX==16)
        seq_name = 'lemming';
        Init = [40,199,61,103,0];
    end
    data_path = 'data\';
    
    % parameter initialization
    init_param_ats
    opt.feat_fast = 1;
    opt.cov_tlf = [0.5 0.5 0.5];
    
    
    % TPM initialization
    param = [];
    param = TPM_Initialization(A1,A2,A3,param);
    %     param.TPM = (1/3)*ones(3,3); % Naive TPM Initialization
    
    % Initial bounding box
    Initial_Box = [Init(1)+Init(3)/2, Init(2)+Init(4)/2, Init(3), Init(4), 0]; % [upper center (u,v), width, height]
    
    % The number of previous frames used as positive samples.
    % Load data
    disp('Loading data...');
    fullPath = [data_path, seq_name, '\'];
    d = dir([fullPath, '*.jpg']);
    if size(d, 1) == 0
        d = dir([fullPath, '*.png']);
    end
    if size(d, 1) == 0
        d = dir([fullPath, '*.bmp']);
    end
    im = imread([fullPath, d(1).name]);
    data = zeros(size(im, 1), size(im, 2), size(d, 1));
    for i = 1 : size(d, 1)
        im = imread([fullPath, d(i).name]);
        if ndims(im) == 2
            data(:, :, i) = im;
        else
            data(:, :, i) = rgb2gray(im);
        end
    end
    
    
    
    % Initial Image Sequence Call
    Frame = data(:,:,1);
    if(size(Frame,2)>320)
        v_r = size(Frame,1)/240;
        u_r = size(Frame,2)/320;
        Frame = imresize(Frame, [240 320]);
        GrayFrame = Frame;
    else
        GrayFrame = Frame;
        u_r = 1; v_r = 1;
    end
    opt.u_r = u_r; opt.v_r = v_r;
    opt.img_sz = size(GrayFrame);
    opt.offset = 10^-50;
    
    
    % Frame Length
    FrameLength = size(d,1);
    
    % Tracker Initialization
    tmpl = [];
    [tmpl, param] = Tracker_Initialization(GrayFrame, Initial_Box, opt,param, tmpl);
    
     
    %% Result
    
    Est_Result = param.est; % Tracking Result
    est_box = obtain_center(opt.tmplsize, param.est); % [center (u,v) , width, height]
    est_box(1) = est_box(1)*opt.u_r; est_box(3) = est_box(3)*opt.u_r;
    est_box(2) = est_box(2)*opt.v_r; est_box(4) = est_box(4)*opt.v_r;
    estimated_box = [est_box(1)-est_box(3)/2,est_box(2)-est_box(4)/2,est_box(3),est_box(4)]; % [left upper (u,v) , width, height]
    TXT_EST = estimated_box;
    %% Draw result
    figure(1)
    set(gca,'Position',[0,0,1,1],'visible','off');
    imshow(uint8(GrayFrame));
    axis tight off;
    drawbox(opt.tmplsize, param.est, 'Color','r', 'LineWidth',5);
    FigurePath = ['result_figure\',seq_name,'\',num2str(1),'.jpg'];
    imwrite(frame2im(getframe(gcf)),FigurePath);
    hold off
    
    
     %%  Tracking
     for f=2:FrameLength
        tic
        disp(['frame: ',num2str(f)]);
        
        % Loading image sequence
        Frame = uint8(data(:, :, f));
        if(size(Frame,2)>320)
            Frame = imresize(Frame, [240 320]);
            GrayFrame = double((Frame));
        else
            GrayFrame = double((Frame));
        end
        
        
        % Tracker Interaction
        if(f==2)
            for i=1:opt.num_tracker
                tmpl(i).sample = repmat(affparam2geom(param.est(:)), [1, opt.numsample]);
            end
        else
            [tmpl] = TrackerInteraction(tmpl,opt,param);
        end
        
        % Sampling
        %         [tmpl] = sampling_state(tmpl,opt,param);
        
        
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

        
        % Tracking an object
        [tmpl] = Tracking_Object(tmpl,opt,GrayFrame);
        
        
        % Tracker Likelihood Function
        [tmpl] = Tracker_Likelihood_Function(tmpl,opt,GrayFrame);
        
        
        % TPM and Tracker Probability Update
        [tmpl,param] = TPM_TrackerProb_Update(tmpl, opt, param);
        
        
        % Selecting the best tracker
        Check = tmpl(1).tracker_prob;
        est_index = 1;
        for i=2:opt.num_tracker
            Check2  = tmpl(i).tracker_prob;
            if(Check2>Check)
                Check = Check2;
                est_index = i;
            end
        end
        
        [maxprob,maxidx] = max(tmpl(est_index).conf);
        param.estPrev = param.est; % previous estimated state
        param.est = affparam2mat(tmpl(est_index).sample(:,maxidx)); % current estimated state
        param.estTemp = warpimg(GrayFrame, param.est, opt.tmplsize);
        param.translation(1:2) = (param.est(1:2)-param.estPrev(1:2));
        
        
        % Appearance Learning
        [tmpl] = TLF_appearance_learning(tmpl, opt, param, GrayFrame,f,est_index);
        [tmpl] = Tracker_appearance_learning(tmpl,opt,est_index);
        
        toc
        
        %% Draw result
        figure(1)
        set(gca,'Position',[0,0,1,1],'visible','off');
        imshow(uint8(GrayFrame));
        axis tight off;
        drawbox(opt.tmplsize, param.est, 'Color','r', 'LineWidth',5);
        FigurePath = ['result_figure\',seq_name,'\',num2str(f),'.png'];
        imwrite(frame2im(getframe(gcf)),FigurePath);
        hold off
        
        
        Est_Result = [Est_Result param.est];
        
        %% Store Result in txt
        est_box = obtain_center(opt.tmplsize, param.est); % [center (u,v) , width, height]
        est_box(1) = est_box(1)*opt.u_r; est_box(3) = est_box(3)*opt.u_r;
        est_box(2) = est_box(2)*opt.v_r; est_box(4) = est_box(4)*opt.v_r;
        estimated_box = [est_box(1)-est_box(3)/2,est_box(2)-est_box(4)/2,est_box(3),est_box(4)]; % [left upper (u,v) , width, height]
        TXT_EST = [TXT_EST; estimated_box];
        
    end
    
    %% Store Result in txt
    file_name = [seq_name, '_imt_irm.txt'];
    fid= fopen(file_name,'w');
    SIZE = size(TXT_EST,1);
    for i=1:SIZE
        fprintf(fid,'%d,%d,%d,%d\n',TXT_EST(i,:)); % [(left upper u v) W H]
    end
    fclose(fid);
    
    
    
    
end




