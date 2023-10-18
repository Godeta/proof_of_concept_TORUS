%% Example
% An example script to control a robot joint using a slider
% Mohammad SAFEEA, 3rd of May 2017
% Modified for joint control with a slider using movePTPJointSpace

 

close all, clear all, clc

 

% Robot initial joint configuration
initialJointAngles = [0, pi * 20 / 180, 0, -pi * 70 / 180, 0, pi * 90 / 180, 0];

 

% IP address of the robot
robotIP = '172.31.1.147';

 

% Create a figure for the slider
fig = figure('Name', 'Robot Joint Control', 'NumberTitle', 'off', 'Position', [100, 100, 400, 200]);

 

% Create a slider for controlling the joint angle
slider = uicontrol('Style', 'slider', 'Min', -pi, 'Max', pi, 'Value', 0, ...
    'Units', 'normalized', 'Position', [0.1, 0.4, 0.8, 0.2], ...
    'Callback', @sliderCallback);

 

% Label to display the joint angle
label = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.45, 0.65, 0.1, 0.1]);

 

% Function to control the robot joint based on the slider value
function sliderCallback(hObject, ~)
    % Callback called when the slider is moved
    angle = get(hObject, 'Value');  % Get the slider value
    set(label, 'String', ['Angle: ', num2str(angle, '%.2f')]);  % Update the label
    controlRobot(angle);  % Call the robot control function
end

 

% Function to control the robot joint using movePTPJointSpace
function controlRobot(angle)
    % Display the joint angle
    disp(['Controlling the joint with an angle of ', num2str(angle, '%.2f'), ' radians.']);

    % Use movePTPJointSpace to move the robot to the specified joint configuration
    movePTPJointSpace(angle, robotIP);
end

 

% Function to move the robot using movePTPJointSpace
function movePTPJointSpace(angle, ip)
    % Replace this with your code to move the robot using movePTPJointSpace
    % For demonstration purposes, we'll just display a message
    disp(['Moving the robot using movePTPJointSpace to an angle of ', num2str(angle, '%.2f'), ' radians.']);
    disp(['Robot IP: ', ip]);  % Display the robot IP address
end