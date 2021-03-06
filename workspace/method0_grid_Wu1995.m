function [gamma,hjmin_tT_pdelta,res_req,res_used,Maij,Mbij,Mffijk,Mfij] = method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,varargin)
%%
%
%  File: method0_grid_author.m
%  Directory: 8_published/LPV_L2/workspace
%  Author: Peter Polcz (ppolcz@gmail.com)
%
%  Created on 2020. March 27. (2019b)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some preliminary assignments
% 

% Resolution when approximating hjmin
args.res_hjmin = 11 + p_lim * [0;0];

% Maximum resolution when computing gama
args.res_max = 5;

% Tightening constants
args.delta = 0;
args.T = Inf;

args = parsepropval(args,varargin{:});

res_max    = args.res_max;
delta      = args.delta;
T          = args.T;

if isscalar(res_max)
    res_max = res_max + p_lim * [0;0];
end

if isinf(T) || delta == 0
    res_req = res_max * Inf;
else
    [res_req,hjmin_tT_pdelta,Maij,Mbij,Mffijk,Mfij] = ...
        approximate_necessary_grid_density_Wu1995(A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,args);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Compute upper-bound gamma
% 
% If the grid is not dense enough, the computed value is only an
% approximation.

TMP_WRUEESbUvbMihFnquvuF = pcz_dispFunctionName('Grid-based [Wu, 1995]');


res_used = min( [ res_req res_max ], [], 2 );
M = prod(res_used);

pcz_dispFunction2(strtrim(evalc('display(res_req, ''Required grid resolutions'')')))
pcz_dispFunction2(strtrim(evalc('display(res_used, ''Acutally used grid resolutions'')')))


[A_f,B_f,C_f,D_f] = helper_fh2fh_vec(A_fh,B_fh,C_fh,D_fh,p_lim);

N = numel(bases);
np = size(p_lim,1);
nx = size(A_f(p_lim(:,1)),1);
nu = size(B_f(p_lim(:,1)),2);
ny = size(C_f(p_lim(:,1)),1);

p = sym('p',[np,1]);
dp = sym('dp',[np,1]);
dbases = bases_Jac * dp;

pdp = [
    p
    dp
    ];

He = he;
I = @(varargin) eye(varargin{:});
J = @(range) ones(size(range));

igamma = sdpvar;

Wi = sdpvar(nx*J(1:N));

W = PGenAffineMatrix(Wi,bases,p);

% dW = SUM(j=1:np) diff(W,pj)*dpj
dW = W.set_channels(dbases,pdp);


CONS = [];

