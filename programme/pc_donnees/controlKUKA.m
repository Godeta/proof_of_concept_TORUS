function controlKUKA()
    disp('Program started');
    
    % Obtenir le chemin du répertoire KST
    kst_Path = getTheKSTDirectory(pwd);
    addpath(kst_Path);
    
    % Etabli une connexion avec CoppeliaSim
    vrep = remApi('remoteApi');
    vrep.simxFinish(-1);
    clientID = vrep.simxStart('127.0.0.1', 1997, true, true, 5000, 5);
    ip = '172.31.1.147'; % Adresse IP du robot Kuka 
    global t_Kuka;
    if (clientID > -1)
        t_Kuka = net_establishConnection(ip);
        if ~exist('t_Kuka', 'var') || isempty(t_Kuka) || strcmp(t_Kuka.Status, 'closed')
            warning('Connection could not be establised, script aborted');
            return;
        end
        
        % Récupère les articulations du robot 
        jHandles = zeros(7, 1);
        for i = 1:7
            s = ['LBR_iiwa_7_R800_joint', num2str(i)];
            [res, daHandle] = vrep.simxGetObjectHandle(clientID, s, vrep.simx_opmode_oneshot_wait);
            jHandles(i) = daHandle;
        end
    else
        return;
    end
    
    %Définit les positions des articulations et la vitesse relative
    jPos = {0, 0, 0, -pi/180 * 90, 0, pi/180*90, 0};
    relVel = 0.25;
    
    % Déplace le robot aux positions jPos
    movePTPJointSpace(t_Kuka, jPos, relVel);
    
    % Controle des joints en temps réel
    realTime_startDirectServoJoints(t_Kuka);
    
    % Pause de sécurité de lancement
    pause(5);
    counter = 0;
    tic; %Début du chrono
    totalTimeSecs = 160; % 160 secondes de simulation
    
    % Démarre la simulation
    vrep.simxStartSimulation(clientID, vrep.simx_opmode_oneshot_wait);
    
    % Gestion des joints en temps réel
    for i = 1:7
        [res, tempPos] = vrep.simxGetJointPosition(clientID, jHandles(i), vrep.simx_opmode_streaming);
    end
    
    % Défini la vitesse dans CoppeliaSim
    vrep.simxWriteStringStream(clientID, 'path_velocity', '0.07', vrep.simx_opmode_oneshot_wait);
    jpos = zeros(7, 25000); % Tableau pour stocker les positions des joints
    t_0 = toc; % Créer un temps de référence
    
    % Boucle principale de controle
    while (t_0 < totalTimeSecs)
        % Récupère les positions des joints
        for i = 1:7
            [res, tempPos] = vrep.simxGetJointPosition(clientID, jHandles(i), vrep.simx_opmode_buffer);
            jPos{i} = tempPos;
        end
        
        % Si plus de 3 ms se sont écoulées, envoie les positions des articulations au robot KUKA
        if (toc - t_0 > 0.003)
            counter = counter + 1;
            sendJointsPositionsf(t_Kuka, jPos);
            for i = 1:7
                jpos(i, counter) = jPos{i};
            end
            t_0 = toc;
        end
    end
    
    % Arrête le serveur du robot Kuka 
    net_turnOffServer(t_Kuka);
    vrep.simxStopSimulation(clientID, vrep.simx_opmode_oneshot_wait);
    vrep.simxFinish(clientID);
    vrep.delete();
end
