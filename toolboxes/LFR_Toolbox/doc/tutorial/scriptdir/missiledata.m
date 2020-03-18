% Data for missile

    g = 32.2;         
    rho = 973.3;      
    a = 1.0364e+03;   
    s = 0.44;         
    m = 13.98;        
    d = 0.75;         
    Iy = 182.5;       

    K1 =     0.0207;  % K1 = 0.7*((rho*s)/(m*a));
    K2 =     1.2320;  % K2 = 0.7*((rho*s*d)/Iy);
    K3 =     0.0116;  % K3 = 0.7*(3.14/180)*((rho*s)/(m*g));

    z3 =   19.3470;   
    z2 =  -31.0084;   
    z1 =   -9.7174;   
    z0 =   -1.9481;   

    m3 =   40.4847;   
    m2 =  -64.1657;   
    m1 =    2.9221;   
    m0 =  -11.8029;   

    kia = 0.7;
    omegaa = 150;

    % alpha nominal
    Al_0 = 0.1745;
    Al_S = 0.1745;

    % mach nominal
    Ma_0 = 3;
    Ma_S = 1;


