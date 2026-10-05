
%% Experiment 1 - RANDOM, NOT REALISTIC
    clear

%     initial_pos_config=3;
%     useRealisticSim=true;
%     PLOTGRAPH=false;
% 
%     batteryTEMP=[];
%     delta_batteryTEMP=[];
%     graphs=[];
%     trees=[];
%     positions=[];
% 
    rng(0);
    load('experiment_1.mat')
    plot_assignment_figs_paper_3d
    initial_pos_config=1;
    useRealisticSim=true;
    PLOTGRAPH=true;
    %     load run.mat
    init=i;
    
    for i=85:85%init:100
        fprintf('\n%d \n',i)

        
        initial_graph=graphs{i};
        initial_tree=trees{i};
        initial_pos=positions{i};
        
        close all;

        FIRSTEXECUTION=false;
        useRandomAsg=false;
        [batRAND,dbatRAND,initial_graph,initial_tree,initial_pos] = cost_based_selection_2(...
                                                                    initial_pos_config,...
                                                                    useRandomAsg,...
                                                                    useRealisticSim,...
                                                                    PLOTGRAPH,...
                                                                    initial_graph,initial_tree,initial_pos,...
                                                                    FIRSTEXECUTION);


        close all;

        useRandomAsg=false;
        [batAUC,dbatAUC,initial_graph,initial_tree,initial_pos] = cost_based_selection(...
                                                                initial_pos_config,...
                                                                useRandomAsg,...
                                                                useRealisticSim,...
                                                                PLOTGRAPH,...
                                                                initial_graph,initial_tree,initial_pos,...
                                                                FIRSTEXECUTION);

%         batteryTEMP=[batteryTEMP;batRAND,batAUC];
%         delta_batteryTEMP=[delta_batteryTEMP;dbatRAND,dbatAUC];
        batteryTEMP{i}.random=batRAND;
        batteryTEMP{i}.auction=batAUC;
        delta_batteryTEMP{i}.random=dbatRAND;
        delta_batteryTEMP{i}.auction=dbatAUC;
    end

    filename=strcat('experiment_',num2str(initial_pos_config),'_all_agents.mat');
    save(filename,'battery','delta_battery', 'graphs', 'trees', 'positions')
%     battery = array2table(batteryTEMP, 'VariableNames',{'mean random', 'median random','std random','mean auction', 'median auction','std auction'});
%     delta_battery = array2table(delta_batteryTEMP, 'VariableNames',{'mean random' 'median random' 'std random' 'min random' 'max random' 'mean auction' 'median auction' 'std auction' 'min auction' 'max auction'});
%     filename=strcat('experiment_',num2str(initial_pos_config),'.mat');
%     save(filename,'battery','delta_battery', 'graphs', 'trees', 'positions')


% 
% %% Experiment 2 - RANDOM, REALISTIC
% initial_pos_config=1;
% useRandomAsg=true;
% useRealisticSim=true;
% PLOTGRAPH=false;
% close all;
% 
% batteryTEMP=[];delta_batteryTEMP=[];
% graphs=[];
% trees=[];
% positions=[];
% for i=1:100
%     [bat,dbat,initial_graph,initial_tree,initial_pos] = cost_based_selection(initial_pos_config,useRandomAsg,useRealisticSim,PLOTGRAPH);
%     graphs{i}=initial_graph;
%     trees{i}=initial_tree;
%     positions{i}=initial_pos;
%     batteryTEMP=[batteryTEMP;bat];
%     delta_batteryTEMP=[delta_batteryTEMP;dbat];
% end
% save('2_random_withbat_decay.mat','battery','delta_battery', 'graphs', 'trees', 'positions')
% figure(2); plot(bat);
% figure(3); plot(dbat);
% 
% %% Experiment 3 - AUCTION, NOT REALISTIC
% initial_pos_config=1;
% useRandomAsg=false;
% useRealisticSim=false;
% PLOTGRAPH=false;
% close all;
% 
% batteryTEMP=[];delta_batteryTEMP=[];
% graphs=[];
% trees=[];
% positions=[];
% for i=1:100
%     [bat,dbat,initial_graph,initial_tree,initial_pos] = cost_based_selection(initial_pos_config,useRandomAsg,useRealisticSim,PLOTGRAPH);
%     graphs{i}=initial_graph;
%     trees{i}=initial_tree;
%     positions{i}=initial_pos;
%     batteryTEMP=[batteryTEMP;bat];
%     delta_batteryTEMP=[delta_batteryTEMP;dbat];
% end
% save('3_auction_nobat_decay.mat','battery','delta_battery', 'graphs', 'trees', 'positions')
% figure(2); plot(bat);
% figure(3); plot(dbat);
% 
% %% Experiment 4 - AUCTION, REALISTIC
% initial_pos_config=1;
% useRandomAsg=false;
% useRealisticSim=true;
% PLOTGRAPH=false;
% close all;
% 
% batteryTEMP=[];delta_batteryTEMP=[];
% graphs=[];
% trees=[];
% positions=[];
% for i=1:100
%     [bat,dbat,initial_graph,initial_tree,initial_pos] = cost_based_selection(initial_pos_config,useRandomAsg,useRealisticSim,PLOTGRAPH);
%     graphs{i}=initial_graph;
%     trees{i}=initial_tree;
%     positions{i}=initial_pos;
%     batteryTEMP=[batteryTEMP;bat];
%     delta_batteryTEMP=[delta_batteryTEMP;dbat];
% end
% save('4_auction_withbat_decay.mat','battery','delta_battery', 'graphs', 'trees', 'positions')
% figure(2); plot(bat);
% figure(3); plot(dbat);