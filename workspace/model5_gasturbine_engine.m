%% 
%  File: model4_randLFR.m
%  Directory: 8_published/LPV_L2/workspace
%  Author: Peter Polcz (ppolcz@gmail.com) 
%  
%  Created on 2020. March 28. (2019b)
%

G_reset
P_init(12)

setenv('RUN_ID', num2str(pcz_runID(mfilename)))
logger = Logger(['results/' mfilename '-output.txt']);
TMP_vcUXzzrUtfOumvfgWXDd = pcz_dispFunctionName;
pcz_dispFunction2('Run ID = %s', getenv('RUN_ID'));

%%

P_generate_symvars_v10(3,1,0,0);

A0 = [
   -4.365 -0.6723 -0.3363
    7.088 -6.557  -4.601
   -2.410  7.584  -14.310
    ];

A1 = [
   -0.56081 0.85534 0.58923
    2.5333 -1.0398 -7.7373
    3.1917  1.7971 -2.5887
    ];

A2 = [
    0.66981 -1.375  -0.99093
   -2.8963  -1.5292 10.516
   -3.5777   2.8389  1.9087
    ];

B0 = [
    2.374   0.7485
    1.366   3.444
    0.9416 -9.619
    ];

B1 = [
   -0.16023 -0.35209
    0.11622 -2.4839
   -0.11058 -4.6057
    ];

B2 = [
    0.15623  0.13063
   -0.49582  4.0379
   -0.030616 0.89473
    ];

A = @(p) A0 + p*A1 + p^2*A2;

B = @(p) B0 + p*B1 + p^2*B2;

C = [
    0 1 0
    0 0 1
    ];

D = [ 0 0 ; 0 0 ];

norm_at0 = norm(ss(A(0),B(0),C,D),Inf);
norm_at1 = norm(ss(A(1),B(1),C,D),Inf);

pcz_dispFunction_scalar(norm_at0, norm_at1)

p_lim = [
    0 1
    ];

%%

bases = [
    1
    p1
    p1^2
    p1^3
    p1^4
    ];

bases_Jac = jacobian(bases,p);

