function [Rect1 Rect2] = Haar_Rect_Generation(tmplsize,Param)
% Five filter windows are used to generate Haar Feature
% Less filter window can be selected.
% The computation time is satisfied with 19 by 19 Rectangle
% Param.IntRow = IntRow; % Integral Image Row Size
% Param.IntCol = IntCol; % Integral Image Column Size
% Param.WinNum = 1 to 5;

if (nargin < 2)
    Param.IntRow = tmplsize(1); % Integral Image Row Size
    Param.IntCol = tmplsize(2); % Integral Image Column Size
    Param.WinNum = 2;
end
% FeatureWin = [1 2;2 1;2 2;1 3;3 1];
FeatureWin = [1 2;2 1;2 2;1 3;3 1];
% Row(Length) : X coordinate
% Column(Width)  Y coordinate
if(Param.WinNum==2)
    FeatDim = 1740;
end
if(tmplsize(1)==16)
    FeatDim = 364;
end
if(tmplsize(1)==22)
    FeatDim = 760;
end
if(Param.WinNum==2)
    Rect1 = zeros(FeatDim,4);
    Rect2 = zeros(FeatDim,4);
end
rect_num = 0;
for i=1:Param.WinNum % Feature Window Index
    SizeX = FeatureWin(i,1); % Length
    SizeY = FeatureWin(i,2); % Width
    WinL = SizeX;
    WinW = SizeY;
    
    for x = 2:1:Param.IntRow-SizeX
        for y = 2:1:Param.IntCol-SizeY
            if(i==1)
                FirstRect = [x, y, ((WinW/2)-1), (WinL-1)];
                SecRect = [x, (y+WinW/2), ((WinW/2)-1), (WinL-1)];        
                rect_num = rect_num + 1;
            elseif(i==2)
                FirstRect = [x, y, (WinW-1), ((WinL/2)-1)];
                SecRect = [(x+WinL/2), y, (WinW-1), ((WinL/2)-1)];
                rect_num = rect_num + 1;
            end
          %%
            Row = FirstRect(1); % Row
            Col = FirstRect(2); % Column
            Wid = FirstRect(3); % Width
            Leng = FirstRect(4); % Length
            R1 = Row-1;
            R2 = Row+Leng;
            C1 = Col-1;
            C2 = Col+Wid;
            B1 = R1 + (C1-1)*tmplsize(1);
            B2 = R1 + (C2-1)*tmplsize(1);
            B3 = R2 + (C1-1)*tmplsize(1);
            B4 = R2 + (C2-1)*tmplsize(1);
            FirstRect = [B4, B1, B2, B3];
            Rect1(rect_num,:) = FirstRect;
            
            
          %%
            Row = SecRect(1); % Row
            Col = SecRect(2); % Column
            Wid = SecRect(3); % Width
            Leng = SecRect(4); % Length
            R1 = Row-1;
            R2 = Row+Leng;
            C1 = Col-1;
            C2 = Col+Wid;
            B1 = R1 + (C1-1)*tmplsize(1);
            B2 = R1 + (C2-1)*tmplsize(1);
            B3 = R2 + (C1-1)*tmplsize(1);
            B4 = R2 + (C2-1)*tmplsize(1);
            SecRect = [B4, B1, B2, B3];
            Rect2(rect_num,:) = SecRect;
        end
    end
end
