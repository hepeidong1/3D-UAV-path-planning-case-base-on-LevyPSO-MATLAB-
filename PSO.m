clc
clear

% 问题定义
MapModel =  CreatModel('test');
CostFunction = @(Solution) CostFunc(Solution,MapModel);
VarMin = [];
VarMax = [];
for i = 1:MapModel.PointNum
    VarMin = [VarMin MapModel.IndexXmin+3 MapModel.IndexYmin+3 1.25*MapModel.Zmin];
    VarMax = [VarMax MapModel.IndexXmax-3 MapModel.IndexYmax-3 1.25*MapModel.Zmax];
end
nVar = 3*MapModel.PointNum;
nPop = 100;
MaxIt = 1000;

% Lower and upper Bounds of particles (Variables)
lb.x=MapModel.IndexXmin;           
ub.x=MapModel.IndexXmax;           
lb.y=MapModel.IndexYmin;           
ub.y=MapModel.IndexYmax;           
lb.z=MapModel.Zmin;           
ub.z=MapModel.Zmax;                 

ub.r=3*2*norm(MapModel.StartPoint-MapModel.EndPoint)/nVar;       % 步长限制    
lb.r=0;

% Inclination (elevation)
AngleRange = pi/4; % 角度范围
lb.psi=-AngleRange;            
ub.psi=AngleRange;          


% Azimuth 
% Determine the angle of vector connecting the start and end points
dirVector = MapModel.EndPoint - MapModel.StartPoint;
phi0 = atan2(dirVector(2),dirVector(1));
lb.phi=phi0 - AngleRange;           
ub.phi=phi0 + AngleRange;           

% Lower and upper Bounds of velocity 速度范围
alpha=0.5;
Velub.r=alpha*(ub.r-lb.r);    
Vellb.r=-Velub.r;                    
Velub.psi=alpha*(ub.psi-lb.psi);    % 俯仰角
Vellb.psi=-Velub.psi;                    
Velub.phi=alpha*(ub.phi-lb.phi);    % 转角
Vellb.phi=-Velub.phi;  

%% 问题定义
VarSize=[1 nVar];   % 迭代矩阵的大小

%% 算法参数
w=1;            % 惯性指数
wdamp=0.99;     % 惯性指数下降速度
c1=1.5;         % 个体学习因数
c2=2.0;         % 全局学习因数

% 速度限制
VelMax=0.1*(VarMax-VarMin);
VelMin=-VelMax;

%% 初始化种群

empty_particle.Position=[];
empty_particle.Cost=[];
empty_particle.Velocity=[];
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];

particle=repmat(empty_particle,nPop,1);
GlobalBest.Cost=inf;

% Initialization Loop
isInit = false;
while (~isInit)
        disp("初始化随机路线...");
   for i=1:nPop
        % Initialize Position
        Solution(i)=CreateRandomSolution(VarSize,lb,ub);  %随机撒点
        particle(i).Position=SolutionToPraticle(Solution(i),MapModel);

        % Initialize Velocity 
        particle(i).Velocity=zeros(VarSize);

        % Evaluation
        particle(i).Cost= CostFunction(particle(i).Position);  %模型评估

        % Update Personal Best
        particle(i).Best.Position=SolutionToPraticle(Solution(i),MapModel);
        particle(i).Best.Cost=particle(i).Cost;
   end
   for i=1:nPop
        % Update Global Best
        if particle(i).Best.Cost < GlobalBest.Cost
            GlobalBest=particle(i).Best;
            isInit = true;
        end
    end
end

%% 迭代过程

