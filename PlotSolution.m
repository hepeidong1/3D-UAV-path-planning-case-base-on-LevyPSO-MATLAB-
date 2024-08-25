function [] = PlotSolution(Sol,MapModel)
    %UNTITLED 此处显示有关此函数的摘要
    SolLong = size(Sol,2)/3;
    Solution = reshape(Sol,3,SolLong)';
    
    xindex = round(Solution(:,1));
    yindex = round(Solution(:,2));
    xReal = MapModel.X;
    yReal = MapModel.Y;
    Solution = [ xReal(xindex(:))' yReal(yindex(:))' Solution(:,3)];
    Solution = [xReal(MapModel.StartPoint(1)) yReal(MapModel.StartPoint(2)) MapModel.StartPoint(3);Solution];
    Solution = [Solution;xReal(MapModel.EndPoint(1)) yReal(MapModel.EndPoint(2)) MapModel.EndPoint(3)];
    xyz = Solution';
    PlotModel(MapModel);
    hold on
    [Dim,PointNum]=size(xyz);
    xyzp=zeros(size(xyz));
    smooth = 0.95;
    for k=1:Dim
        xyzp(k,:)=ppval(csaps(1:PointNum,xyz(k,:),smooth),1:PointNum);
    end
    plot3(xyzp(1,:),xyzp(2,:),xyzp(3,:),'r->','LineWidth',2);
    i = 1;
    while 1
        %view(a,b):a是角度，b是仰视角
        view(i,MapModel.View(2));
        pause(0.06);
        i = i+2;
    end
end

