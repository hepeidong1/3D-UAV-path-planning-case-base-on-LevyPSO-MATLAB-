function [] = PlotModel(MapModel)

% PLOTMODEL  绘制地图
xi = MapModel.X;
yi = MapModel.Y;
[xx,yy] = meshgrid(xi,yi);
Z = MapModel.H;

%% 图片尺寸设置（单位：厘米）
figureUnits = 'centimeters';
figureWidth = 15;
figureHeight = 10;

%% 窗口设置
set(gcf, 'Units', figureUnits, 'Position', [0 0 figureWidth figureHeight]);
set(gca, 'FontName', 'Arial', 'FontSize', 11)
% set(gcf,'Color',[1 1 1])% 背景颜色
% hold on

view(2)


%% 绘图
% 地形
% sc = surfc(xx,yy,Z','linewidth',0.5,'EdgeColor','none','FaceAlpha',0.9);
% sc(2).ZLocation = 'zmax';
surf(xx,yy,Z','linewidth',0.5,'EdgeColor','none','FaceAlpha',0.9);
box on
grid on
light
material dull
view(MapModel.View)
% colormap(TheColor('terrain'))
colorbar
axis tight
axis([MapModel.Xmin MapModel.Xmax MapModel.Ymin MapModel.Ymax MapModel.Zmin MapModel.Zmax+0.25*(MapModel.Zmax-MapModel.Zmin)]);
hold on


% 威胁
threatH = MapModel.Zmax;
threat = MapModel.Threat;
for i = 1:MapModel.ThreatNum

    threatX = threat(i,1);
    threatY = threat(i,2);
    threatR = threat(i,3);

    [SX,SY,SZ] = cylinder(1,150);
    X = threatR*SX+threatX;
    Y = threatR*SY+threatY;
    Z = threatH*SZ;

    Alpha = 0.3;
    surf(X,Y,Z,'FaceColor','b','EdgeColor','none',FaceAlpha=Alpha)
    hold on
    fill3(X(1,:),Y(1,:),Z(1,:),'b','EdgeColor','b',FaceAlpha=Alpha)
    hold on
    fill3(X(1,:),Y(1,:),Z(2,:),'b','EdgeColor','b',FaceAlpha=Alpha)
    hold on
end

Title = title('Trisurf Plot');
set(Title, 'FontSize', 12, 'FontWeight' , 'bold')

XLabel = xlabel('x');
YLabel = ylabel('y');
ZLabel = zlabel('z');
set([XLabel,YLabel,ZLabel], 'FontName',  'Arial', 'FontSize', 11)

end