IsOutside(nPop,:) = false(VarSize);
BestCost=zeros(MaxIt,1);
for it=1:MaxIt

    parfor i=1:nPop %代价函数计算复杂(1min)时这里改 parfor
        % 更新速度
        particle(i).Velocity = w*particle(i).Velocity ...
            +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
            +c2*rand(VarSize).*(GlobalBest.Position-particle(i).Position) + Levy(VarSize,particle(i).Position,particle(i).Best.Position);
        
        % 速度限制
        particle(i).Velocity = max(particle(i).Velocity,VelMin);
        particle(i).Velocity = min(particle(i).Velocity,VelMax);
        
        % 更新位置
        particle(i).Position = particle(i).Position + particle(i).Velocity;
        
        % 超出范围则速度变为反向
        IsOutside(i,:) = (particle(i).Position<VarMin | particle(i).Position>VarMax);
        particle(i).Velocity(IsOutside(i,:))=-particle(i).Velocity(IsOutside(i,:));
        
        % 位置限制
        particle(i).Position = max(particle(i).Position,VarMin);
        particle(i).Position = min(particle(i).Position,VarMax);
        
        % 评估
        particle(i).Cost = CostFunction(particle(i).Position);
        
        % 更新个体最优位置
        if particle(i).Cost<particle(i).Best.Cost
            
            particle(i).Best.Position=particle(i).Position;
            particle(i).Best.Cost=particle(i).Cost;
              
        end
        
    end
    for i=1:nPop
            % 更新全局最优位置
        if particle(i).Best.Cost<GlobalBest.Cost
                
                GlobalBest=particle(i).Best;
                
        end 
    end
    
    BestCost(it)=GlobalBest.Cost;
    
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    
    w=w*wdamp;
    
end

%% 赋值区
BestPosition     = GlobalBest.Position;
BestScore        = GlobalBest.Cost;
ConvergenceCurve = BestCost;

%% 结果展示

PlotSolution(BestPosition,MapModel)


function Levy_Velocity = Levy(VarSize,Position,Pbest)
    beta = 1.5 ;
    sigma_u = (gamma(1+beta)*sin(pi*beta/2)/(beta*gamma((1+beta)/2)*2^((beta-1)/2)))^(1/beta) ;
    sigma_v = 1 ;
    u = normrnd(0,sigma_u,VarSize) ;
    v = normrnd(0,sigma_v,VarSize) ;
    step = u./(abs(v).^(1/beta)) ;
    l = 0.02 * abs(Position-Pbest); 
    Levy_Velocity =rand(VarSize).* l.* step;
end

% Convert the solution from spherical space to Cartesian coordinates

function Position = SolutionToPraticle(sol,MapModel)

Position = [];

    % Start location
    xs = MapModel.StartPoint(1);
    ys = MapModel.StartPoint(2);
    zs = MapModel.StartPoint(3);
    
    % Solution in Sperical space
    r = sol.r;
    psi = sol.psi;
    phi = sol.phi;
    
    % First Cartesian coordinate
    x(1) = xs + r(1)*cos(psi(1))*sin(phi(1));
    
    % Check limits
    if x(1) > MapModel.IndexXmax
        x(1) = MapModel.IndexXmax;
    end
    if x(1) < MapModel.IndexXmin
        x(1) = MapModel.IndexXmin;
    end 
    
    y(1) = ys + r(1)*cos(psi(1))*cos(phi(1));
    if y(1) > MapModel.IndexYmax
        y(1) = MapModel.IndexYmax;
    end
    if y(1) < MapModel.IndexYmin
        y(1) = MapModel.IndexYmin;
    end
    
    z(1) = zs + r(1)*sin(psi(1));
    if z(1) > MapModel.Zmax
        z(1) = MapModel.Zmax;
    end
    if z(1) < MapModel.Zmin
        z(1) = MapModel.Zmin;
    end  
    Position = [Position, x(1) y(1) z(1)];

    % Next Cartesian coordinates
    for i = 2:MapModel.PointNum
        x(i) = x(i-1) + r(i)*cos(psi(i))*sin(phi(i));
        if x(i) > MapModel.IndexXmax
            x(i) = MapModel.IndexXmax;
        end
        if x(i) < MapModel.IndexXmin
            x(i) = MapModel.IndexXmin;
        end 

        y(i) = y(i-1) + r(i)*cos(psi(i))*cos(phi(i));
        if y(i) > MapModel.IndexYmax
            y(i) = MapModel.IndexYmax;
        end
        if y(i) < MapModel.IndexYmin
            y(i) = MapModel.IndexYmin;
        end

       % z(i) = z(i-1) + r(i)*cos(psi(i));
        z(i) = z(i-1) + r(i)*sin(psi(i));
        if z(i) > MapModel.Zmax
            z(i) = MapModel.Zmax;
        end
        if z(i) < MapModel.Zmin
            z(i) = MapModel.Zmin;
        end 
        Position = [Position, x(i) y(i) z(i)];
    end

end