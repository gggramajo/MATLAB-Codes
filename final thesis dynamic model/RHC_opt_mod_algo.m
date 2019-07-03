% this RHC function optimizes the control for energy constrain and
% redirects the vehicle to uncovered area of the region.


function [rhc]=RHC_opt_mod_algo(omega_dot,turn_duration,tspan,x0,y0,theta0,p_exit,E_batt_remain,Power_req,boundaryx,boundaryy,covered_area_x,covered_area_y,xc,yc,vel,epsilon,gravity,rho,wing_area,Cd_zero,Cd_i,eta)
Velocity=vel;
W=omega_dot;
p=p_exit;
parameter=[Velocity W];
[~,Y]=ode45(@equa_mot,tspan,[x0,y0,theta0],[],parameter);
Y(1,:)=[];
cal_path_X(:,1)=Y(:,1);
cal_path_Y(:,1)=Y(:,2);
X_exit=abs(cal_path_X(end)-p(1,1));
Y_exit=abs(cal_path_Y(end)-p(1,2));
dist_exit=sqrt(X_exit.^2+Y_exit.^2);
Time_exit=dist_exit/(Velocity);
load_fac=sqrt((W*Velocity/gravity)^2+1);
P_required=.5*rho*wing_area*Velocity^3*(Cd_zero+load_fac^2*Cd_i)/eta;
time_remain_battery=(E_batt_remain-(P_required*turn_duration))/Power_req;
condition=time_remain_battery-Time_exit;
path=[cal_path_X cal_path_Y];
[x_C,y_C]=area_for_turn_rate_path(path,xc,yc);
[X_c,Y_c]=poly2cw(x_C,y_C);
[cov_x,cov_y]=polybool('subtraction',X_c,Y_c,covered_area_x,covered_area_y);
[X_C,Y_C]=polybool('intersection',boundaryx,boundaryy,cov_x,cov_y);
[all_cov_x,all_cov_y]=polybool('union',X_c,Y_c,covered_area_x,covered_area_y);
[x_c,y_c]=polybool('intersection',boundaryx,boundaryy,all_cov_x,all_cov_y);

%starts to calculate the possible area that each possible
%path can cover
test_nan=isnan(X_C);
if all(test_nan==0)
    cal_poss_area=polyarea(X_C,Y_C);
    poss_area=cal_poss_area;
else
    nan_cells=find(test_nan==1);
    size_vector=size(nan_cells,2)+1;
    cell_dummy=1;
    cal_poss_area=0;
    for count_split_area=1:size_vector
        cell_num=cell_dummy;
        if count_split_area==size_vector
            cal_poss_area1=polyarea(X_C(1,cell_dummy:end),Y_C(1,cell_dummy:end));
            cal_poss_area=cal_poss_area+cal_poss_area1;
        else
            cell_num_end=nan_cells(count_split_area)-1;
            cal_poss_area1=polyarea(X_C(1,cell_num:cell_num_end),Y_C(1,cell_num:cell_num_end));
            cal_poss_area=cal_poss_area+cal_poss_area1;
            cell_dummy=nan_cells(count_split_area)+1;
        end
    end
    poss_area=cal_poss_area;
end 

%area not covered
[area_need_cove_x,area_need_cove_y]=polybool('subtraction',boundaryx,boundaryy,x_c,y_c);
test_nan=isnan(area_need_cove_x);
if all(test_nan==0)
    [x_bar, y_bar,~]=xycentroid(area_need_cove_x,area_need_cove_y);
else
    nan_cell=find(test_nan==1);
    size_vector=size(nan_cell,2)+1;
    cell_dummy=1;
    for count_split_area=1:size_vector
        cell_num=cell_dummy;
        if count_split_area==size_vector
            cal_poss_area1=polyarea(area_need_cove_x(1,cell_dummy:end),area_need_cove_y(1,cell_dummy:end));
            cal_poss_area(count_split_area,1)=cal_poss_area1;
        else
            cell_num_end=nan_cell(count_split_area)-1;
            cal_poss_area1=polyarea(area_need_cove_x(1,cell_num:cell_num_end),area_need_cove_y(1,cell_num:cell_num_end));
            cal_poss_area(count_split_area,1)=cal_poss_area1;
            cell_dummy=nan_cell(count_split_area)+1;
        end
    end
    [~,minvec]=max(cal_poss_area);
    if minvec==size_vector
        xx_C=area_need_cove_x(1,nan_cell(minvec-1)+1:end);
        yy_C=area_need_cove_y(1,nan_cell(minvec-1)+1:end);
        [x_bar, y_bar,~]=xycentroid(xx_C,yy_C);
    elseif minvec==1
        xx_C=area_need_cove_x(1,1:nan_cell(1)-1);
        yy_C=area_need_cove_y(1,1:nan_cell(1)-1);
        [x_bar, y_bar,~] = xycentroid(xx_C,yy_C);
    else
        xx_C=area_need_cove_x(1,nan_cell(minvec-1)+1:nan_cell(minvec)-1);
        yy_C=area_need_cove_y(1,nan_cell(minvec-1)+1:nan_cell(minvec)-1);
        [x_bar, y_bar,~] = xycentroid(xx_C,yy_C);
    end
end 

%calculates the way inwhich to redirect the vehicle
if condition>Time_exit
    cost1=1/(poss_area);
    if cost1==inf
        x_cen=abs(cal_path_X(end)-x_bar);
        y_cen=abs(cal_path_Y(end)-y_bar);
        Dist_cen=sqrt(x_cen.^2+y_cen.^2);
        cost1=Dist_cen;
    end
elseif condition>=0 && condition<=Time_exit
    cost1=0;
else
    cost1=0;
end

if condition>Time_exit
    cost2=0;
elseif condition>=0 && condition<=Time_exit
    cost2=1/(condition+epsilon);
else
    cost2=dist_exit;
end

rhc=cost1+cost2;