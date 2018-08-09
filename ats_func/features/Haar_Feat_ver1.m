function [Feature] = Haar_Feat_ver1(IntegImg, Rect)


FeatDim = size(Rect,2);
Feature = zeros(FeatDim,1);
FirstRect = Rect(:,1:4);
SecRect = Rect(:,5:8);
Crop_Img = IntegImg(FirstRect);
Rect1_Img = Crop_Img(:,1)+Crop_Img(:,2)-(Crop_Img(:,3)+Crop_Img(:,4));
Crop_Img = IntegImg(SecRect);
Rect2_Img = Crop_Img(:,1)+Crop_Img(:,2)-(Crop_Img(:,3)+Crop_Img(:,4));
Feature = (Rect2_Img - Rect1_Img)';

