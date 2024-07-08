% Vérification si la webcam est déjà allumée
if ~exist('cam', 'var') || ~isvalid(cam)
    %cam = webcam('FULL HD 1080P Webcam'); % Webcam du prototype
     cam = webcam(); % Webcam par défaut (webcam du pc)
end

% Création d'une figure pour afficher la vidéo en direct
figure;

% Créer la liaison avec CoppeliaSim
vrep = remApi('remoteApi');
vrep.simxFinish(-1);
clientID = vrep.simxStart('127.0.0.1', 19998, true, true, 5000, 1);
connected = false;
if (clientID > -1)
    connected = true;
    disp('Connected to remote API server');
    vrep.simxStartSimulation(clientID, vrep.simx_opmode_oneshot_wait);

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
        blue_mask = (img_hsv(:,:,1) >= 0.5 & img_hsv(:,:,1) <= 0.6) & ...
                    (img_hsv(:,:,2) >= 0.5 & img_hsv(:,:,3) >= 0.4);

        % Appliquer le masque à l'image originale
        img_blue = zoomedImg;
        img_blue(repmat(~blue_mask, [1, 1, 3])) = 0;

        % Affichage de l'image avec la balle bleue mise en évidence
        imshow(img_blue);
       
        % Pause pour permettre l'affichage en temps réel
        drawnow;
        pause(0.1);
        
        % Obtenir les coordonnées de la balle bleue
        [row, col] = find(blue_mask);
        if ~isempty(row) && ~isempty(col)
            centroid = [mean(col), mean(row)];
            fprintf('Coordonnées de la balle bleue : (%.2f, %.2f)\n', centroid);
            vrep.simxSetFloatSignal(clientID, 'centroidX', centroid(1), vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'centroidY', centroid(2), vrep.simx_opmode_oneshot);
        else
            fprintf('Balle bleue non détectée.\n');
            vrep.simxSetFloatSignal(clientID, 'centroidX', -1, vrep.simx_opmode_oneshot);
            vrep.simxSetFloatSignal(clientID, 'centroidY', -1, vrep.simx_opmode_oneshot);
        end
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
