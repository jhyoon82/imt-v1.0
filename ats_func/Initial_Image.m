function  [opt, GrayFrame] = Initial_Image(DataPath,opt)

Frame = imread(DataPath);

if(size(Frame,1)>240 || size(Frame,2)>320)
    v_r = size(Frame,1)/240; u_r = size(Frame,2)/320;
    Frame = imresize(Frame, [240 320]);
    GrayFrame = double(rgb2gray(Frame));
else
    GrayFrame = double(rgb2gray(Frame));
    u_r = 1; v_r = 1;
end
opt.u_r = u_r; opt.v_r = v_r;  