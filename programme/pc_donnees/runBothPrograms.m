function runBothPrograms()
    % Créé un pool parallèle s'il n'existe pas
    if isempty(gcp('nocreate'))
        parpool;
    end
    
    % Créé des tâches pour les deux fonctions
    f1 = parfeval(@controlKUKA, 0);
    f2 = parfeval(@controlWebcam, 0);
    
    % Attendre que les deux fonctions se lancent
    wait([f1, f2]);
end
