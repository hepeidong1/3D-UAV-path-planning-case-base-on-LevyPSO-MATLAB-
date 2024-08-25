function MapModel = CreatModel(method)
    
switch method
    case 'test'
        % 参数 越大图约精细
        MapLength = 300;

        X=linspace(0,1,MapLength)';
        Y=linspace(0,1,MapLength)';
        CL=(-cos(X*2*pi)+1).^.2;
        H0=(X-.5)'.^2+(X-.5).^2;
        H = (abs(ifftn(exp(7i*rand(MapLength))./H0.^.9)).*(CL*CL')).^(0.5)*30;
        
        Threat = [0.300000000000000	0.500000000000000	0.0800000000000000;
            0.600000000000000	0.200000000000000	0.0700000000000000;
            0.500000000000000	0.400000000000000	0.0600000000000000;
            0.500000000000000	0.350000000000000	0.0800000000000000;
            0.750000000000000	0.750000000000000	0.0800000000000000;
            0.350000000000000	0.200000000000000	0.0700000000000000;
            0.700000000000000	0.550000000000000	0.0700000000000000;
            0.150000000000000	0.350000000000000	0.0600000000000000;
            0.200000000000000	0.800000000000000	0.0700000000000000;
            0.500000000000000	0.800000000000000	0.0800000000000000;
            0.500000000000000	0.600000000000000	0.0500000000000000;];
        ThreatNum = size(Threat,1);

        MapModel.ThreatNum = ThreatNum;
        MapModel.Threat = Threat;

        MapModel.X = X';
        MapModel.Y = Y';
        MapModel.H = H;

        MapModel.IndexXmin = 1;
        MapModel.IndexXmax = MapLength;
        MapModel.IndexYmin = 1;
        MapModel.IndexYmax = MapLength;

        MapModel.Xmin = X(1);
        MapModel.Xmax = X(MapLength);
        MapModel.Ymin = Y(1);
        MapModel.Ymax = Y(MapLength);
        MapModel.Zmin = min(H,[],"all");
        MapModel.Zmax = max(H,[],"all");

        MapModel.PointNum = 8;
        MapModel.StartPoint = [10,10,H(10,10)+0.4*(MapModel.Zmax - MapModel.Zmin)];
        MapModel.EndPoint = [MapLength-10,MapLength-10,H(MapLength-10,MapLength-10)+0.4*(MapModel.Zmax - MapModel.Zmin)];

        MapModel.View = [41,56];
        
        clear X Y CL H0 H MapLength ThreatNum Threat

    case 'real'
        load data.mat %#ok<LOAD>
        % 参数 越大图约粗糙 需为整数
        Spite = 10;

        X = 1:Spite:size(Terrain,1);
        Y = 1:Spite:size(Terrain,2);
        Z = Terrain(X,Y);

        Threat = [0.300000000000000	0.500000000000000	0.0800000000000000;
            0.600000000000000	0.200000000000000	0.0700000000000000;
            0.500000000000000	0.400000000000000	0.0600000000000000;
            0.500000000000000	0.350000000000000	0.0800000000000000;
            0.750000000000000	0.750000000000000	0.0800000000000000;
            0.350000000000000	0.200000000000000	0.0700000000000000;
            0.700000000000000	0.550000000000000	0.0700000000000000;
            0.150000000000000	0.350000000000000	0.0600000000000000;
            0.200000000000000	0.800000000000000	0.0700000000000000;
            0.500000000000000	0.800000000000000	0.0800000000000000;
            0.500000000000000	0.600000000000000	0.0500000000000000;].*[X(size(X,2)),Y(size(Y,2)),0.5*(X(size(X,2))+Y(size(Y,2)))];
        ThreatNum = size(Threat,1);

        MapModel.ThreatNum = ThreatNum;
        MapModel.Threat = Threat;

        % Model.IndexX = 1:size(X,2);
        % Model.IndexY = 1:size(Y,2);
        MapModel.X = X;
        MapModel.Y = Y;
        MapModel.H = Z;

        MapModel.IndexXmin = 1;
        MapModel.IndexXmax = size(X,2);
        MapModel.IndexYmin = 1;
        MapModel.IndexYmax = size(Y,2);

        MapModel.Xmin = X(1);
        MapModel.Xmax = X(size(X,2));
        MapModel.Ymin = Y(1);
        MapModel.Ymax = Y(size(Y,2));
        MapModel.Zmin = min(Z,[],"all");
        MapModel.Zmax = max(Z,[],"all");

        MapModel.PointNum = 10;
        MapModel.StartPoint = [5,5,Z(5,5)];
        MapModel.EndPoint = [size(X,2)-5,size(Y,2)-5,Z(size(X,2)-5,size(X,2)-5)];
        clear X Y Z Spite xi yi Terrain

        MapModel.View = [19.8,65.5];

        case 'city'
        load data.mat %#ok<LOAD>
        % 参数 越大图约粗糙 需为整数
        Spite = 10;

        X = 1:Spite:size(Terrain,1);
        Y = 1:Spite:size(Terrain,2);
        Z = Terrain(X,Y);

        Threat = [0.300000000000000	0.500000000000000	0.0800000000000000;
            0.600000000000000	0.200000000000000	0.0700000000000000;
            0.500000000000000	0.400000000000000	0.0600000000000000;
            0.500000000000000	0.350000000000000	0.0800000000000000;
            0.750000000000000	0.750000000000000	0.0800000000000000;
            0.350000000000000	0.200000000000000	0.0700000000000000;
            0.700000000000000	0.550000000000000	0.0700000000000000;
            0.150000000000000	0.350000000000000	0.0600000000000000;
            0.200000000000000	0.800000000000000	0.0700000000000000;
            0.500000000000000	0.800000000000000	0.0800000000000000;
            0.500000000000000	0.600000000000000	0.0500000000000000;].*[X(size(X,2)),Y(size(Y,2)),0.5*(X(size(X,2))+Y(size(Y,2)))];
        ThreatNum = size(Threat,1);

        MapModel.ThreatNum = ThreatNum;
        MapModel.Threat = Threat;

        % Model.IndexX = 1:size(X,2);
        % Model.IndexY = 1:size(Y,2);
        MapModel.X = X;
        MapModel.Y = Y;
        MapModel.H = Z;

        MapModel.IndexXmin = 1;
        MapModel.IndexXmax = size(X,2);
        MapModel.IndexYmin = 1;
        MapModel.IndexYmax = size(Y,2);

        MapModel.Xmin = X(1);
        MapModel.Xmax = X(size(X,2));
        MapModel.Ymin = Y(1);
        MapModel.Ymax = Y(size(Y,2));
        MapModel.Zmin = min(Z,[],"all");
        MapModel.Zmax = max(Z,[],"all");

        MapModel.PointNum = 10;
        MapModel.StartPoint = [5,5,Z(5,5)];
        MapModel.EndPoint = [size(X,2)-5,size(Y,2)-5,Z(size(X,2)-5,size(X,2)-5)];
        clear X Y Z Spite xi yi Terrain

        MapModel.View = [19.8,65.5];

end

end

