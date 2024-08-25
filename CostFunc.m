function cost = CostFunc(Sol,MapModel)
    %% COSTFUNCTION 此处显示有关此函数的摘要
    SolLong = size(Sol,2)/3;
    Solution = reshape(Sol,3,SolLong)';
    Jinf = 1000;

    PointN = MapModel.PointNum + 2;
    
    xindex = round(Solution(:,1));
    yindex = round(Solution(:,2));
    xReal = MapModel.X;
    yReal = MapModel.Y;
    zReal = MapModel.H;
    x = xReal(xindex(:))';
    y = yReal(yindex(:))';
    z = Solution(:,3);
    xIndex = [MapModel.IndexXmin xindex' MapModel.IndexXmax];
    yIndex = [MapModel.IndexYmin yindex' MapModel.IndexYmax];
    
    % 起点位置
    xs=xReal(MapModel.StartPoint(1));
    ys=yReal(MapModel.StartPoint(2));
    zs=MapModel.StartPoint(3);
    
    % 终点位置
    xf=xReal(MapModel.EndPoint(1));
    yf=yReal(MapModel.EndPoint(2));
    zf=MapModel.EndPoint(3);
    
    x_all = [xs x' xf];
    y_all = [ys y' yf];
    z_all = [zs z' zf];

    %% J1 - 额外路径长度代价    以起点和终点二范数为标准 是个百分比
    J1 = 0;
    J1Standard = norm([xs-xf,ys-yf,zs-zf]);
    for i = 1:PointN-1
        diff = [ x_all(i+1)-x_all(i); y_all(i+1)-y_all(i); z_all(i+1)-z_all(i) ];
        J1 = J1 + norm(diff);
    end
    J1 = Jinf*(J1/(J1Standard)-1);

    %% J2 - 威胁代价
    threats = MapModel.Threat;
    threat_num = MapModel.ThreatNum;

    J2 = 0;
    for line = 1:(PointN-1)
        LineStart = [x_all(line),y_all(line),z_all(line)];
        LineEnd = [x_all(line+1),y_all(line+1),z_all(line+1)];
        for threatIndex = 1:threat_num
            DangerDistance = threats(threatIndex,3);
            WarningDiatance = 1.1*threats(threatIndex,3);
            Distance = Distance2Threat(threats(threatIndex,1:2),LineStart(1:2),LineEnd(1:2));
            % disp([num2str(Distance),'   ',num2str(DangerDistance)])
            if Distance>WarningDiatance || all(LineStart==LineEnd)  % 距离威胁足够远
                J2 = J2 + 0;
            elseif Distance>DangerDistance % 在警告距离和危险距离之间
                w = (Distance - DangerDistance)/(WarningDiatance - DangerDistance);
                J2 = J2 + (-Jinf*w.^(0.01)+Jinf);
            else % 在危险距离以内
                J2 = J2 + Jinf;
            end
        end
    end
    J2 = J2/threat_num;
    
    %% J3 - 碰撞代价
    J3 = 0;
    dx = (MapModel.Xmax - MapModel.Xmin)/(MapModel.IndexXmax - MapModel.IndexXmin + 1);
    dy = (MapModel.Ymax - MapModel.Ymin)/(MapModel.IndexYmax - MapModel.IndexYmin + 1);
    CheckR = sqrt(dx^2+dy^2) + 0;% 后面这个零主要看无人机的尺寸，定位的精确度等

    for line = 1:PointN-2
        LineStartIndex = [xIndex(line),yIndex(line),z_all(line)];
        LineEndIndex = [xIndex(line+1),yIndex(line+1),z_all(line+1)];

        % 端点 a b
        a = [xReal(LineStartIndex(1)),yReal(LineStartIndex(2))];
        b = [xReal(LineEndIndex(1)),yReal(LineEndIndex(2))];

        for xi = min(LineStartIndex(1),LineEndIndex(1)):max(LineStartIndex(1),LineEndIndex(1))
            for yi = min(LineStartIndex(2),LineEndIndex(2)):max(LineStartIndex(2),LineEndIndex(2))
                 p = [xReal(xi),yReal(yi)];
                 if (Distance2Point(p,a,b)>CheckR) || all(LineStartIndex(1:2)==LineEndIndex(1:2)) % 排除距离远和一个点的特殊情况
                     J3 = J3 + 0;
                 else
                     ZInMap = zReal(xi,yi);
                     if LineStartIndex(1) == LineEndIndex(1)
                         Weight = (yi-LineStartIndex(2))/(LineEndIndex(2)-LineStartIndex(2));
                     else
                         Weight = (xi-LineStartIndex(1))/(LineEndIndex(1)-LineStartIndex(1));
                     end
                     ZInLine = z_all(line) + (z_all(line+1)-z_all(line))*Weight;
                     % check
                     if (ZInLine-ZInMap)>=0.05*(MapModel.Zmax - MapModel.Zmin) % 保持安全距离
                         J3 = J3 + 0;
                     else
                         J3 = J3 + 10*Jinf;
                     end
                 end
            end
        end
    end

    %% J4 - 目标代价
    J4 = 0;
    VectorToEnd = [x_all(PointN)-x_all(1),y_all(PointN)-y_all(1)];
    for VectorIndex = 1:PointN-1
        LineStart = [x_all(VectorIndex),y_all(VectorIndex),z_all(VectorIndex)];
        LineEnd = [x_all(VectorIndex+1),y_all(VectorIndex+1),z_all(VectorIndex+1)];
        Vector(VectorIndex,1:3) = LineEnd - LineStart;
        
        PersonalAngle = acos(Vector(VectorIndex,1:2)*VectorToEnd'/(norm(Vector(VectorIndex,1:2))*norm(VectorToEnd)));
        PersonalAngle = abs(PersonalAngle/pi*180);
        if PersonalAngle < 60 || all(Vector(VectorIndex,1:2==[0,0]))
            J4 = J4 + 0;
        elseif PersonalAngle < 90
            J4 = J4 + Jinf*(90 - PersonalAngle)/(90 - 60);
        else
            J4 = J4 + Jinf;
        end

    end
    J4 = J4/(PointN-1);

    %% J5 - 平滑代价
    J5 = 0;
    for AngleIndex = 1:PointN-2
        xy1 = Vector(AngleIndex,1:2);
        xy2 = Vector(AngleIndex+1,1:2);
        % 按照弧度式输出
        TurningAngle(AngleIndex) = acos(xy1*xy2'/(norm(xy1)*norm(xy2)));
        ClimbingAngle(AngleIndex) = atan(Vector(AngleIndex,3)/norm(xy1)) - atan(Vector(AngleIndex+1,3)/norm(xy2));
        % 转化为角度
        TurningAngle(AngleIndex) = abs(TurningAngle(AngleIndex)/pi*180);
        ClimbingAngle(AngleIndex) = abs(ClimbingAngle(AngleIndex)/pi*180);


        if TurningAngle(AngleIndex) < 60 || all(xy1==[0,0]) || all(xy2==[0,0])
            J5 = J5 + 0;
        elseif TurningAngle(AngleIndex) < 90
            J5 = J5 + Jinf*(90 - TurningAngle(AngleIndex))/(90 - 60);
        else
            J5 = J5 + 10*Jinf;
        end

        if ClimbingAngle(AngleIndex) < 90 || all(xy1==[0,0]) || all(xy2==[0,0])
            J5 = J5 + 0;
        elseif ClimbingAngle(AngleIndex) < 150
            J5 = J5 + Jinf*(120 - ClimbingAngle(AngleIndex))/(150 - 90);
        else
            J5 = J5 + 10*Jinf;
        end
    end
    J5 = J5/(PointN-2);

    %% 统计输出
    cost = 1*J1 + 30*J2 + 30*J3 + 30*J4 + 5*J5;
end

function x = Distance2Threat(p,a,b)

    Vector_ab = b - a;
    Vector_ap = p - a;
    ProjectionVector = ((Vector_ab*Vector_ap')/(Vector_ab*Vector_ab'))*(Vector_ab);
    ProjectionPoint = a + ProjectionVector;
    % Distance = sqrt((Vector_ap - ProjectionVector)*(Vector_ap - ProjectionVector)');
    
    if ProjectionPoint(1)>min(a(1),b(1)) && ProjectionPoint(1)<max(a(1),b(1)) % 投影点在线段上
        x = sqrt((Vector_ap - ProjectionVector)*(Vector_ap - ProjectionVector)');
    else % 投影点在线段外，返回p到两个端点距离的最小值
        Distance(1) = norm(p-a);
        Distance(2) = norm(p-b);
        x = min(Distance);
    end
end


function Distance = Distance2Point(p,a,b)

    Vector_ab = b - a;
    Vector_ap = p - a;
    ProjectionVector = ((Vector_ab*Vector_ap')/(Vector_ab*Vector_ab'))*(Vector_ab);
    Distance = sqrt((Vector_ap - ProjectionVector)*(Vector_ap - ProjectionVector)');

end