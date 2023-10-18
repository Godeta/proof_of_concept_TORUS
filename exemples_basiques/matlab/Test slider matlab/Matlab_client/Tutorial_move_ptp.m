close all,clear all,clc
sldchanger; 
function sldchanger 
fig = uifigure; 

%%dial = uigauge(fig); 

% Creating the slider and assigning 
% its values to the dial/gauge created above 
slid = uislider(fig,'ValueChangedFcn',@(slid,event) changedial(slid,dial)); 

% setting limits to 20 to 40 
slid.Limits = [20 40]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ip='172.31.1.147'; % The IP of the controller
% start a connection with the server
t_Kuka=net_establishConnection( ip );

if ~exist('t_Kuka','var') || isempty(t_Kuka) || strcmp(t_Kuka.Status,'closed')
  warning('Connection could not be establised, script aborted');
  return;
else
   
    %% move to initial position
%pinit={0,pi*20/180,0,-pi*70/180,0,pi*90/180,0}; % initial confuguration
%relVel=0.15; % relative velocity
%movePTPJointSpace( t_Kuka , pinit, relVel); % point to point motion in joint space

ptest={0,pi*40/180,0,-pi*70/180,0,pi*90/180,0}; % initial confuguration
relVel=0.15; % relative velocity
pause(0.1)
movePTPJointSpace( t_Kuka , ptest, relVel); % point to point motion in joint space

ptest2={0,pi*'slid'/180,0,-pi*70/180,0,pi*90/180,0}; % initial confuguration
relVel=0.15; % relative velocity
pause(10)
movePTPJointSpace( t_Kuka , ptest2, relVel); % point to point motion in joint space
      %% PTP motion
      %jPos={}
      %%homePos={}
     %[ jPos ] = getJointsPos( t_Kuka ) % get current joints position

      
           
      %%for ttt=1:7  % home position
          %%homePos{ttt}=0;
      %%end
      
      %%pause(0.1)
     % relVel=0.15;
      %%movePTPJointSpace( t_Kuka , homePos, relVel); % go to home position
      %%pause(0.1)
     % movePTPJointSpace( t_Kuka , jPos, relVel); % return back to original position
      
      %% turn off the server
       net_turnOffServer( t_Kuka );


       fclose(t_Kuka);
end
end

