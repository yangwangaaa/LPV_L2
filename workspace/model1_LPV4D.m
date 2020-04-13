%% LPV4D_main
%  
%  File: LPV4D_main.m
%  Directory: workspace/1_comp_LPV
%  Author: Peter Polcz (ppolcz@gmail.com) 
%  
%  Created on 2020. March 20. (2019b)
%

G_reset
P_init(11)

%%

RUN_ID = str2double(getenv('RUN_ID'));
if isnan(RUN_ID) || ceil(log10(RUN_ID + 1)) ~= 4
    setenv('RUN_ID', num2str(pcz_runID))
else
    setenv('RUN_ID', num2str(str2double(getenv('RUN_ID')) + 1))
end

logger = Logger(['results/' mfilename '-output.txt']);
TMP_vcUXzzrUtfOumvfgWXDd = pcz_dispFunctionName;

pcz_dispFunction2('Run ID = %s', getenv('RUN_ID'));

%%

P_generate_symvars_v10(4,3,2,2)

p_lim = [
    -1 2
    -1 2
    0 2
    ];

for Scale_dp_lim = [
%         1
        1.78
%         2.15
        3.16
%         4.64
        5.6
%         10
        17.8
%         21.5
        31.6
%         46.4
        56.2
%         100
        177.8
%         215.4
        316.2
%         464.2
        562.3
%         1000
        ]'

    dp_lim = [
        -10 10
        -1 1
        -5 5
        ]*Scale_dp_lim;

    modelname = sprintf('model1_LPV4D_x%s', num2str(Scale_dp_lim));
    
    [p_lfr,p_lfr_cell] = pcz_generateLFRStateVector('p',p_lim);

    A_fh = @(p1,p2,p3) [
        -3+p1       3+p1/(p3^2 + 0.5*p1 + 1)     0.1*p3   p3^2*p2
        0          -1-p2^2                       5        0
        -1/(5-p2)  0                             -4+p1    0
        0          0.1                           0        -5+1/(p1 + 2)
        ];

    C_fh = @(p1,p2,p3) [
        1/(5-p2)   0                             0        0
        0          0                             p1+1     0
        ];

    B_fh = @(p1,p2,p3) [
        0      0
        1+p2^2 0
        0      0
        0      2+p1/(p1 + 2)
        ];

    D_fh = [
        0      0
        0      0
        ];


    % norm(ss(A_fh(2,2,2),B_fh(2,2,2),C_fh(2,2,2),D_fh),Inf)

    %%

    % LPV_quick_check_stability(A_fh, B_fh, C_fh, D, p_lim)

    p_lims_comp = p_lim;

    pdp_lims_comp = [
        p_lims_comp
        dp_lim
        ];

    %% Basis functions for the grid-based methods

    bases = [
                       1
                      p1
                      p2
                      p3
                1/(5-p2)
        ];

    bases_Jac = jacobian(bases,p);

    %%

    % method1_RCT(modelname,A_fh,B_fh,C_fh,D_fh,p_lim)

    % method0_grid_LPVTools(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,[5 5 5]);
    % 
    % % Greedy grid 
    method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',5);
    % method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',15);
    % 
    % % As proposed by Wu (1995,1996)
    % method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',5,'delta',1e-6,'T',1e6);
    % method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',5,'delta',1e-5,'T',100000);
    % method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',5,'delta',1e-4,'T',10000);
    % method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',5,'delta',1e-3,'T',1000);
    % method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',5,'delta',1e-2,'T',100);
    % method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',5,'delta',1e-1,'T',100);
    % method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',5,'delta',1e-2,'T',10);
    % method0_grid_Wu1995(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,bases,bases_Jac,'res_max',5,'delta',1e-1,'T',10);
    % 
    % method2_descriptor_primal(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim)
    % method2_descriptor_dual(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,1)
    method2_descriptor_dual(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,0)
    % 
    % % IQC/LFT approaches for LPV with rate-bounded parameters
    method3_IQC_LFT_IQCToolbox(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim);
    method3_IQC_LFT_LPVTools(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim);
    % 
    % method4_authors_old_symbolical(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim);
    % 
    % % Imported variables to the base workspace: Q, dQ, PI_x, gamma
    method5_proposed_approach(modelname,A_fh,B_fh,C_fh,D_fh,p_lim,dp_lim,p_lims_comp,pdp_lims_comp);

end

%%

pcz_dispFunctionEnd(TMP_vcUXzzrUtfOumvfgWXDd);
logger.stoplog

return


%% Plot overall results

Entries = {
    'Grid approx 5x5x5 (Wu,1995)' '^--' 10
    'Descriptor'                  '.--' 30
    'LPVMAD'                      '.--' 40
    'lpvwcgain'                   '.--' 20
    'Finsler (old)'               's--' 20
    'Finsler (new)'               '.k--' 10
    };


Res = [
1	1.78	2.15	3.16	4.64	5.6	10	17.8	21.5	31.6	46.4	56.2	100	177.8	215.4	316.2	464.2	562.3	1000	1.00E+04	1.00E+05
2.035240	2.05126989067949	NaN	2.14179282356365	NaN	2.29222240933528	2.50069044501004	NaN	NaN	NaN	NaN	NaN	2.68133181557627	NaN	NaN	NaN	NaN	NaN	2.68303688028365	2.68305331689286	2.6830534808692
2.105647	2.20063554509286	NaN	2.36050330073879	NaN	2.55228514512871	2.69285796471826	NaN	NaN	NaN	NaN	NaN	2.78009235130869	NaN	NaN	NaN	NaN	NaN	2.7807585761487	2.78075936139437	2.78075911067564
2.248608	2.54833429486015	NaN	2.82087126323161	NaN	2.81794253677084	2.82033877316899	NaN	NaN	NaN	NaN	NaN	2.82026959237618	NaN	NaN	NaN	NaN	NaN	2.81963134967875	2.82739191302986	2.87240145997068
2.364417	2.59231592853063	NaN	2.81855086686819	NaN	2.81812896808011	2.81884398630243	NaN	NaN	NaN	NaN	NaN	2.81924566906359	NaN	NaN	NaN	NaN	NaN	2.81813194525962	2.81862859240125	2.81851428506674
2.035245	NaN	NaN	NaN	NaN	NaN	2.37246558356987	NaN	NaN	NaN	NaN	NaN	2.72932634897617	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
2.035241	2.05120659809694	NaN	2.11755668912915	NaN	2.23104291531253	2.37250963593153	NaN	NaN	NaN	NaN	NaN	2.7291213977834	NaN	NaN	NaN	NaN	NaN	2.7768342796527	2.694649013175	NaN
    ];

s = Res(1,:)';
data = num2cell(Res(2:end,:)',1);

figure(1), delete(gca), hold on
for i = 1:numel(data)
    I = ~isnan(data{i});
    plot(s(I), data{i}(I),Entries{i,2},'MarkerSize',Entries{i,3})
end
set(gca,'xscale','log')
Leg = legend(Entries{:,1});
Leg.Location = 'southeast';

grid on
axis tight
