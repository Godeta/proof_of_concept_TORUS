function runBothPrograms()
    % Create a parallel pool if it does not exist
    if isempty(gcp('nocreate'))
        parpool;
    end
    
    % Create futures for the two functions
    f1 = parfeval(@controlKUKA, 0);
    f2 = parfeval(@controlWebcam, 0);
    
    % Wait for both functions to complete
    wait([f1, f2]);
end
