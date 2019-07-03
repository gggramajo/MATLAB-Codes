%this script optimizes the trajectory for energy constrain and turning rate range

%%%%%%%%%%%%%%%%%%%%%%%%% Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%EC                    :Electric charge of the battery for the vehicle
%E_batt                :Total energy stored in battery 
%W_area                 :Wing area
%W_span                 :Wing span
%V_mass                 :mass of vehicle
%Cd_zero                :zero lift drag
%max_load               :maximum load factor for the vehicel during a turn 
%alt                    :operating altitude
%dt                     :turn duration
%p_hor                  :planning horizon
%ex_hor                 :execution horizon
%p_entry                :entry point coordinates
%Theta                  :entry orientation
%CD                     :total drag coefficient
%CL                     :lift coefficient
%Power_req              :power required steady level flight
%Dis_total              :Total distance the airplanes travel in ideal steady level flight 
%max_area               :ideal maximum area
%Area                   :Area of the specified region   
%x0_c                   :x component of the footprint area at entry
%y0_c                   :y component of the footprint area at entry
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc
load_system('navion_simulation_Gramajo_yaw_rate_feedback')

%aircraft specifications 
EC=2200;                                                   %mAh
Voltage=11.1;                                              %volts
E_batt=EC*Voltage/1000;                                    %Wh
gravity=9.81;                                              %m/sec^2
V_mass=5;                                                  %kg (vehicle mass)
Weight=V_mass*gravity;                                     %N
CL=.6;                                                     %lift coefficient from NavionOut.op file 
CD=.06;
e=1;
eta=.9;
AR=(aero1{1,1}.blref)^2/aero1{1,1}.sref;
Cd_i=CL^2/(pi*AR*e);
W_area=aero1{1,1}.sref;                                    % from NavionOut file 
W_span=aero1{1,1}.blref;

%input conditions
max_load=1.5;
alt=121.92;                                                %meters
dt=13;                                                     %sec
p_hor=1*dt;                                                %sec
ex_hor=1*dt;                                                 %sec
p_entry=[10 200 -alt];
Theta=0*pi/180;                                           %rad

%Calculates needed values
rho=density_cal(alt);                                      %kg/m^3
Velocity=sqrt(2*Weight/(rho*W_area)*(1/CL));               %m/s
max_turn_rate=gravity*sqrt(max_load^2-1)/Velocity;         %rad/s
Power_req=rho*W_area*Velocity^3*CD/(2*eta);                %W
Time=round(E_batt*60/Power_req);                           %min
Time_sec=Time*60;                                          %sec
max_power_req=.5*rho*W_area*Velocity^3*(CD+max_load^2*Cd_i)/eta;

%footprint of camera
rc=50;                                                      %meters
angle=linspace(0,2*pi,40);
xc=rc*cos(angle);
yc=rc*sin(angle);

%create region in space
Dis_total=Velocity*Time_sec;                                %meters
max_area=Dis_total*rc/2+pi*(rc)^2;                            %m^2
boundary_length=sqrt(max_area);                             %m
boundaryx=[boundary_length+10 boundary_length+10 10 10 boundary_length+10];     %x points of the region meters
boundaryy=[boundary_length+10 10 10 boundary_length+10 boundary_length+10];     %y points of the region meters
plot(boundaryx,boundaryy)
hold on 

%Initiates exit
p_exit=[10 boundary_length+10 alt];

epsilon=.02;

%initiates area calculation 
Area=polyarea(boundaryx,boundaryy);                         %m^2
x0_c=p_entry(1)+xc;
y0_c=p_entry(2)+yc;
[X0,Y0]=poly2cw(x0_c,y0_c);
[top_level_footprint_x,top_level_footprint_y]=polybool('intersection', boundaryx,boundaryy,X0,Y0);  %produces the vector of the polygon 
top_level_area_cov=polyarea(top_level_footprint_x,top_level_footprint_y);

%Rotation matrix 
R=[0 1 0;1 0 0;0 0 -1];

%Initial condition
Vb=[Velocity 0 0];
Angle=[0 0];

%initiates path
entry_point=[p_entry Theta 0];
top_PATH=entry_point;

%measures the count (calculates the amount of for loops)
counter=0;
ct=ceil(p_hor/dt);
Ct=ceil(ex_hor/dt);

%initiates the energy remaining 
top_level_E=E_batt*3600;                               %Joules
Time_sec=400;     

