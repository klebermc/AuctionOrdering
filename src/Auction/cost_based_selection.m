 function [bat,dbat,initial_graph,initial_tree,initial_pos] = cost_based_selection(...
                                                                initial_pos_config,...
                                                                useRandomAsg,...
                                                                useRealisticSim,...
                                                                PLOTGRAPH,...
                                                                initial_graph,initial_tree,initial_pos,...
                                                                FIRSTEXECUTION)
%Set of structures, each structure position contains the number of parts that structure will need

% experiment=1;
% useRandomAsg=true;
% useRealisticSim=false;
% PLOTGRAPH=false;

int_range_r = 1.33; %range of my sensors 
d=1;   %desired distance between nodes


switch (initial_pos_config)
    case 1
        %experiment 1
        St=[5,6,7];
    case 2
        %experiment 2
        St=[50,60,70];
    case 3
        %experiment 3
        St=[100,100,100];
    case 4
        St=[330,330,340];

end
posST=[ [-10;-10] , [10;-10] , [0;10] ];

    %Create the nodes in space
    N=sum(St);
    n=2;                % Variables of the state of each node
    A=zeros(N,N);       % Ajacency Matrix
    x=inf(n,N);
    x(:,1)=zeros(n,1);
    for i=2:N 
        xnew=x(:,i-1);
        counterTries=0;
        dist=0.6;
        while any(sum((x-xnew).^2,1)<0.5^2)
            counterTries=counterTries+1;
            if counterTries>100
                dist=d;
            end
            if counterTries>200
                break;
            end
            [xi,yi]=pol2cart(rand*2*pi,dist);
            xnew=[xi;yi]+x(:,i-1);
    
        end
        x(:,i)=xnew;
    end

    
    %ASSIGNED VECTOR
    state_node.assigned=zeros(1,N);

    %BATTERY VECTOR
    min_bat=0.5;
    max_bat=0.9;
    state_node.bat=(max_bat-min_bat)*rand(1,N) + min_bat; 
    initial_bat=state_node.bat;
    % assigned and battery
    
if FIRSTEXECUTION
    [x, A] = simulate_agents_pos(x, A, N, n, d, int_range_r, false);

    G=graph(A);
    hops_graph=distances(G);
    pin=Auxiliar_DynNet.newpin_using_gramian( hops_graph, 1, A);

    %Then Compute MST
    % [T,pred] = minspantree(G);
    % highlight(h,T);
    [T.tree,T.parent] = minspantree(G,'Root',pin(1));
else
    G = initial_graph;
    hops_graph=distances(G);
    T = initial_tree;
    x = initial_pos;
    pin = find(T.parent == 0);
end

if PLOTGRAPH 
    hold on
    grid on 
    plot(x(1,pin),x(2,pin),'ko','MarkerSize',25,'Linewidth',1.5); %auctioneer
    %Plotting structures
    for j=1:length(St)
%         plot(posST(1,j),posST(2,j), 'rx', 'MarkerSize',10)
    end
    valid_bids=[];
    axis equal
end

initial_graph=G;
initial_tree=T;
initial_pos=x;



tic
%Now, iteratively selects nodes from network
for idxAsgn=1:N
    if PLOTGRAPH
        FontSizes=16;
        alreadyAssigned = state_node.assigned > 0;
        nodeNumbers=1:N;
        nodes2remove=nodeNumbers(alreadyAssigned);
        

        
        if isempty(nodes2remove)
            sub_G = G;
            sub_x=x;
            sub_T.tree=T.tree;
        else
            sub_G = rmnode(G,nodes2remove);
            sub_x=x;
            sub_x(:,nodes2remove)=[];
            sub_T.tree=rmnode(T.tree,nodes2remove);
        end
        h(1)=plot(sub_G,'XData',sub_x(1,:),'YData',sub_x(2,:), 'Linewidth', 1.0, 'MarkerSize', 8, 'NodeFontSize', FontSizes, 'LineStyle','-','EdgeColor','black', 'NodeColor','blue');
        xlabel('Pos X_I [m]');
        ylabel('Pos Y_I [m]');
        grid on;
        axis equal;

        notAssigned = state_node.assigned == 0;
        nodes2stay=nodeNumbers(notAssigned);
        for idx=1:length(nodes2stay);labelnode(h(1),idx,num2str(nodes2stay(idx))); end
        
        ax=gca;
        ax.FontSize=FontSizes;
        highlight(h(1),sub_T.tree,'EdgeColor',[0.8 0 0],'LineWidth',2,'LineStyle','--');

        axDim=axis;
        xRange=abs(axDim(1))+abs(axDim(2));
        yRange=abs(axDim(3))+abs(axDim(4));
        xBorders=[0.14 0.1];
        yBorders=[0.13 0.075];
        multipliers = [ xRange/(1-sum(xBorders)) yRange/(1-sum(yBorders))];

        if idxAsgn == 1
        h(2)=annotation('textarrow', ([-2 x(1,pin)-0.5]-axDim(1))/multipliers(1)+xBorders(1),...
                                     ([-1 x(2,pin)]-axDim(3))/multipliers(2)+yBorders(1),...
                                    'String', 'Auctioneer','Color','k', 'Linewidth',1.0, 'FontSize',FontSizes);
        end

        if idxAsgn == 1
        h(3)=annotation('textarrow', ([-3 -2]-axDim(1))/multipliers(1)+xBorders(1),...
                                     ([ 0  0]-axDim(3))/multipliers(2)+yBorders(1),...
                                    'String', 'MST','Color','k', 'Linewidth',1.0, 'FontSize',FontSizes);
        end

        if idxAsgn == 1
        h(4)=annotation('textarrow', ([-3 -2.2 ]-axDim(1))/multipliers(1)+xBorders(1),...
                                     ([0.5 0.5]-axDim(3))/multipliers(2)+yBorders(1),...
                                    'String', 'R_l^u','Color','k', 'Linewidth',1.0, 'FontSize',FontSizes);
        end
    end
    
    
    st=mod(idxAsgn,3)+1
