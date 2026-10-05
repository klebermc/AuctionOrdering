function [x_out, A] = simulate_agents_pos(x, A, N, n, d, int_range_r, DEBUG)

x(n+1:n+n,:)=zeros(n,size(x,2));
mean_vel_h=[];
if DEBUG
%% Starting figure
close all
figure
hold on
grid on

end
%% Flocking algorithm and misc. variables
epslon = 0.5; %flocking parameter
dt=0.1;  %time stpe of the simulation
sigma_d = Auxiliar.sigma_norm(d); %used for flocking
sigma_int_range = Auxiliar.sigma_norm(int_range_r); %used for flocking
kp=1; %gain
kv=2;   %gain
%d=1;   %desired distance between nodes
%int_range_r = 1; %range of my sensors 

for t=dt:dt:200
    k=round(t/dt);
    %cla
    objects_in_fig=[];
    clc;
    %First the node will check its connections
    for i=1:N
        %who is close (therefore, connected)
        for j=1:N
            %In a real scenario, I would not iterate through all vehicles, 
            %but through all sensors to see "who" am I seeing
            if i~=j 
                if norm(x(1:n,i,k)-x(1:n,j,k),2)<=int_range_r ... %node is close
                   && A(i,j)==0 %node is not connected
                       [ A, hops_graph ] = Auxiliar_DynNet.change_net_topology_add(A,i,j);
                end
                if norm(x(1:n,i,k)-x(1:n,j,k),2)>int_range_r ... %node is not close
                   && A(i,j)==1 %node is connected
                    [ A, hops_graph ] = Auxiliar_DynNet.change_net_topology_remove(A,i,j);
                end
            end
        end
    end
    
    
    %simulating each node
    for i=1:N
        % Figure plot
        % --------------- 
%          plot(x(1,i,k), 0.5, 'xr'); %1D
%          text(x(1,i,k)+0.01, 0.5+0.01, num2str(i)); %1D
        if DEBUG; objects_in_fig=[objects_in_fig,plot(x(1,i,k),x(2,i,k), 'xr')]; end
        if DEBUG; objects_in_fig=[objects_in_fig,text(x(1,i,k)+0.01,x(2,i,k)+0.01, num2str(i))]; end
        posi = x(1:n,i,k);
        veli = x(n+1:n+n,i,k);
        u = x(n+1:n+n,1,1)*0;
        
        for j=1:N
%             if A(i,j)~=0; disp([i,j]);end
            if i~=j && A(i,j)~=0
                posj = x(1:n,j,k);
                velj = x(n+1:n+n,j,k);

                dif = posj-posi;
                sigma_dif = Auxiliar.sigma_norm(dif);
                
                phi_alpha = Auxiliar.rho_h(sigma_dif/sigma_int_range)*Auxiliar.sigma_1(sigma_dif-sigma_d);
                nij= dif/sqrt(1+epslon*norm(dif,2)^2);

                u = u + kp*phi_alpha*nij + kv*Auxiliar.rho_h(sigma_dif/sigma_int_range)*A(i,j)*(velj-veli);
                %disp([i,j,phi_alpha,nij', (phi_alpha*nij)', (Auxiliar.rho_h(sigma_dif/sigma_int_range)*A(i,j)*(velj-veli))'])
                if i>j
                    if DEBUG; objects_in_fig=[objects_in_fig,plot([x(1,i,k) x(1,j,k)],[x(2,i,k) x(2,j,k)], 'k','linewidth',0.5)];  end
                    %uncomment below to see the desired actual distance between nodes
                    %objects_in_fig=[objects_in_fig,text(mean([x(1,i,k) x(1,j,k)]),mean([x(2,i,k) x(2,j,k)]), strcat('d=',num2str(norm((x(1:n,i,k)-x(1:n,j,k)),2),3)))];
                end
            end
        end
        if i == 1
            u=u+0.01*(posi*0 - posi)+0.01*(veli*0-veli);
        end
            
        %First order Euler integration for node dynamics
        x(1:n,i,k+1)     = posi + dt*veli + ((dt^2)/2)*u;
        next_vel =           veli +         dt*u;
        x(n+1:n+n,i,k+1) =saturate(next_vel);
    end
    mean_vel_h=[mean_vel_h, mean(sqrt(sum(x(n+1:n+n,:,k+1).^2,1)))];
    if length(mean_vel_h)>1
        derivative_vel=diff(mean_vel_h);
        disp([t, abs(derivative_vel(end)),mean_vel_h(end)])
        if abs(derivative_vel(end))<1e-4 && mean_vel_h(end) < N/10000   %0.0018   0.0180   0.0300    0.01
            break; %stopped decreasing vel, standing still
        end
    end
    if DEBUG 
        axis ([min(x(1,:,k))-1 max(x(1,:,k))+1 min(x(2,:,k))-1 max(x(2,:,k))+1])
        drawnow; 
        pause(dt); 
    end
    if DEBUG; delete(objects_in_fig); end
end
x_out=x(1:n,:,k) ;
end
    
function vSat=saturate(vector)
vectorMag = norm(vector);
if vectorMag>0.1
    vSat=(vector/vectorMag)*0.1;
else
    vSat=vector;
end

end