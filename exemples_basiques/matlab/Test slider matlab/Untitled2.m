close all,clear all,clc

 sldchanger; 
function sldchanger

ip='172.31.1.147'; % The IP of the controller
% start a connection with the server
t_Kuka=net_establishConnection( ip );
relVel = 0,15;

 

if ~exist('t_Kuka','var') || isempty(t_Kuka) || strcmp(t_Kuka.Status,'closed')
  warning('Connection could not be establised, script aborted');
  return;
else

 

    
label = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.45, 0.65, 0.1, 0.1]);

 
sliderCallback;
function sliderCallback(hObject)
    % Callback appelé lorsqu'on déplace le slider
    angle = get(hObject, 'Value');  % Obtenir la valeur du slider
    set(label, 'String', ['Angle: ', num2str(angle, '%.2f')]);  % Mettre à jour l'étiquette
    controlRobot(angle);  % Appeler la fonction de contrôle du robot
end

 

function controlRobot(angle)
    % Fonction de contrôle du robot en fonction de l'angle
    % Remplacez cette fonction par votre logique de contrôle réelle

 

    % Afficher l'angle de l'articulation
    disp(['Contrôle de l''articulation avec un angle de ', num2str(angle, '%.2f'), ' radians.']);

 

    % Appeler une fonction pour déplacer l'articulation du robot (remplacez par votre code)
    movePTPJointSpace( t_Kuka , angle, relVel);  % Remplacez par votre fonction de déplacement du robot
end    


    %% move to initial position
%%pinit={0,pi*20/180,0,-pi*70/180,0,pi*90/180,0}; % initial confuguration
%%relVel=0.15; % relative velocity
%%movePTPJointSpace( t_Kuka , pinit, relVel); % point to point motion in joint space

 

      %% turn off the server
       net_turnOffServer( t_Kuka );

 

       fclose(t_Kuka);
end