# Make sure to have the add-on "ZMQ remote API" running in
# CoppeliaSim and have following scene loaded:
#
# scenes/messaging/synchronousImageTransmissionViaRemoteApi.ttt
#
# Do not launch simulation, but run this script
#
# All CoppeliaSim commands will run in blocking mode (block
# until a reply from CoppeliaSim is received). For a non-
# blocking example, see simpleTest-nonBlocking.py

import time

import numpy as np
import cv2

from coppeliasim_zmqremoteapi_client import RemoteAPIClient


print('Program started')

client = RemoteAPIClient()
sim = client.getObject('sim')

visionSensorHandle = sim.getObject('/VisionSensor')
passiveVisionSensorHandle = sim.getObject('/v1')

# When simulation is not running, ZMQ message handling could be a bit
# slow, since the idle loop runs at 8 Hz by default. So let's make
# sure that the idle loop runs at full speed for this program:
defaultIdleFps = sim.getInt32Param(sim.intparam_idle_fps)
sim.setInt32Param(sim.intparam_idle_fps, 0)

# Run a simulation in stepping mode:
client.setStepping(True)
sim.startSimulation()

while (t := sim.getSimulationTime()) < 15:
    img, resX, resY = sim.getVisionSensorCharImage(visionSensorHandle)

    # test avec image autre capteur
    # sim.setVisionSensorImage(passiveVisionSensorHandle, img)

    # test image webcam
    cap = cv2.VideoCapture(1)
    if not cap.isOpened():
        print("Cannot open camera")
        exit()
    #     # Capture frame-by-frame
    ret, frame = cap.read()
    # if frame is read correctly ret is True
    if not ret:
        print("Can't receive frame (stream end?). Exiting ...")
        break
    # Our operations on the frame come here
    # gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    # Display the resulting frame
    cv2.imshow('frame', frame)
    # frame = cv2.imread("testIMG.raw") 
    # print(frame.shape)
    im_resize = cv2.resize(frame, (256, 256))
    # print(im_resize.shape)
    is_success, im_buf_arr = cv2.imencode(".bmp", im_resize)
    
    byte_im = im_buf_arr.tobytes()
    print(len(byte_im))
    sim.setVisionSensorImage(passiveVisionSensorHandle, byte_im)
    sim.pauseSimulation()
    # print(type(img))
    img2 = np.frombuffer(img, dtype=np.uint8).reshape(resY, resX, 3)

    # In CoppeliaSim images are left to right (x-axis), and bottom to top (y-axis)
    # (consistent with the axes of vision sensors, pointing Z outwards, Y up)
    # and color format is RGB triplets, whereas OpenCV uses BGR:
    img2 = cv2.flip(cv2.cvtColor(img2, cv2.COLOR_BGR2RGB), 0)
    
    cv2.imshow('t', img2)
    cv2.imwrite("testIMG.bmp", img2) 
    cv2.waitKey(1)
    client.step()  # triggers next simulation step

sim.stopSimulation()
cap.release()

# Restore the original idle loop frequency:
sim.setInt32Param(sim.intparam_idle_fps, defaultIdleFps)

cv2.destroyAllWindows()

print('Program ended')
