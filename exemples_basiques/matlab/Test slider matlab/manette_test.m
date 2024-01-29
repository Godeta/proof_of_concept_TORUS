% Créer une connexion à la manette Xbox
joy = vrjoystick(1);  % Assurez-vous que votre manette est correctement connectée

% Boucle pour lire les données
disp('Appuyez sur Ctrl+C pour arrêter la lecture.');
while true
    % Lire les données de la manette
    [axes, buttons, povs] = read(joy);

    % Afficher les données
    disp('Axes:');
    disp(axes);
    
    disp('Boutons:');
    disp(buttons);
    
    disp('POVs (Hats):');
    disp(povs);

    % Pause pour éviter une sortie rapide des données
    pause(0.1);
end