%     st = randi(length(St));
    while St(st)==0
        st = randi(length(St));
    end
    
    %Compute the auction
    for i=1:N
        %each agend sends its bid
        c(i,idxAsgn) = score(x(:,i), posST(:,st),state_node.bat(i));
    end
    p_s=posST(:,st);
    
    for i=1:N
        %discard invalid bids (not leaves and already assigned
        if state_node.assigned(i) > 0 || any(T.parent - i == 0)
            c(i,idxAsgn) = 0;
        else
            if PLOTGRAPH; valid_bids=[valid_bids,plot(x(1,i),x(2,i),'k*','MarkerSize',10,'LineWidth',2.0)]; end
        end
    end
    
    if useRandomAsg
        winnerRand = randi(N);
        while c(winnerRand,idxAsgn)==0
            winnerRand = randi(N);
        end
        winner=winnerRand;
    else
        [~,winner] = max(c(:,idxAsgn)); %maximum reward wins        
    end
    
    pos_winner=x(:,winner);

    if useRealisticSim
        %Decay to move to the structure
        bat_decay=norm( x(:,winner) - posST(:,st) )/100;
        state_node.bat(winner) = state_node.bat(winner) - bat_decay;
    end
    
    [xwin,ywin]=pol2cart(winner*(2*pi/N),0.5);
    x(:,winner) = posST(:,st)+[xwin;ywin]; % robot moves
    state_node.assigned(winner)=st;        % which structure it moves to
    T.parent(winner)=0;                    % remove from the tree structure
    
    %Update tree
    newT.tree = T.tree; for i=1:N; newT.tree = rmedge(newT.tree,winner,i); end
    T.tree=newT.tree;
    %Update graph
    newG = G; for i=1:N; newG = rmedge(newG,winner,i); end
    G=newG;
    
    St(st) = St(st) -1 ; %this structure needs 1 less node     
    
    if useRealisticSim
        %battery decay
        for i=1:N
            if state_node.assigned(i)==0
                state_node.bat(i)=state_node.bat(i)-0.001;
            end
        end
    end

    if idxAsgn == 1
        exportgraphics(gcf, strcat('assignment_initial.pdf'), 'ContentType', 'vector');
        delete(h(2:4))
    end
    if idxAsgn <= 3

        dim1=[0.15 0.5 0.3 0.3];
        dim2=[0.15 0.8 0.1 0.1];
        if idxAsgn==1
            xWinLabel=[pos_winner(1)+0.5 pos_winner(1)];
            yWinLabel=[pos_winner(2)-1.5 pos_winner(2)-0.2];
        else
            xWinLabel=[pos_winner(1)+0.1 pos_winner(1)];
            yWinLabel=[pos_winner(2)+1.5 pos_winner(2)+0.2];
        end
        h(5)=annotation('textarrow', (xWinLabel-axDim(1))/multipliers(1)+xBorders(1),...
                                     (yWinLabel-axDim(3))/multipliers(2)+yBorders(1),...
                                    'String', 'Winner robot','Color','k', 'Linewidth',1.0, 'FontSize',FontSizes);
        str = {'$ID ~~ ~~~ c_{ij}$'};
        row=2;
        for idxROBOT=1:N
            if c(idxROBOT,idxAsgn) ~= 0
                if idxROBOT<10
                    str{row}=strcat(num2str(idxROBOT) , ' ~~  ~~ ' , sprintf('%.2f',c(idxROBOT,idxAsgn)));
                else
                    str{row}=strcat(num2str(idxROBOT) , ' ~ ~~ ' , sprintf('%.2f',c(idxROBOT,idxAsgn)));
                end
                row=row+1;
            end
        end


        h(6)=annotation('textbox',dim1,'String',str,'FitBoxToText','on','Color','k',...
                        'Linewidth',1.0, 'FontSize',FontSizes, 'Interpreter','latex');

        str = {strcat('$\textbf{\textit{p}}^s = [' , num2str(p_s(1)) , ' , ', num2str(p_s(2)), ']$') };
        h(7)=annotation('textbox',dim2,'String',str,'FitBoxToText','on','Color','k', ...
                        'LineWidth',1.0, 'FontSize',FontSizes, 'Interpreter','latex');

         pause(0.1)       
    end

    final_bat=state_node.bat;
     exportgraphics(gcf, strcat('assignment',num2str(idxAsgn),'.pdf'), 'ContentType', 'vector');
    save('experiment_figure_step_by_step.mat','initial_bat','final_bat','c')

    if PLOTGRAPH
        pause(0.1)
        delete(valid_bids)
        delete(h)
    end
    fprintf('%.2f ',(idxAsgn*100)/N)

if idxAsgn>5
    break
end

end
toc
if PLOTGRAPH
    h=plot(G,'XData',x(1,:),'YData',x(2,:));
    highlight(h,T.tree);
    drawnow
    pause(0.1);
end
final_bat=state_node.bat;


bat=[mean(final_bat) median(final_bat) std(final_bat)];
delta_bat=initial_bat-final_bat;
dbat=[mean(delta_bat) median(delta_bat) std(delta_bat) min(delta_bat) max(delta_bat)];
% bat=final_bat;
% dbat=delta_bat;
end
 
function cij = score(pos, posST, bat)

cij = 1/ norm(pos-posST) + 1/bat;

end