% Vérification si la webcam est déjà allumée
if ~exist('cam', 'var') || ~isvalid(cam)
    %cam = webcam('FULL HD 1080P Webcam'); % Caméra de Arnaud
    %cam = webcam("USB2.0 HD UVC WebCam"); % Caméra de ton pc
    cam = webcam("USB2.0 HD UVC WebCam");
end

% Création d'une figure pour afficher la vidéo en direct
figure;

% Ouverture du fichier CSV en écriture
%fileID = fopen('resultats.csv', 'w');
%fprintf(fileID, 'X,Y\n'); % En-têtes des colonnes

addpath('../realTimeControl_iiwa_From_Vrep/');
vrep=remApi('remoteApi'); vrep.simxFinish(-1); 
clientID=vrep.simxStart('127.0.0.1',19997,true,true,5000,1);
connected = false;
if (clientID>-1)
connected = true;
disp('Connected to remote API server');
%% ---------------------------------start simulation-----------------------
vrep.simxStartSimulation(clientID,vrep.simx_opmode_oneshot_wait);   

% Boucle principale
    while ishandle(1)
        tic;  % Réinitialiser la temporisation
        % Capture d'une image depuis la webcam
        img = snapshot(cam);

        % Dimensions de l'image
        [height, width, ~] = size(img);

        % Facteur de zoom (par exemple, 2 pour zoomer 2x)
        zoomFactor = 1.5;

        % Calcul de la nouvelle largeur
        newWidth = floor(width / zoomFactor);

        % Calcul des indices de recadrage pour obtenir la partie centrale
        xStart = floor((width - newWidth) / 2) + 1;
        xEnd = xStart + newWidth - 1;
        if xStart < 1
            xStart = 1;
        end
        if xEnd > width
            xEnd = width;
        end

        % Recadrer l'image pour obtenir la partie centrale
        croppedImg = img(:, xStart:xEnd, :);

        % Redimensionner l'image recadrée à la taille originale pour un zoom horizontal
        zoomedImg = imresize(croppedImg, [height, width]);

        % Conversion de l'image RGB en espace de couleur HSV
        img_hsv = rgb2hsv(zoomedImg);

        % Détection de la balle bleue
        blue_mask = (img_hsv(:,:,1) >= 0.5 & img_hsv(:,:,1) <= 0.7) & ...
                    (img_hsv(:,:,2) >= 0.5 & img_hsv(:,:,3) >= 0.2);

        % Appliquer le masque à l'image originale
        img_blue = zoomedImg;
        img_blue(repmat(~blue_mask, [1, 1, 3])) = 0;

        % Affichage de l'image avec la balle bleue mise en évidence
        imshow(img_blue);

        % Optionnel : obtenir les coordonnées de la balle bleue
        [row, col] = find(blue_mask);
        if length(row) >= 2 && length(col) >= 2
            % Sélectionner les deux premiers points bleus détectés
            point2=point1;
            point1 = [col(1), row(1)];
            
            % Calcul du vecteur entre les deux points
            vector = point2 - point1;
            hold on;
            plot(point1(1),point1(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
            plot(point2(1),point2(2), 'g+', 'MarkerSize', 30, 'LineWidth', 2);
              % **Affichage de la ligne entre les points**
            line([point1(1), point2(1)], [point1(2), point2(2)], 'Color', 'w', 'LineWidth', 2);

            fprintf('Vecteur entre les deux points bleus : (%.2f, %.2f)\n', vector);

            % Envoyer les coordonnées des deux points et le vecteur à V-REP
            vrep.simxSetFloatSignal(clientID, 'point1X', point1(1), vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'point1Y', point1(2), vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'point2X', point2(1), vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'point2Y', point2(2), vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'vectorX', vector(1), vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'vectorY', vector(2), vrep.simx_opmode_oneshot);
        else
            fprintf('Moins de deux points bleus détectés.\n');
            vrep.simxSetFloatSignal(clientID, 'point1X', -1, vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'point1Y', -1, vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'point2X', -1, vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'point2Y', -1, vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'vectorX', 0, vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'vectorY', 0, vrep.simx_opmode_oneshot);
        end

        % Pause pour permettre l'affichage en temps réel
        drawnow;
        pause(0.1);
        
        
    end
    % Arrêt de la simulation
    vrep.simxStopSimulation(clientID, vrep.simx_opmode_oneshot_wait);
    % Fermeture du client
    vrep.simxFinish(clientID);
    vrep.delete();

    % Libération des ressources de la webcam à la fin
    clear cam;
else
    disp('Failed connecting to remote API server');
end
