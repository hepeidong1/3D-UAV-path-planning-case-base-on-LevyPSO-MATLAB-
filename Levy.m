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