%calculates the trajectory 
%while top_level_E>0
for ii=1:ceil(Time_sec/dt)
    bottom_Path=entry_point;
    top_level_path_area=top_level_area_cov;
    top_level_covered_area_x=top_level_footprint_x;
    top_level_covered_area_y=top_level_footprint_y;
    area_cov=top_level_area_cov;
    footprint_x=top_level_footprint_x;
    footprint_y=top_level_footprint_y;
    Energy_remain_battery=top_level_E;
    
    if (max_power_req*dt)>=Energy_remain_battery
        break;
    end
    
    %calculates the trajectory for the planing horizon
    ctrl=zeros(ct,1);
    for count=1:ct
        E_batt_remain=Energy_remain_battery;
        if (max_power_req*dt)>=E_batt_remain
            break;
        end
        h=bottom_Path(end,:);
        path_area=area_cov;
        covered_area_x=footprint_x;
        covered_area_y=footprint_y;
        if count<ct
            span=0:1:dt;
        else 
            span=0:1:(p_hor/dt-(count-1))*dt;
        end
        t0=counter*ex_hor+dt*(count-1);
        tspan=t0+span;
        
        %calculates the optimal trajectories in the planning horizon
        x0=h(1,1);
        y0=h(1,2);
        theta0=h(1,4);
        min_cost=@(omega_dot)RHC_opt(omega_dot,tspan,x0,y0,theta0,p_exit,boundaryx,boundaryy,covered_area_x,covered_area_y,xc',yc',Velocity,epsilon,Time_sec);
        [desired_omega,fval]=fminbnd(min_cost,-max_turn_rate,max_turn_rate,optimset('TolX',1e-4,'MaxIter',50,'MaxFunEvals',50));
        ctrl(count)=desired_omega;
        pass_param=[Velocity desired_omega];
        [~,calc_path]=ode45(@equa_mot,span,[x0,y0,theta0],[],pass_param);
        plot(calc_path(:,1),calc_path(:,2))
        calc_path(1,:)=[];
        load_fac=sqrt((desired_omega*Velocity/gravity)^2+1);
        P_required=.5*rho*W_area*Velocity^3*(CD+load_fac^2*Cd_i)/eta;
        Energy_remain_battery=E_batt_remain-P_required*dt;
        c_path(1:length(calc_path),1)=alt;
        sel_path=[calc_path(:,1) calc_path(:,2) c_path(1:end) calc_path(:,3)];
        Time_vec=tspan(2:end)';
        [x_c,y_c]=area_for_turn_rate_path(sel_path(:,1:2),xc',yc');
        [Xc,Yc]=poly2cw(x_c,y_c);
        [fp_cov_pol_x,fp_cov_pol_y]=polybool('union',covered_area_x,covered_area_y,Xc,Yc);
        [cov_inside_boundary_x,cov_inside_boundary_y]=polybool('intersection',boundaryx,boundaryy,fp_cov_pol_x,fp_cov_pol_y);
        [fp_new_position_x,fp_new_position_y]=polybool('subtraction',Xc,Yc,covered_area_x,covered_area_y);
        [fp_new_position_ccw_x,fp_new_position_ccw_y]=poly2cw(fp_new_position_x,fp_new_position_y);
        [covered_poly_x,covered_poly_y]=polybool('intersection',boundaryx,boundaryy,fp_new_position_ccw_x,fp_new_position_ccw_y);
        [ccw_x,ccw_y]=poly2cw(covered_poly_x,covered_poly_y);
        test_nan=isnan(ccw_x);
        if all(test_nan==0)
            area_new_pos=polyarea(ccw_x,ccw_y);
             area_cov=area_new_pos+path_area;
        else
            nan_cells=find(test_nan==1);
            size_vector=size(nan_cells,2)+1;
            cell_dummy=1;
            area_new_pos=0;
            for count_split_area=1:size_vector
                cell_num=cell_dummy;
                if count_split_area==size_vector
                    cal_area_new_pos=polyarea(ccw_x(1,cell_dummy:end),ccw_y(1,cell_dummy:end));
                    area_new_pos=cal_area_new_pos+area_new_pos;
                else
                    cell_num_end=nan_cells(count_split_area)-1;
                    cal_area_new_pos=polyarea(ccw_x(1,cell_num:cell_num_end),ccw_y(1,cell_num:cell_num_end));
                    area_new_pos=cal_area_new_pos+area_new_pos;
                    cell_dummy=nan_cells(count_split_area)+1;
                end
            end
            area_cov=area_new_pos+path_area;
        end
        footprint_x=cov_inside_boundary_x;
        footprint_y=cov_inside_boundary_y;
        bottom_Path=[bottom_Path;sel_path Time_vec];
    end
    
    %calcluates data for executed horizon using simulation
    pass_E_re=top_level_E;
    pass_path=top_PATH(end,:);
    h0=pass_path(4);
    Rr=[cos(pass_path(4)-pi/2) -sin(pass_path(4)-pi/2) 0;sin(pass_path(4)-pi/2) cos(pass_path(4)-pi/2) 0;0 0 1];
    sim_path=pass_path;
    for cot=1:Ct
        init_val=pass_path(1:3);
        if cot==Ct
            u=[];
            u(:,1)=0:((ex_hor/dt)-(cot-1))*dt;
            u(:,2)=-ctrl(cot);
            sim_tspan=0:.1:dt*(ex_hor/dt-(cot-1));
        else
            u=[];
            u(:,1)=0:dt;
            u(:,2)=-ctrl(cot);
            sim_tspan=0:.1:dt;
        end
        sel_load=sqrt((ctrl(cot)*Velocity/gravity)^2+1);
        E_c=.5*rho*W_area*Velocity^3*(CD+sel_load^2*Cd_i)/eta;
        Sim_Time_vec=sim_tspan+(counter*ex_hor+(cot-1)*dt);
        [~,~,Out1,Out2,Out3,Out4,Out5]=sim('navion_simulation_Gramajo_yaw_rate_feedback',sim_tspan,[],u);
        Vb=Out3(end,:);
        h0=Out1(end,3);
        path_add(1:length(Out3),1)=pass_path(1);
        path_add(1:length(Out3),2)=pass_path(2);
        path_add(1:length(Out3),3)=0;
        sim_path_out=(Rr*(R*(Out1)'))'+path_add;
        pass_path=Out1(end,:);
        sim_path_out(1,:)=[];
        Sim_Time_vec(1)=[];
        sim_path=[sim_path;sim_path_out sim_path(end,4)-Out2(2:end,3) Sim_Time_vec'];
        pass_E_re=pass_E_re-E_c*sim_tspan(end);
    end
    top_PATH=[top_PATH;sim_path(2:end,:)];
    entry_point=top_PATH(end,:);
    top_level_E=pass_E_re;
    
    %calclautes the area vectors of the execution horizon
    [top_level_x_c,top_level_y_c]=area_for_turn_rate_path(sim_path(:,1:2),xc',yc');
    [top_level_Xc,top_level_Yc]=poly2cw(top_level_x_c,top_level_y_c);
    [top_level_fp_cov_pol_x,top_level_fp_cov_pol_y]=polybool('union',top_level_covered_area_x,top_level_covered_area_y,top_level_Xc,top_level_Yc);
    [top_level_cov_inside_boundary_x,top_level_cov_inside_boundary_y]=polybool('intersection',boundaryx,boundaryy,top_level_fp_cov_pol_x,top_level_fp_cov_pol_y);
    [top_level_fp_new_position_x,top_level_fp_new_position_y]=polybool('subtraction',top_level_Xc,top_level_Yc,top_level_covered_area_x,top_level_covered_area_y);
    [top_level_fp_new_position_ccw_x,top_level_fp_new_position_ccw_y]=poly2cw(top_level_fp_new_position_x,top_level_fp_new_position_y);
    [top_level_covered_poly_x,top_level_covered_poly_y]=polybool('intersection',boundaryx,boundaryy,top_level_fp_new_position_ccw_x,top_level_fp_new_position_ccw_y);
    [top_level_ccw_x,top_level_ccw_y]=poly2cw(top_level_covered_poly_x,top_level_covered_poly_y);
    test_nan=isnan(top_level_ccw_x);
    if all(test_nan==0)
        top_level_area_new_pos=polyarea(top_level_ccw_x,top_level_ccw_y);
        top_level_area_cov=top_level_area_new_pos+top_level_path_area;
    else
        nan_cells=find(test_nan==1);
        size_vector=size(nan_cells,2)+1;
        cell_dummy=1;
        top_level_area_new_pos=0;
        for count_split_area=1:size_vector
            cell_num=cell_dummy;
            if count_split_area==size_vector
                cal_area_new_pos=polyarea(top_level_ccw_x(1,cell_dummy:end),top_level_ccw_y(1,cell_dummy:end));
                top_level_area_new_pos=cal_area_new_pos+top_level_area_new_pos;
            else
                cell_num_end=nan_cells(count_split_area)-1;
                cal_area_new_pos=polyarea(top_level_ccw_x(1,cell_num:cell_num_end),top_level_ccw_y(1,cell_num:cell_num_end));
                top_level_area_new_pos=cal_area_new_pos+top_level_area_new_pos;
                cell_dummy=nan_cells(count_split_area)+1;
            end
        end
        top_level_area_cov=top_level_area_new_pos+top_level_path_area;
    end
    top_level_footprint_x=top_level_cov_inside_boundary_x;
    top_level_footprint_y=top_level_cov_inside_boundary_y;
    top_level_area_covered=top_level_area_cov;
    
    %keeps count of the amount of execution horizon during the mission
    %duration
    plot(top_PATH(:,1),top_PATH(:,2))
    counter=counter+1;
end
plot(top_level_footprint_x,top_level_footprint_y)
%plot(top_PATH(:,1),top_PATH(:,2))
coverage_perc=top_level_area_covered/Area*100
dist_exit=sqrt(sum((top_PATH(end,1:2)-p_exit(1:2)).^2))
miss_dur=top_PATH(end,5)
Energy_remain_battery

close_system('navion_simulation_Gramajo_yaw_rate_feedback')