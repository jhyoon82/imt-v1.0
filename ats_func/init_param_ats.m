% Single Tracker Setting

% To get constant tracking results, random seed is used in this code.
% randn('seed',5);
% rand('seed',5);
opt.rm = 1;
opt.irm = 0;
%
opt.num_tracker = 3;
opt.tmplsize = [32,32]; % Template Size
opt.numsample = 600; % The number of Samples for each feature
opt.affsig1 = [6, 6, .01, .02, .000, .001]; % Affine Standard Deviation
opt.affsig2 = [3, 3, .01, .02, .000, .001]; % Affine Standard Deviation
opt.maxbasis = 16; % The number of maximum basis
opt.batchsize = 3;% Or opt.batchsize = 10; (Data batch size)
opt.errfunc = 'L2'; % error function model
opt.ff = 1; % forgetting factor
opt.minopt = optimset; opt.minopt.MaxIter = 25; opt.minopt.Display='off';
opt.Spacing = 2;
opt.subwin = opt.tmplsize(1)/2;
opt.numsubwin = 4;
opt.nT = 25;
opt.delta = 10;
opt.max_spacing = 12;

% TPM grid samples
a12 = [0.7 0.15 0.15]';
a13 = [0.6 0.2 0.2]';
a14 = [0.5 0.25 0.25]';
a15 = [0.4 0.3 0.3]';
a16 = [0.2 0.4 0.4]';
a17 = [0.30 0.35 0.35]';

a22 = [0.15 0.7 0.15]';
a23 = [0.2 0.6 0.2]';
a24 = [0.25 0.5 0.25]';
a25 = [0.3 0.4 0.3]';
a26 = [0.4 0.2 0.4]';
a27 = [0.35 0.3 0.35]';

a32 = [0.15 0.15 0.7]';
a33 = [0.2 0.2 0.6]';
a34 = [0.25 0.25 0.5]';
a35 = [0.3 0.3 0.4]';
a36 = [0.4 0.4 0.2]';
a37 = [0.35 0.35 0.30]';

A1 = [a12 a13 a14 a15 a16 a17];
A2 = [a22 a23 a24 a25 a26 a27];
A3 = [a32 a33 a34 a35 a36 a37];

% Edge feature index
[Rect1 Rect2] = Haar_Rect_Generation(opt.tmplsize);
opt.haar_rect = [Rect1,Rect2];
[Rect1 Rect2] = Haar_Rect_Generation(opt.tmplsize/2);
opt.haar_rect2 = [Rect1,Rect2];