%% N logarithmically equidistant points in a decade
for Scale_dp_lim = setdiff(unique([
%         logspace(0,4,41)'
%         logspace(4,6,61)'
%         logspace(0,6,481)'
%         
%         ...
%         logspace(0,1,5)'
%         logspace(1,2,5)'
%         logspace(2,3,5)'
%         logspace(3,4,5)'
%         logspace(4,5,5)'
%         logspace(5,6,5)'
%         ...
%         logspace(3,4,4)'
%         logspace(4,5,4)'
%         logspace(5,6,4)'
%         ...
%         logspace(4,5,2)'
        100
        ])',[])
%%

modelname = sprintf('gasturbine_engine, alpha: %g', Scale_dp_lim);

dp_lim = [
    -1 1
    ] * Scale_dp_lim;

pdp_lim = [
    p_lim
    dp_lim
    ];

p_lims_comp = p_lim;
pdp_lims_comp = pdp_lim;


%%

method1_RCT(modelname,A,B,C,D,p_lim)

% method0_grid_LPVTools(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,5);

% Greedy grid 
% method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',5);
method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',45);
% method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',95);
% method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',135);
% method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',255);

% As proposed by Wu (1995,1996)
% method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',1000,'delta',1e-4,'T',10000);
% method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',1000,'delta',1e-3,'T',1000);
% method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',1000,'delta',1e-2,'T',100);
% method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',1000,'delta',1e-1,'T',100);
% method0_grid_Wu1995(modelname,A,B,C,D,p_lim,dp_lim,bases,bases_Jac,'res_max',1000,'delta',1e-1,'T',10);

method2_descriptor_primal(modelname,A,B,C,D,p_lim,dp_lim)
method2_descriptor_dual(modelname,A,B,C,D,p_lim,dp_lim,1)
method2_descriptor_dual(modelname,A,B,C,D,p_lim,dp_lim,0)

% IQC/LFT approaches for LPV with rate-bounded parameters
method3_IQC_LFT_LPVMAD(modelname,A,B,C,D,p_lim,dp_lim);
method3_IQC_LFT_LPVTools(modelname,A,B,C,D,p_lim,dp_lim);

method4_authors_old_symbolical(modelname,A,B,C,D,p_lim,dp_lim,'minlfr',false);

method4_authors_old_symbolical(modelname,A,B,C,D,p_lim,dp_lim,'minlfr',true);

% Imported variables to the base workspace: Q, dQ, PI_x, gamma
method5_proposed_approach(modelname,A,B,C,D,p_lim,dp_lim,p_lim,pdp_lim,'minlfr',false);
method5_proposed_approach(modelname,A,B,C,D,p_lim,dp_lim,p_lim,pdp_lim,'minlfr',true);

end

pcz_dispFunctionEnd(TMP_vcUXzzrUtfOumvfgWXDd);
logger.stoplog

return

%% Plot overall results

Entries = {
    '$\hat\gamma$, grid $5$ 5th $V(x,p)$'  'v--'  5 false
    '$\hat\gamma$, grid $45$ 4th $V(x,p)$' '.--'  20 true
    '$\hat\gamma$, grid $255$ 15th $V(x,p)$' '.--'  15 false
    'upper bound $\gamma$, descriptor'       '*--'  6 true
    'upper bound $\gamma$, LPVMAD'           'ro--'  5 true
    'upper bound $\gamma$, lpvwcgain'        'bo--'  5 true
    'upper bound $\gamma$, Finsler (old)'    'gs-'  10 true
    'upper bound $\gamma$, Finsler (new)'    '.k-' 10 true
    };

clear data
data(1).entries_I = [1,4:8];
data(1).s = unique([ logspace(0,2,21) logspace(2,6,17) ]);
data(1).gamma = [ 0.942031479764354	0.942108148617209	0.944567602756851	0.945191016155451	0.942031475464013	0.942031474766492	0.942031481944707	0.942157495360236	0.944896555230655	0.946329883001282	0.942031476763222	0.942031476624744	0.942031486521951	0.942241856783785	0.945942048537104	0.947279806142681	0.942031476742491	0.942031473311019	0.942031480674637	0.942385955090677	0.947479831478201	0.948762512251983	0.942031475683864	0.942031475960589	0.942031488391206	0.942633397304665	0.949965249393328	0.950680379849289	0.942031474553799	0.942031475654659	0.942031489027327	0.943060550157471	0.952993721871793	0.953517298935495	0.942031474467763	0.942031473118814	0.942031480040235	0.943797346140112	0.956447331754617	0.956210732368692	0.942031473753874	0.942031475271006	0.942031482819092	0.945050539435436	0.960048849820039	0.958918989042961	0.942031475953767	0.942031476601642	0.942031501054447	0.947042954401423	0.960650457893874	0.95931342693621	0.94203147395555	0.942031476684841	0.942031479757427	0.949755198202692	0.960518080638093	0.959627293045783	0.942031476956377	0.942031476757585	0.942031491402522	0.952603618455337	0.960015925453968	0.959720045126855	0.942031477231332	0.942031474318069	0.942031506974636	0.954909222607101	0.95986590459078	0.959437395447362	0.942031474009416	0.942031476562302	0.942031496390809	0.95653781429232	0.960486960935286	0.959374225539742	0.942031475842366	0.942031472667866	0.942031481869763	0.95758175594823	0.95990343617526	0.959511241648624	0.942031518085678	0.942031508327554	0.943034361128093	0.958207990180731	0.959897766438103	0.959432470265707	0.942041649603339	0.942151687058853	0.945165213873434	0.958563528158164	0.959970532119406	0.959556627892628	0.942068742914509	0.942066089318619	0.947314387381264	0.958758169095067	0.960503172985982	0.959515723801579	0.94210807959183	0.942839188508409	0.949245061983548	0.958860123237579	0.960411482340487	0.959479313091595	0.942073385520495	0.94295451220952	0.950906584972556	0.958908180535822	0.960148511080259	0.959456347031034	0.942090246537319	0.942454139072901	0.952304332952536	0.958923923387035	0.959600680991556	0.959409807829648	0.942208073415051	0.942798246439225	0.953463520172424	0.958924649259189	0.959838071779446	0.959313774328746	0.942104412904722	0.942779286909781	0.955521918868271	0.958923832630372	0.960409953740545	0.959554979423462	0.942158566892249	0.942265075385827	0.956734902857187	0.958923772928559	0.960875850585886	0.95943062491471	0.942098912275971	0.942101955589695	0.957434919401886	0.958923795614241	0.960101063397765	0.959556726129123	0.942057357604915	0.942130456306345	0.957834365500752	0.958923795023824	0.960504202752733	0.959693968839741	0.942038746869841	0.942040184573146	0.958060778242762	0.958923790671193	0.960356878707385	0.959576729692185	0.942033968559493	0.94203862794847	0.958188668567468	0.958923787993486	0.959775228470264	0.959521201924037	0.94203748461679	0.942034183894488	0.958260770232666	0.95892378647916	0.960536195331772	0.959494380488926	0.942030182303467	0.942032398108992	0.958301359725994	0.958923785629833	0.959763656386857	0.959543511530848	0.942032826030229	0.942035192108563	0.958324201329282	0.958923785153388	0.959797806408924	0.95956039034231	0.942063377596219	0.944270825703255	0.958337114832839	0.958923784886161	0.961015541864458	0.959613836682044	0.942706253518062	0.944221678890643	0.958344316777041	0.958923784735811	0.959892261022667	0.959413329290316	0.946035150907847	0.946147886901858	0.958348430980557	0.958923784651317	0.962897602858273	0.959580896024629	0.957152196932508	0.949630990389822	0.958350646669978	0.958923784603824	0.963371354938087	0.959528606356382	0.992992042428834	0.960317890760701	0.958351939046257	0.958923784577124	1.0154449572564	0.959494854072864	1.05097190452144	0.947015703581277	0.958352750031986	0.958923784562113	1.0038064470121	0.959527854422965	1.1684642369418	0.922388686237231	0.95835312113542	0.958923784553682	0.987792710360593	0.95939790357276	1.35035282279304	0.760336969820012 ];

data(2).entries_I = 7:8;
data(2).s = unique([ logspace(4,5,11) logspace(5,6,11) ]);
data(2).gamma = [ 0.942032826030229	0.942033369569613	0.942036646245341	0.942000527800393	0.942045010847433	0.942645463956214	0.942078388371325	0.942353077232417	0.94235423191521	0.938797476026076	0.942706253518062	0.942661712833993	0.943254110165509	0.943316347882341	0.945321705948278	0.945230660456181	0.948191951301639	0.946637689177567	0.952172319702551	0.941608645678395	0.957152196932508	0.941477350639305	0.972003982982519	0.946655138503383	0.989886735865341	0.94782262471442	1.00922586986142	0.952461331501072	1.01260795977235	0.93722259217171	1.05097190452144	0.935593006937552	1.09930362716292	0.89114799671124	1.17725800135195	0.922861588782169	1.21313204166143	0.769029123488705	1.30346947657634	0.515096430402589	1.35035282279304	0.640830856277855 ];

% % Results of 10th grid
% data(3).entries_I = 2;
% data(3).s = logspace(0,6,61);
% data(3).gamma = [ 0.942031484022013	0.942031484947948	0.942031488934696	0.942031487065198	0.942031484913758	0.942031481446197	0.942031495337336	0.942031477598249	0.942031477789764	0.942031477955328	0.94203147834717	0.942031484208519	0.942031478703489	0.942031477685593	0.9420314837332	0.9420314787251	0.942031477644766	0.94203147754287	0.942031478068006	0.942031477769348	0.942031481241702	0.942031485263702	0.942031491607841	0.942031485678773	0.942031483836857	0.942031484839608	0.942031499992108	0.942031533447606	0.942031501004128	0.942031564927635	0.942031618154105	0.942031714640329	0.942031668634616	0.942031633226862	0.94203187933646	0.942037128932346	0.942031911812287	0.942031736889338	0.942033077593582	0.942031509477011	0.942031755408179	0.94203164061932	0.94203179833975	0.942031691910943	0.942033328729331	0.950596219381334	0.942033688589793	0.942032232532771	0.958338141324657	0.958344577709702	0.958210096936051	0.958348596137957	0.958349950714223	0.958350682464829	0.958351406577183	0.958351926397707	0.958352244338578	0.958352559084426	0.958352800621608	0.958352970662731	0.95835311451581 ];
% 
% % Results of 15th grid
% data(4).entries_I = 3;
% data(4).s = logspace(4,6,61);
% data(4).gamma = [ 0.942032488658656	0.942031482711025	0.942031897205317	0.942032546463696	0.942033244464936	0.94203154614666	0.942031563058008	0.942038233323504	0.942035446338399	0.942037008306141	0.942031632283626	0.942032149994761	0.942034786451025	0.942031832024642	0.942031480181942	0.942031588395472	0.942031507904656	0.94203156857367	0.942033434319018	0.9420331563788	0.942031497847475	0.942031607942907	0.942031621520146	0.942031627228579	0.942031598943598	0.942031700971941	0.942031899515012	0.94203268839071	0.942033413985939	0.942036175195824	0.942032146762797	0.942032691400258	0.942033255523366	0.942031838078924	0.942031971140395	0.942031659042726	0.942031676843973	0.942031926443436	0.942034658126647	0.942031495618327	0.942033047313352	0.942032826691425	0.942033212692688	0.942034836091517	0.958347850180543	0.958348914929736	0.958349244601235	0.95834967370412	0.958349928368428	0.958350751535657	0.958350846437456	0.958351223220757	0.942031953707932	0.958351955228647	0.958352176815155	0.958352266985973	0.958352393188751	0.95835247213643	0.958352649473857	0.958352691905296	0.958352790071687 ];

% Results of 15th grid over alpha481 p255 grid points
% data(5).entries_I = 3;
% data(5).s = logspace(0,6,481);
% data(5).gamma = RES_2278_2020_04_15__15th;

% Results of 4th grid over alpha481 p45 grid points
data(6).entries_I = 2;
data(6).s = logspace(0,6,481);
data(6).gamma = RES_2278_2020_04_15__4th;


aa = cell([size(Entries,1),1]);
pl = cell([size(Entries,1),1]);
for i = 1:numel(data)
    if isempty(data(i).entries_I), continue; end
    
    data(i).gamma = num2cell(reshape(data(i).gamma,[numel(data(i).entries_I) numel(data(i).s)]),2)
    
    pl(data(i).entries_I) = cellfun(@(a,b) {[a b]}, pl(data(i).entries_I),data(i).gamma);
    aa(data(i).entries_I) = cellfun(@(a) {[a data(i).s]}, aa(data(i).entries_I));
end

for j = 1:numel(aa)
    [aa{j},I] = unique(aa{j});
    pl{j} = pl{j}(I);
end

HARD_LOWER = method0_grid_ltiwc_Hinf(modelname,A,B,C,D,p_lim);

figure(1), delete(gca), hold on
for i = 1:numel(aa)
    if Entries{i,4}
        plot(aa{i}, pl{i},Entries{i,2},'MarkerSize',Entries{i,3})
    end
end
plot([1 1e6],[0 0]+HARD_LOWER,'r','LineWidth',2);
set(gca,'xscale','log')
Leg = legend(Entries{[Entries{:,4}],1});
Leg.Location = 'southeast';
Leg.Interpreter = 'latex';
Leg.FontSize = 10;

grid on

xlim([1,1e6])
ylim([0.94,0.965])

Logger.latexify_axis(14)
Logger.latexified_labels(gca,15,'Value of $\alpha$','Computed $\gamma$')

%{

print('results_stored/model5_gasturbine_engine-plot1.pdf','-dpdf')
print('results_stored/model5_gasturbine_engine-plot2.pdf','-dpdf')
print('results_stored/model5_gasturbine_engine-plot3.pdf','-dpdf')

%}


%%

RES_2278_2020_04_15__4th = [
    0.942031479847709
    0.94203148011429
    0.942031477608168
    0.942031477612958
    0.942031477639342
    0.942031477666853
    0.942031477677991
    0.942031477690197
    0.942031477700068
    0.942031477705802
    0.942031477698414
    0.942031477693301
    0.942031477689647
    0.942031477684373
    0.942031477694091
    0.942031477709071
    0.942031477729248
    0.942031477759066
    0.942031477808832
    0.942031477891128
    0.942031477925471
    0.942031477970815
    0.942031478064191
    0.942031478321273
    0.942031478869641
    0.942031478721325
    0.9420314787916
    0.942031478590242
    0.942031478379601
    0.942031478168968
    0.942031478025456
    0.942031478002689
    0.942031477995949
    0.942031477986317
    0.942031477974348
    0.942031477962862
    0.942031477960167
    0.94203147803235
    0.942031478206751
    0.942031478416609
    0.942031478495004
    0.942031478594319
    0.942031478713129
    0.942031478851418
    0.942031479014883
    0.942031479192521
    0.942031479386867
    0.942031479596469
    0.942031479822793
    0.942031480071979
    0.942031477766101
    0.9420314778127
    0.942031477873537
    0.942031477913888
    0.942031477939226
    0.942031477968281
    0.942031478001407
    0.942031478041393
    0.942031478088503
    0.942031478148213
    0.942031478225443
    0.942031478299097
    0.942031478371193
    0.942031478422838
    0.942031478466306
    0.942031478508486
    0.942031478535898
    0.94203147854138
    0.942031478594159
    0.942031478784999
    0.942031479008267
    0.942031479282846
    0.942031479611882
    0.942031480152424
    0.942031477739357
    0.942031477806559
    0.942031477905677
    0.942031478031801
    0.942031478209917
    0.942031478459181
    0.942031478758497
    0.942031479137192
    0.942031479577204
    0.942031480058303
    0.942031480625098
    0.94203148134838
    0.942031478070259
    0.942031478203773
    0.942031478290421
    0.942031478335052
    0.942031478399538
    0.942031478352314
    0.942031478294579
    0.942031478229632
    0.942031478586126
    0.942031479639114
    0.942031481691414
    0.942031478000849
    0.942031478553133
    0.942031479292729
    0.942031480722254
    0.942031478643174
    0.942031482442466
    0.942034383712869
    0.94208653243925
    0.94219267687821
    0.94234114319069
    0.942522539339519
    0.942729733213737
    0.942957039732253
    0.943200091314594
    0.943455139630945
    0.94371932524216
    0.943990428743196
    0.944266571748277
    0.944545920570392
    0.944827179773904
    0.94510957246387
    0.94539222108067
    0.945673980270527
    0.945954231719353
    0.946232825739092
    0.94650930992484
    0.946783042490304
    0.947053463095561
    0.947320824720396
    0.947584937497202
    0.947845475723646
    0.948101838237678
    0.948354379954144
    0.948603023362629
    0.948847729817192
    0.949088258953177
    0.949324260332138
    0.949556148435977
    0.949783916765348
    0.950007498515448
    0.950226854736784
    0.950441738475995
    0.950652404327567
    0.950858889184311
    0.951061267478192
    0.951259514595438
    0.951453611764841
    0.951643595357856
    0.951829550159925
    0.952011509455974
    0.95218948304869
    0.952363582427373
    0.952533810306467
    0.952700163421467
    0.952862682267316
    0.953021418528853
    0.953176474091949
    0.953327849576932
    0.953475694580442
    0.953619977978287
    0.953760782759841
    0.953898240255964
    0.954032381048363
    0.954163219965497
    0.954290822364797
    0.954415222084983
    0.954536480511428
    0.954654661191726
    0.954769829941362
    0.954882051511271
    0.954991389008378
    0.955097911066795
    0.95520167940723
    0.955302759521217
    0.955401219430732
    0.955497099645653
    0.955590481267775
    0.955681414840686
    0.955769979873711
    0.955856168885999
    0.955940108383572
    0.95602184971191
    0.956101380013403
    0.956178850716665
    0.956254208982103
    0.956327586169536
    0.956398997729332
    0.956468498422814
    0.956536136238298
    0.956601961818231
    0.956666014031776
    0.956728364507968
    0.956788999541015
    0.956848015944303
    0.956905430956923
    0.956961288897866
    0.957015616705386
    0.957068483228733
    0.957119919384552
    0.957169949067018
    0.957218614550566
    0.957265952049216
    0.957311996722506
    0.957356782247763
    0.957400340023852
    0.95744270299039
    0.957483904437433
    0.957523976407197
    0.957562944934055
    0.957600854123012
    0.957637718354658
    0.957673558713933
    0.957708408930288
    0.957742296894658
    0.957775246608802
    0.957807285246897
    0.957838436217794
    0.957868721668739
    0.957898169940435
    0.957926801347366
    0.957954638513601
    0.957981702950751
    0.958008016092506
    0.958033598287225
    0.958058471675615
    0.958082653015916
    0.958106158645504
    0.958129011810712
    0.958151228658316
    0.958172824402339
    0.958193818105378
    0.958214224352128
    0.958234061333469
    0.958253343353455
    0.958272085675834
    0.958290304396335
    0.958308013580089
    0.958325226850406
    0.958341956444669
    0.958358218200869
    0.958374025418238
    0.958389386313076
    0.958404319639736
    0.958418830330352
    0.958432938458897
    0.958446647391359
    0.958459970680728
    0.958472923627099
    0.958485512826965
    0.958497744514421
    0.958509636590495
    0.958521191014122
    0.958532424081954
    0.958543355169938
    0.958553946137808
    0.9585642542197
    0.958574274293049
    0.958584008293061
    0.958593498514763
    0.958602692491158
    0.958611629123636
    0.95862031411807
    0.958628754333561
    0.958636939290748
    0.958644903933619
    0.958652649711848
    0.958660177786719
    0.958667493469489
    0.958674601686137
    0.95868153166325
    0.958688244094055
    0.958694766998757
    0.958701105322535
    0.958707265165478
    0.958713251649157
    0.958719069526435
    0.958724723229728
    0.95873021645517
    0.958735553797237
    0.958740738207427
    0.95874577766564
    0.958750672910952
    0.958755430843478
    0.958760057999269
    0.958764559081314
    0.958768926809634
    0.958773169253802
    0.958777292701685
    0.958781300417774
    0.958785194619458
    0.95878897823435
    0.9587926553291
    0.958796230408382
    0.958799703960004
    0.958803074808846
    0.958806355240192
    0.958809538839204
    0.95881263633844
    0.958815645801415
    0.958818568412008
    0.958821404504883
    0.958824158301173
    0.958826851271419
    0.958829451639986
    0.958831987170602
    0.958834447080581
    0.958836836681014
    0.958839158185661
    0.958841414063874
    0.958843608458478
    0.958845730560482
    0.958847806963202
    0.958849822260334
    0.958851775560632
    0.958853675421504
    0.958855521005057
    0.958857314214722
    0.958859056588019
    0.95886074958132
    0.958862394637329
    0.958863993035834
    0.958865546159322
    0.958867055250402
    0.958868521644789
    0.958869946540576
    0.958871331054994
    0.958872676293747
    0.958873983371862
    0.958875253417473
    0.95887648744827
    0.958877686568558
    0.958878851733342
    0.958879983876676
    0.95888108391741
    0.958882152761141
    0.958883191289757
    0.958884200383905
    0.958885180868944
    0.958886133521319
    0.958887059150409
    0.958887958544928
    0.958888832416296
    0.958889681514435
    0.958890506500284
    0.958891307874542
    0.95889208668219
    0.958892843236472
    0.95889357810984
    0.958894291986029
    0.958894985550502
    0.958895660116691
    0.958896315259699
    0.95889695137807
    0.958897574919489
    0.958898174671133
    0.958898759094054
    0.958899325542265
    0.958899875337494
    0.958900410976833
    0.958900932275654
    0.958901440233016
    0.958901934936355
    0.958902414195412
    0.958902879447848
    0.958903331007334
    0.958903769395824
    0.958904195054252
    0.95890460842823
    0.958905009910985
    0.958905399930197
    0.958905778816029
    0.95890614691401
    0.958906504302141
    0.958906851645164
    0.95890718890583
    0.958907516887239
    0.958907835346391
    0.958908144955004
    0.958908446257531
    0.958908739624781
    0.958909023714838
    0.95890930138566
    0.958909568672512
    0.958909831525231
    0.958910084834266
    0.958910331207988
    0.958910570483741
    0.958910802123326
    0.958911029143548
    0.958911248577538
    0.958911463297467
    0.958911669076668
    0.958911870779341
    0.958912066161258
    0.958912258464531
    0.958912442144494
    0.958912622042142
    0.958912795201109
    0.9589129643663
    0.958913129242996
    0.95891328931875
    0.95891344594758
    0.958913596488026
    0.958913744225043
    0.958913885918086
    0.958914026302883
    0.958914157730916
    0.958914291316558
    0.958914418448064
    0.958914541455256
    0.958914662681117
    0.958914781916472
    0.958914895745478
    0.958915001396246
    0.958915111402386
    0.958915214502248
    0.958915316723902
    0.958915413668896
    0.958915508054609
    0.958915599258751
    0.958915689158894
    0.958915776849336
    0.95891586329503
    0.958915944374927
    0.958916024552203
    0.958916101970108
    0.958916177877451
    0.958916269970095
    0.958916322750291
    0.958916401186864
    0.958916459677276
    0.958916524866629
    0.958916588416268
    0.958916651514319
    0.958916710955913
    0.958916771825413
    0.958916825889008
    0.958916880848821
    0.958916937339165
    0.958916986454591
    0.9589170402346
    0.958917086252844
    0.958917135256583
    0.95891718168061
    0.958917228283286
    0.958917269138483
    0.958917331420722
    0.95891735419996
    0.958917394145687
    0.958917446724089
    0.958917471949399
    0.958917509628509
    0.958917543208231
    0.958917578828839
    0.958917617720216
    0.958917645222519
    0.958917676428984
    0.958917708563618
    0.958917738823422
    0.95891776795539
    0.958917796204085
    0.958917823822485
    0.958917851870821
    0.958917876869457
    0.958917903109618
    0.958917929072027
    0.958917951506079
    0.958917974721182
    0.958917996985376
    0.958918018972197
    0.958918086258473
    0.95891806126311
    0.958918083913011
    0.958918100199226
    0.958918122647078
    0.958918161153577
    0.958918180202318
    0.958918196700907
    0.958918214000328
    0.958918229971902
    0.95891824520123
    0.958918261043624
    0.958918275605536
    0.958918289495808
    ];

RES_2278_2020_04_15__15th = [
    0.942031477450473
    0.942031477428221
    0.942031477532397
    0.942031477467076
    0.94203147746008
    0.942031477450166
    0.942031477461247
    0.942031477508193
    0.942031477714841
    0.942031477437847
    0.942031477918184
    0.942031477969542
    0.942031478010677
    0.942031478035833
    0.942031478032532
    0.942031477977406
    0.942031477861565
    0.942031477682406
    0.942031477579976
    0.942031477555792
    0.942031477563021
    0.942031477584403
    0.942031477598396
    0.942031477616903
    0.942031477615658
    0.942031477652202
    0.942031477730718
    0.942031477416768
    0.942031477715332
    0.942031477731239
    0.94203147774059
    0.942031477750554
    0.942031477763086
    0.942031477777402
    0.942031477794463
    0.942031477809615
    0.942031477807578
    0.942031477822473
    0.942031477841026
    0.942031477857729
    0.942031477873193
    0.942031477890098
    0.942031477901967
    0.94203147788944
    0.942031477892508
    0.942031477892283
    0.942031477881564
    0.942031477876415
    0.942031477870704
    0.942031477865124
    0.942031477856052
    0.942031477828312
    0.942031477796421
    0.942031477757104
    0.94203147774373
    0.94203147773438
    0.942031477737617
    0.942031477719807
    0.942031477671065
    0.942031477597279
    0.942031477712583
    0.942031477811267
    0.942031477598082
    0.942031477415409
    0.942031477415611
    0.942031477418392
    0.94203147742418
    0.942031477453355
    0.942031477467981
    0.942031477542338
    0.942031477434032
    0.942031477514379
    0.942031477446296
    0.942031477438343
    0.94203147764854
    0.942031477440085
    0.942031477561597
    0.942031477570405
    0.94203147749676
    0.942031477416696
    0.942031477743943
    0.942031477659309
    0.942031477931511
    0.942031477769446
    0.942031477882463
    0.942031478350452
    0.942031478573869
    0.942031477755982
    0.942031478624312
    0.94203147899677
    0.942031477467588
    0.942031477542885
    0.942031477747361
    0.942031477896332
    0.942031477974851
    0.942031477764229
    0.942031477785144
    0.942031477656559
    0.942031477630832
    0.942031477759656
    0.942031477575139
    0.942031477501657
    0.942031477423918
    0.942031477484633
    0.942031477479466
    0.94203147743526
    0.942031478144797
    0.942044774301785
    0.942112544853297
    0.94222777015292
    0.942380753314231
    0.942563312211296
    0.942770002335947
    0.942995373414458
    0.943235749965568
    0.943487691535885
    0.943749214237611
    0.94401677584866
    0.944289494539119
    0.944565987340569
    0.944844803126996
    0.94512573124556
    0.945405747062137
    0.945685538574631
    0.945964786275719
    0.946241734130667
    0.946516604402168
    0.946789141504493
    0.947058430868562
    0.947324277457214
    0.947587289447388
    0.94784661244829
    0.94810242564747
    0.948354458409415
    0.948602206967109
    0.948846175491032
    0.949085430066556
    0.949320852571467
    0.94955102986748
    0.949779237890457
    0.950001057096037
    0.95021964582621
    0.950433991540686
    0.950644531346681
    0.950850315750665
    0.951052304808262
    0.951250475624738
    0.951444063029445
    0.951633366491104
    0.951819315537356
    0.95200067687577
    0.952178774026935
    0.952352698417045
    0.952522724686667
    0.952688847634191
    0.9528512095137
    0.953009910142109
    0.953164801002565
    0.953316534427859
    0.953463989928282
    0.953608408354961
    0.953749439422678
    0.953887128404923
    0.95402118195936
    0.954153398168037
    0.954279696715251
    0.954404265999179
    0.954526029973865
    0.954644747441542
    0.954760170867257
    0.954872518094594
    0.954982298079523
    0.955089065708489
    0.955193210767988
    0.95529556610901
    0.955393624100588
    0.955489137999005
    0.955583725595323
    0.955674441104465
    0.95576428798889
    0.955850034758128
    0.955933787119474
    0.956017061382769
    0.9560965373986
    0.95617438736841
    0.956249402469653
    0.95632353507745
    0.95639517583988
    0.956464906129273
    0.956532729693351
    0.956598684343829
    0.956662850601171
    0.956725034215503
    0.95678632278025
    0.956845554999862
    0.956903443077308
    0.956959536783604
    0.957013842313472
    0.957066927033496
    0.957118496869156
    0.957168967508026
    0.957217646210785
    0.957265174173976
    0.957311308923257
    0.957356270633657
    0.957399940822571
    0.9574424170773
    0.957483872109373
    0.957523959168084
    0.957563048448212
    0.957601098756825
    0.95763805315692
    0.957673944018523
    0.957708848298036
    0.957742809240748
    0.957775918623447
    0.957808012107995
    0.957839364835513
    0.957869764009827
    0.957899434329488
    0.957928173159008
    0.957956148920073
    0.957983290049881
    0.958009733231678
    0.958035579882138
    0.958060393630728
    0.958084707329437
    0.958108304834952
    0.958131231178523
    0.958153500391249
    0.958175148399065
    0.95819620034973
    0.958216671311785
    0.958236551004472
    0.958255869638749
    0.958274678062461
    0.958293023222717
    0.958310854120848
    0.958328074533467
    0.958344859557455
    0.95836122405785
    0.958376994360052
    0.958392506825925
    0.958407457715314
    0.958422194492012
    0.958436353644502
    0.958450120845771
    0.958463446879815
    0.958476453980579
    0.958489082761723
    0.958501400829126
    0.958513303838201
    0.958524892029004
    0.958536136351629
    0.958547164973115
    0.958557761451
    0.958568103811211
    0.958578146501965
    0.958587947226245
    0.958597434369114
    0.958606657126838
    0.958615629741412
    0.958624330915984
    0.958632796340402
    0.958641020197399
    0.958648992507679
    0.95865676045456
    0.958664308106913
    0.958671722271254
    0.958678849549648
    0.958685782878104
    0.958692511673733
    0.958699048888761
    0.958705442373064
    0.958711648501083
    0.958717624022532
    0.958723452656267
    0.958729117660073
    0.958734619065196
    0.958739967981474
    0.958745169517384
    0.958750220874746
    0.958755144877148
    0.958759918218898
    0.958764554257303
    0.958769053357221
    0.958773415504661
    0.958777701206981
    0.958781833894116
    0.958785828342474
    0.958789727592221
    0.958793554937391
    0.9587972979562
    0.958800880533465
    0.958804304781449
    0.958807708061897
    0.958810976597154
    0.958814214887965
    0.958817304270324
    0.958820346585599
    0.958823276371597
    0.958826119865589
    0.95882886097234
    0.958831570659935
    0.958834185537257
    0.958836704691907
    0.958839201967723
    0.958841555063075
    0.958843894112189
    0.958846152714745
    0.958848374698108
    0.958850441979098
    0.95885254543898
    0.958854587985016
    0.958856599959497
    0.958858468162454
    0.958860351051982
    0.958862126378565
    0.958863885039596
    0.958865547477254
    0.958867208052066
    0.958868799200839
    0.958870373281617
    0.958871937976326
    0.958873348431494
    0.958874848146382
    0.958876258263534
    0.958877531013778
    0.958878845019986
    0.958880155914932
    0.958881348940412
    0.958882611069294
    0.958883787374652
    0.958884923499573
    0.958885979334214
    0.958887067159898
    0.958888140324905
    0.958889083540078
    0.958890118561942
    0.958891099332282
    0.958892020003038
    0.95889296278701
    0.958893834609259
    0.958894682339519
    0.95889550266546
    0.958896306961067
    0.958897084373944
    0.958897832941204
    0.958898591676245
    0.958899302838575
    0.958899995119416
    0.958900649165178
    0.958901319167778
    0.958901952407921
    0.958902578139045
    0.958903173723324
    0.958903756492736
    0.958904315082628
    0.95890483567702
    0.958905376810267
    0.958905901265163
    0.958906410573662
    0.958906926629149
    0.958907343150934
    0.958907820760548
    0.958908270961819
    0.958908767568827
    0.958909181753041
    0.958909599700643
    0.958909938167236
    0.958910332787271
    0.958910758505763
    0.958911140838215
    0.958911435024873
    0.958911803123879
    0.958912124860763
    0.958912476988114
    0.958912816311573
    0.958913062725204
    0.958913379936116
    0.958913679114152
    0.958913958434936
    0.958914226097657
    0.958914537990635
    0.958914786492215
    0.958915033578319
    0.958915261811117
    0.958915497538149
    0.958915765308465
    0.95891595201382
    0.958916168332191
    0.958916377602589
    0.958916599200993
    0.958916806634694
    0.958917024423975
    0.958917206106281
    0.958917383879323
    0.958917577718555
    0.958917755761875
    0.958917920513956
    0.958918082779926
    0.958918244705609
    0.958918399305064
    0.95891849326375
    0.958918693647788
    0.95891883063829
    0.95891894692904
    0.958919096884439
    0.958919223638382
    0.958919351933658
    0.95891949236518
    0.958919540981437
    0.958919669045692
    0.958919842050685
    0.958919890144906
    0.958920016545803
    0.958920117698622
    0.958920219312288
    0.958920321842623
    0.958920410122719
    0.958920550961876
    0.958920639188109
    0.958920689240206
    0.958920768072848
    0.958920849012206
    0.958920927540964
    0.95892100155366
    0.958921077809731
    0.958921148502988
    0.958921218391719
    0.958921259130734
    0.958921316415298
    0.958921411315177
    0.958921475016413
    0.958921516384439
    0.95892157500078
    0.958921617412344
    0.95892167485026
    0.958921721209792
    0.958921867310346
    0.958921852562449
    0.958921972066523
    0.958921944520297
    0.958922063543453
    0.958922082974921
    0.958922126362365
    0.958922164599599
    0.958922239700975
    0.95892227723552
    0.958922324106005
    0.958922359713538
    0.95892240679874
    0.958922435711355
    0.958922417498427
    0.958922488191446
    0.958922507160385
    0.958922533803865
    0.958922552964693
    0.958922576983745
    0.958922657132662
    0.958922691905927
    0.958922657867037
    0.95892266553191
    0.958922755878029
    0.958922788602786
    0.958922807698311
    0.958922784816986
    0.958922875945021
    0.958922823518377
    0.958922883092543
    0.958922931810348
    0.95892294759721
    0.9589229671634
    0.958922987336559
    0.958922965662427
    0.958922965376489
    0.958923040092099
    0.958923029108607
    0.958923053217014
    0.958923111139268
    0.958923091194574
    ];