if ~isinf(T)

    % norm(Wi,'fro') <= T
    Xi = sdpvar(nx*J(1:N));
    for i = 1:N
        CONS = [ CONS , trace(Xi{i}) <= T , [ I(nx) Wi{i} ; Wi{i}' Xi{i} ] >= 0 ];    
    end
    
end

% Generate grid
lspace = cellfun(@(o) {linspace(o{:})}, num2cell(num2cell([p_lim res_used]),2));
pp = cell(1,np);
[pp{:}] = ndgrid(lspace{:});
pp = cellfun(@(a) {a(:)'}, pp);
pp = vertcat(pp{:});

dpp = P_ndnorms_of_X(dp_lim)';

stat = PStatus(M,100,'Collecting LMI constraints');
for i = 1:M
    stat = stat.progress(i);
    
    pi = pp(:,i);
    
    CONS = [ CONS , W(pi) - delta*I(nx) >= 0 ];
    
    Wpi = W(pi);
    Api = A_f(pi);
    Bpi = B_f(pi);
    Cpi = C_f(pi);
    Dpi = D_f(pi);
    
    % LMI without parameter rate
    Lambda_1 = [
        He{ Wpi*Api } ,  Wpi*Bpi    ,  igamma*Cpi'
        Bpi'*Wpi      , -I(nu)      ,  igamma*Dpi'
        igamma*Cpi    ,  igamma*Dpi , -I(ny)
        ];
          
    % LMI + diag( dW , 0 , 0 )
    for dpj = dpp
        
        Lambda = Lambda_1 + blkdiag( dW([pi;dpj]) , zeros(nu+ny) );
        
        CONS = [CONS , Lambda + delta*I(nx+nu+ny) <= 0 ];
        
    end
end

pcz_dispFunction('Calling the solver..........')

sdps = sdpsettings('solver','mosek','verbose',0);
sol = optimize(CONS,-igamma,sdps);
gamma = 1/double(igamma);

Overall_Time = toc(TMP_WRUEESbUvbMihFnquvuF);
solver_time = sol.solvertime;

pcz_dispFunction
pcz_dispFunction_scalar(gamma, solver_time);
pcz_dispFunction(sol.info);
pcz_dispFunction

strreq = strjoin(cellfun(@(n) {num2str(n)}, num2cell(res_req) ), 'x');
strused = strjoin(cellfun(@(n) {num2str(n)}, num2cell(res_used) ), 'x');

method = sprintf('Req grid for T=%g, delta=%g: %s (Wu, 1995)', T, delta, strreq);

store_results('Results_All', modelname, 0, gamma, solver_time, Overall_Time, ...
    [ strused ', ' sol.info ], method)

%{

W = value(W);
dW = value(dW);

WA_AW_dW_contr = zeros(M,size(dpp,2)+1);
for i = 1:M
    pi = pp(:,i);    
    WA_AW_dW_contr(i,1) = max(abs(eig(He{ W(pi)*A_f(pi) })));
          
    for j = 1:size(dpp,2)
        WA_AW_dW_contr(i,j+1) = max(abs(eig(dW([pi;dpp(:,j)]))));
    end
end

WA_AW_dW_contr(:,2) = max(WA_AW_dW_contr(:,2:end),[],2);
WA_AW_dW_contr(:,3) = WA_AW_dW_contr(:,2) ./ WA_AW_dW_contr(:,1) * 100;
WA_AW_dW_contr(:,4:end) = [];

syms He(WA) Max(dW) perc

WA_AW_dW_contr = vpa([
    He(WA) Max(dW) perc
    WA_AW_dW_contr
    ],5);

pcz_dispFunction2('Contribution of He{WA} compared to that of dW:');
pcz_dispFunction2(evalc('disp(WA_AW_dW_contr)'));

%}
    
pcz_dispFunctionEnd(TMP_WRUEESbUvbMihFnquvuF);

end

function [res_req,hjmin_tT_pdelta,Maij,Mbij,Mffijk,Mfij] = ...
    approximate_necessary_grid_density_Wu1995(A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,args)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Approximate the necessary grid density 

TMP_ajzRhMJbzYfMHEzDwdpD = pcz_dispFunctionName('Grid-based [Wu, 1995] - compute required grid density');

res_hjmin  = args.res_hjmin;
delta      = args.delta;
T          = args.T;

% -------------------------------------------------------------------------
% 1.1 (Arithmetic) tensor dimensions

[A_sym,B_sym,C_sym,D_sym] = helper_fh2sym(A_fh,B_fh,C_fh,D_fh,p_lim);

% Number of basis functions
N = numel(bases);      % i = 1:N

% Number of parameters
np = size(p_lim,1);    % j = 1:np

% Number of elements in matrices A(p) and B(p)
nA = numel(A_sym);     % k = 1:nA
nB = numel(B_sym);     % k = 1:nB

% Number of grid samples
M = prod(res_hjmin);  % l = 1:M

% -------------------------------------------------------------------------
% 1.2. Generate grid

ZERO = sym('ZERO__');
p = sym('p',[np 1]);

lspace = cellfun(@(o) {linspace(o{:})}, num2cell(num2cell([p_lim res_hjmin]),2));
pp = cell(1,np);
[pp{:}] = ndgrid(lspace{:});
pp = cellfun(@(a) {a(:)'}, pp);
pp = [ pp {pp{1}*0} ];


% -------------------------------------------------------------------------
% 1.3. Compute Mfij

bases_Jac_fh = matlabFunction(bases_Jac(:) + ZERO, 'vars', [p;ZERO]);
bases_Jac_val = bases_Jac_fh(pp{:});

Mfij = reshape(max(abs(bases_Jac_val),[],2),size(bases_Jac));

% -------------------------------------------------------------------------
% 1.4. Compute Mffijk

H = jacobian(bases_Jac(:),p);

H_fh = matlabFunction(H(:) + ZERO, 'vars', [p;ZERO]);
H_val = H_fh(pp{:});

Mffijk = reshape(max(abs(H_val),[],2),[N np np]);


% -------------------------------------------------------------------------
% 1.5. Compute Maij

fA_sym = bases * reshape(A_sym,[1 nA]);
fA_sym = fA_sym(:);
assert(all(size(fA_sym) == [N*nA 1]), 'Dimensions are not correct')

dfA_sym = jacobian(fA_sym,p);
dfA_sym = dfA_sym(:);
assert(all(size(dfA_sym) == [N*nA*np 1]), 'Dimensions are not correct')

dfA_fh = matlabFunction(dfA_sym + ZERO, 'vars', [p;ZERO]);
dfA = dfA_fh(pp{:});
assert(all(size(dfA) == [N*nA*np M]), 'Dimensions are not correct')

% dim 1: i (f1 f2 f3)
% dim 2: k (a1 a2 a3 a4)
% dim 3: j (diff w.r.t x an y)
% dim 4: samples in the grid points
dfA = reshape(dfA,[N nA np M]);

% Summation through dim k (to compute the Frobenius norm)
dfA = sqrt(sum(dfA.^2,2));

% Compute maximum along the samples
dfA = max(dfA,[],4);

% Permute the dimensions:
% dim 1: i
% dim 2: j
Maij = permute(dfA,[1 3 2]);


% -------------------------------------------------------------------------
% 1.6. Compute Mbij

fB_sym = bases * reshape(B_sym,[1 nB]);
fB_sym = fB_sym(:);
assert(all(size(fB_sym) == [N*nB 1]), 'Dimensions are not correct')

dfB_sym = jacobian(fB_sym,p);
dfB_sym = dfB_sym(:);
assert(all(size(dfB_sym) == [N*nB*np 1]), 'Dimensions are not correct')

dfB_fh = matlabFunction(dfB_sym + ZERO, 'vars', [p;ZERO]);
dfB = dfB_fh(pp{:});
assert(all(size(dfB) == [N*nB*np M]), 'Dimensions are not correct')

% dim 1: i (f1 f2 f3)
% dim 2: k (a1 a2 a3 a4)
% dim 3: j (diff w.r.t x an y)
% dim 4: samples in the grid points
dfB = reshape(dfB,[N nB np M]);

% Summation through dim k (to compute the Frobenius norm)
dfB = sqrt(sum(dfB.^2,2));

% Compute maximum along the samples
dfB = max(dfB,[],4);

% Permute the dimensions:
% dim 1: i
% dim 2: j
Mbij = permute(dfB,[1 3 2]);


% -------------------------------------------------------------------------
% 1.7. Compute hjmin and the necessary grid resolution

hjmin_tT_pdelta = min([
    
    % upper bound coming from LMI 1: W(p) > delta
    sum(Mfij,1).^(-1)
    
    % Upper bound comming from LMI 2: Lambda(p) < -delta
    sum(2*Maij + Mbij,1) + dp_lim(:,2)' * permute(sum(Mffijk,1),[2 3 1])
    
    ].^(-1),[],1)' * np;

hjmin = hjmin_tT_pdelta * delta / T;

% Necessary grid resolution
res_req = ceil((p_lim * [-1 1 ]') ./ hjmin);

pcz_dispFunction_scalar(T,delta)
pcz_dispFunction2(strtrim(evalc('display(hjmin_tT_pdelta, ''hjmin*T/delta'')')))

pcz_dispFunctionEnd(TMP_ajzRhMJbzYfMHEzDwdpD);

end

function Maij_demo
%% Maij (demo)

syms x y real
syms f1(x,y) f2(x,y) f3(x,y) a1(x,y) a2(x,y) a3(x,y) a4(x,y)

N = 3;
nA = 2*2;
np = 2;
Nr_Samples = 6;

f = [ f1 ; f2 ; f3 ];
A = [ a1 a3 ; a2 a4 ];

fA = f * reshape(A,[nA 1]).'

fA = reshape(fA,[N*nA 1])

dfA = jacobian(fA,[x;y])
dfA = reshape(dfA,[N*nA*np 1])


syms x_f1_a1_1 x_f2_a1_1 x_f3_a1_1 x_f1_a2_1 x_f2_a2_1 x_f3_a2_1 x_f1_a3_1 x_f2_a3_1 x_f3_a3_1 x_f1_a4_1 x_f2_a4_1 x_f3_a4_1 y_f1_a1_1 y_f2_a1_1 y_f3_a1_1 y_f1_a2_1 y_f2_a2_1 y_f3_a2_1 y_f1_a3_1 y_f2_a3_1 y_f3_a3_1 y_f1_a4_1 y_f2_a4_1 y_f3_a4_1 real
syms x_f1_a1_2 x_f2_a1_2 x_f3_a1_2 x_f1_a2_2 x_f2_a2_2 x_f3_a2_2 x_f1_a3_2 x_f2_a3_2 x_f3_a3_2 x_f1_a4_2 x_f2_a4_2 x_f3_a4_2 y_f1_a1_2 y_f2_a1_2 y_f3_a1_2 y_f1_a2_2 y_f2_a2_2 y_f3_a2_2 y_f1_a3_2 y_f2_a3_2 y_f3_a3_2 y_f1_a4_2 y_f2_a4_2 y_f3_a4_2 real
syms x_f1_a1_3 x_f2_a1_3 x_f3_a1_3 x_f1_a2_3 x_f2_a2_3 x_f3_a2_3 x_f1_a3_3 x_f2_a3_3 x_f3_a3_3 x_f1_a4_3 x_f2_a4_3 x_f3_a4_3 y_f1_a1_3 y_f2_a1_3 y_f3_a1_3 y_f1_a2_3 y_f2_a2_3 y_f3_a2_3 y_f1_a3_3 y_f2_a3_3 y_f3_a3_3 y_f1_a4_3 y_f2_a4_3 y_f3_a4_3 real
syms x_f1_a1_4 x_f2_a1_4 x_f3_a1_4 x_f1_a2_4 x_f2_a2_4 x_f3_a2_4 x_f1_a3_4 x_f2_a3_4 x_f3_a3_4 x_f1_a4_4 x_f2_a4_4 x_f3_a4_4 y_f1_a1_4 y_f2_a1_4 y_f3_a1_4 y_f1_a2_4 y_f2_a2_4 y_f3_a2_4 y_f1_a3_4 y_f2_a3_4 y_f3_a3_4 y_f1_a4_4 y_f2_a4_4 y_f3_a4_4 real
syms x_f1_a1_5 x_f2_a1_5 x_f3_a1_5 x_f1_a2_5 x_f2_a2_5 x_f3_a2_5 x_f1_a3_5 x_f2_a3_5 x_f3_a3_5 x_f1_a4_5 x_f2_a4_5 x_f3_a4_5 y_f1_a1_5 y_f2_a1_5 y_f3_a1_5 y_f1_a2_5 y_f2_a2_5 y_f3_a2_5 y_f1_a3_5 y_f2_a3_5 y_f3_a3_5 y_f1_a4_5 y_f2_a4_5 y_f3_a4_5 real
syms x_f1_a1_6 x_f2_a1_6 x_f3_a1_6 x_f1_a2_6 x_f2_a2_6 x_f3_a2_6 x_f1_a3_6 x_f2_a3_6 x_f3_a3_6 x_f1_a4_6 x_f2_a4_6 x_f3_a4_6 y_f1_a1_6 y_f2_a1_6 y_f3_a1_6 y_f1_a2_6 y_f2_a2_6 y_f3_a2_6 y_f1_a3_6 y_f2_a3_6 y_f3_a3_6 y_f1_a4_6 y_f2_a4_6 y_f3_a4_6 real

dfA = [
    x_f1_a1_1 x_f1_a1_2 x_f1_a1_3 x_f1_a1_4 x_f1_a1_5 x_f1_a1_6
    x_f2_a1_1 x_f2_a1_2 x_f2_a1_3 x_f2_a1_4 x_f2_a1_5 x_f2_a1_6
    x_f3_a1_1 x_f3_a1_2 x_f3_a1_3 x_f3_a1_4 x_f3_a1_5 x_f3_a1_6
    x_f1_a2_1 x_f1_a2_2 x_f1_a2_3 x_f1_a2_4 x_f1_a2_5 x_f1_a2_6
    x_f2_a2_1 x_f2_a2_2 x_f2_a2_3 x_f2_a2_4 x_f2_a2_5 x_f2_a2_6
    x_f3_a2_1 x_f3_a2_2 x_f3_a2_3 x_f3_a2_4 x_f3_a2_5 x_f3_a2_6
    x_f1_a3_1 x_f1_a3_2 x_f1_a3_3 x_f1_a3_4 x_f1_a3_5 x_f1_a3_6
    x_f2_a3_1 x_f2_a3_2 x_f2_a3_3 x_f2_a3_4 x_f2_a3_5 x_f2_a3_6
    x_f3_a3_1 x_f3_a3_2 x_f3_a3_3 x_f3_a3_4 x_f3_a3_5 x_f3_a3_6
    x_f1_a4_1 x_f1_a4_2 x_f1_a4_3 x_f1_a4_4 x_f1_a4_5 x_f1_a4_6
    x_f2_a4_1 x_f2_a4_2 x_f2_a4_3 x_f2_a4_4 x_f2_a4_5 x_f2_a4_6
    x_f3_a4_1 x_f3_a4_2 x_f3_a4_3 x_f3_a4_4 x_f3_a4_5 x_f3_a4_6
    y_f1_a1_1 y_f1_a1_2 y_f1_a1_3 y_f1_a1_4 y_f1_a1_5 y_f1_a1_6
    y_f2_a1_1 y_f2_a1_2 y_f2_a1_3 y_f2_a1_4 y_f2_a1_5 y_f2_a1_6
    y_f3_a1_1 y_f3_a1_2 y_f3_a1_3 y_f3_a1_4 y_f3_a1_5 y_f3_a1_6
    y_f1_a2_1 y_f1_a2_2 y_f1_a2_3 y_f1_a2_4 y_f1_a2_5 y_f1_a2_6
    y_f2_a2_1 y_f2_a2_2 y_f2_a2_3 y_f2_a2_4 y_f2_a2_5 y_f2_a2_6
    y_f3_a2_1 y_f3_a2_2 y_f3_a2_3 y_f3_a2_4 y_f3_a2_5 y_f3_a2_6
    y_f1_a3_1 y_f1_a3_2 y_f1_a3_3 y_f1_a3_4 y_f1_a3_5 y_f1_a3_6
    y_f2_a3_1 y_f2_a3_2 y_f2_a3_3 y_f2_a3_4 y_f2_a3_5 y_f2_a3_6
    y_f3_a3_1 y_f3_a3_2 y_f3_a3_3 y_f3_a3_4 y_f3_a3_5 y_f3_a3_6
    y_f1_a4_1 y_f1_a4_2 y_f1_a4_3 y_f1_a4_4 y_f1_a4_5 y_f1_a4_6
    y_f2_a4_1 y_f2_a4_2 y_f2_a4_3 y_f2_a4_4 y_f2_a4_5 y_f2_a4_6
    y_f3_a4_1 y_f3_a4_2 y_f3_a4_3 y_f3_a4_4 y_f3_a4_5 y_f3_a4_6
    ];

% dim 1: i (f1 f2 f3)
% dim 2: k (a1 a2 a3 a4)
% dim 3: j (diff w.r.t x an y)
% dim 4: samples in the grid points
dfA = reshape(dfA,[N nA np Nr_Samples])

% Summation through dim k (to compute the Frobenius norm)
% dfA = sqrt(sum(dfA.^2,2)):
dfA = dfA(:,1,:,:) + dfA(:,2,:,:) + dfA(:,3,:,:) + dfA(:,4,:,:)

% Compute maximum along the samples
% dfA = max(dfA,[],4)
dfA = dfA(:,:,:,1)

% Permute the dimensions:
% dim 1: i
% dim 2: j
dfA = permute(dfA,[1 3 2])

end