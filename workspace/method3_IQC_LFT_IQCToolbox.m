function method3_IQC_LFT_IQCToolbox(modelname, A_fh, B_fh, C_fh, D_fh, p_lim, dp_lim)
%% LPV_L2anal_IQCToolbox
%  
%  File: LPV_L2anal_IQCToolbox.m
%  Directory: 1_PhD_projects/22_Hinf_norm/qLPV_ipend
%  Author: Peter Polcz (ppolcz@gmail.com) 
%  
%  Created on 2020. March 13. (2019b)
%

TMP_quNJgGJNllaEMSewPAvy = pcz_dispFunctionName('IQCToolbox');

% Find out np, nw and nz
[ny,nx] = size(C_fh);
[~,nu] = size(D_fh);
np = size(p_lim,1);

% Generate symbolic lfr variables
[~,p_cell] = pcz_generateLFRStateVector('p',p_lim);

% Hack
p_cell{1} = p_cell{1} + 1;
p_cell{2} = p_cell{2} + 1;
p_lim(1:2,1:2) = p_lim(1:2,1:2) - 1;


% LFR realization of matrix A(p):
A_lfr = A_fh(p_cell{:});

% LFR realization of matrix B(p):
B_lfr = B_fh(p_cell{:});

F_lfr_initial = [
    A_lfr B_lfr
    C_fh  D_fh
    ];

F_lfr = minlfr(F_lfr_initial);
% P_lfr = P_lfrdata_v6(F_lfr_initial)

%%

m = size(F_lfr.a,1);

Fij = [
    F_lfr.d F_lfr.c
    F_lfr.b F_lfr.a
    ];
F = cell(3);

F{1,1} = Fij(1:nx       ,1:nx); F{1,2} = Fij(1:nx       ,nx+1:nx+nu); F{1,3} = Fij(1:nx       ,nx+nu+1:end);
F{2,1} = Fij(nx+1:nx+nu ,1:nx); F{2,2} = Fij(nx+1:nx+nu ,nx+1:nx+nu); F{2,3} = Fij(nx+1:nx+nu ,nx+nu+1:end);
F{3,1} = Fij(nx+nu+1:end,1:nx); F{3,2} = Fij(nx+nu+1:end,nx+1:nx+nu); F{3,3} = Fij(nx+nu+1:end,nx+nu+1:end);

% A possible shorthand:
% [F{:}] = pcz_split_matrix(Fij, [nx nz m], [nx nw m], 'RowWise', false);


% In my model
%
% dx = F11 x + F12 w + F13 Pi
%  z = F21 x + F22 w + F23 Pi
%  y = F31 x + F32 w + F33 Pi

% In the IQC Toolbox model [THIS ONE USED IN THIS CASE]
%
% dx = F11 x + F13 Pi + F12 w
%  y = F31 x + F33 Pi + F32 w
%  z = F21 x + F23 Pi + F22 w

A = F{1,1} - eye(3)*eps;

B = [
    F{1,3} F{1,2}
    ];

C = [
    F{3,1}
    F{2,1}
    ];

D = [
    F{3,3} F{3,2}
    F{2,3} F{2,2}
    ];

M = ss(A,B,C,D);

iqc = iqcpb(M);

[iqc,~] = iqcuc(iqc,'ltvs',F_lfr.blk.desc(1,:),[p_lim' dp_lim'],'box');
 
iqc = set(iqc,1,'Pole',[-2 -2 -2]);
iqc = set(iqc,1,'Length',[2 2 2]);
iqc = set(iqc,1,'Relax',1);
iqc = set(iqc,1,'Active',1);

tic
iqc = iqcsolve(iqc);
IQC_solution_time = toc;
toc

get(iqc)

gamma = get(iqc,'gopt');
if isempty(gamma)
    gamma = 0;
end

info = [ 'Pole: [' num2str(get(iqc,1,'Pole')) '], Length: [' num2str(get(iqc,1,'Length')) '], Relax: ' num2str(get(iqc,1,'Relax')) ', Active: ' num2str(get(iqc,1,'Active')) ];

store_results('IQCToolbox_Results.csv',modelname,0,gamma,IQC_solution_time,info,'IQCToolbox - ltvs')
store_results('Results_All.csv',modelname,0,gamma,IQC_solution_time,info,'IQCToolbox - ltvs')

%%
pcz_dispFunctionEnd(TMP_quNJgGJNllaEMSewPAvy);

end