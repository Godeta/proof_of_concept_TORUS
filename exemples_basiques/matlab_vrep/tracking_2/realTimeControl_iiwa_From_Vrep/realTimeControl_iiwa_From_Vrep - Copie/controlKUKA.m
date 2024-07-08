function controlKUKA()
    disp('Program started');
    kst_Path = getTheKSTDirectory(pwd);
    addpath(kst_Path);
    vrep = remApi('remoteApi');
    vrep.simxFinish(-1);
    clientID = vrep.simxStart('127.0.0.1', 1997, true, true, 5000, 5);
    ip = '172.31.1.147';
    global t_Kuka;
    if (clientID > -1)
        t_Kuka = net_establishConnection(ip);
        if ~exist('t_Kuka', 'var') || isempty(t_Kuka) || strcmp(t_Kuka.Status, 'closed')
            warning('Connection could not be establised, script aborted');
            return;
        end
        jHandles = zeros(7, 1);
        for i = 1:7
            s = ['LBR_iiwa_7_R800_joint', num2str(i)];
            [res, daHandle] = vrep.simxGetObjectHandle(clientID, s, vrep.simx_opmode_oneshot_wait);
            jHandles(i) = daHandle;
        end
    else
        return;
    end
    jPos = {0, 0, 0, -pi/180 * 90, 0, pi/180*90, 0};
    relVel = 0.25;
    movePTPJointSpace(t_Kuka, jPos, relVel);
    
    realTime_startDirectServoJoints(t_Kuka);
    pause(10);
    counter = 0;
    tic;
    totalTimeSecs = 160; % 60 seconds of execution time
    vrep.simxStartSimulation(clientID, vrep.simx_opmode_oneshot_wait);
    
    for i = 1:7
        [res, tempPos] = vrep.simxGetJointPosition(clientID, jHandles(i), vrep.simx_opmode_streaming);
    end
    vrep.simxWriteStringStream(clientID, 'path_velocity', '0.07', vrep.simx_opmode_oneshot_wait);
    jpos = zeros(7, 25000);
    t_0 = toc;
    while (t_0 < totalTimeSecs)
        for i = 1:7
            [res, tempPos] = vrep.simxGetJointPosition(clientID, jHandles(i), vrep.simx_opmode_buffer);
            jPos{i} = tempPos;
        end
        if (toc - t_0 > 0.003)
            counter = counter + 1;
            sendJointsPositionsf(t_Kuka, jPos);
            for i = 1:7
                jpos(i, counter) = jPos{i};
            end
            t_0 = toc;
        end
    end
    
    net_turnOffServer(t_Kuka);
    vrep.simxStopSimulation(clientID, vrep.simx_opmode_oneshot_wait);
    vrep.simxFinish(clientID);
    vrep.delete();
end
