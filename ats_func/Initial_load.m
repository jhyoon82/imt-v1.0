function  [GrayFrame] = Initial_load(DataPath)

Frame = imread(DataPath);

if(size(Frame,1)>240 || size(Frame,2)>320)
    Frame = imresize(Frame, [240 320]);
    GrayFrame = double(rgb2gray(Frame));
else
    GrayFrame = double(rgb2gray(Frame));
end
 