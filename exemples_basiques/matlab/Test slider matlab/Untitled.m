sldchanger; 

% function to generate slider and a 
% dummy dial to show changed values 
function sldchanger 
fig = uifigure; 

dial = uigauge(fig); 

% Creating the slider and assigning 
% its values to the dial/gauge created above 
slid = uislider(fig,'ValueChangedFcn',@(slid,event) changedial(slid,dial)); 

% setting limits to 0 to 23 
slid.Limits = [0 23]; 
end

% ValueChangedFcn event handler 
function changedial(slid,dial) 

% changing dialer values to slider 
% values after each slide 
dial.Value = slid.Value; 
end
