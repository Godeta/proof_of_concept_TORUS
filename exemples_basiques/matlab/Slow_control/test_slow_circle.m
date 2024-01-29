% initialisation à la position de base
close all;clear;clc;
warning('off')
%% Create the robot object
ip='172.31.1.147'; % The IP of the controller
arg1=KST.LBR7R800; % choose the robot iiwa7R800 or iiwa14R820
arg2=KST.Medien_Flansch_elektrisch; % choose the type of flange
Tef_flange=eye(4); % transofrm matrix of EEF with respect to flange.
Tef_flange(3,4)=30/1000;
iiwa=KST(ip,arg1,arg2,Tef_flange); % create the object

%% Start a connection with the server
flag=iiwa.net_establishConnection();
if flag==0
  return;
end
pause(1);

%gestion de la vitesse de déplacement
relVel=0.15; % over ride relative joint velocities
pos={0, 0, 0,-pi/180 *90, 0,-pi/180*90, 0};   % initial configuration
iiwa.movePTPJointSpace( pos, relVel); % go to initial position

%boucle du cercle
timerval = tic; 
while 1
    endval = toc(timerval);
    try;
%         iiwa.doCircle();

        doCircle(iiwa);
    catch exception
        % Catch and handle the error
        fprintf('An error occurred: %s\n', exception.message);
        iiwa.net_turnOffServer();
    end
    if endval>=3
        break
    end
end
%tic/toc are built in matlab functions to count time. This utilizes them to count seconds for length of time running through the loop

%retour à la position de base
relVel=0.15; % over ride relative joint velocities
pos={0, 0, 0, 0, 0,0, 0};   % initial configuration
iiwa.movePTPJointSpace( pos, relVel); % go to initial position

%% couper le serveur
disp('Turn off server');
iiwa.net_turnOffServer();
warning('on')