# Make sure to have the server side running in CoppeliaSim: 
# in a child script of a CoppeliaSim scene, add following command
# to be executed just once, at simulation start:
#
# simRemoteApi.start(19999)
#
# then start simulation, and run this program.
#
# IMPORTANT: for each successful call to simxStart, there
# should be a corresponding call to simxFinish at the end!

try:
    import sim
except:
    print ('--------------------------------------------------------------')
    print ('"sim.py" could not be imported. This means very probably that')
    print ('either "sim.py" or the remoteApi library could not be found.')
    print ('Make sure both are in the same folder as this file,')
    print ('or appropriately adjust the file "sim.py"')
    print ('--------------------------------------------------------------')
    print ('')

import time
import array
import numpy as np
from PIL import Image as I
import cv2 as cv

def returnCameraIndexes():
    # checks the first 10 indexes.
    index = 0
    arr = []
    i = 10
    while i > 0:
        cap = cv.VideoCapture(index)
        if cap.read()[0]:
            arr.append(index)
            cap.release()
        index += 1
        i -= 1
    return arr

# cap = cv.VideoCapture(1)
# if not cap.isOpened():
#     print("Cannot open camera")
#     exit()
# while True:
#     # Capture frame-by-frame
#     ret, frame = cap.read()
#     # if frame is read correctly ret is True
#     if not ret:
#         print("Can't receive frame (stream end?). Exiting ...")
#         break
#     # Our operations on the frame come here
#     gray = cv.cvtColor(frame, cv.COLOR_BGR2GRAY)
#     # Display the resulting frame
#     cv.imshow('frame', gray)
#     if cv.waitKey(1) == ord('q'):
#         break
# # When everything done, release the capture
# cap.release()
# cv.destroyAllWindows()
# voir https://docs.opencv.org/4.x/dd/d43/tutorial_py_video_display.html

# print(returnCameraIndexes())
# exit()
print ('Program started')
sim.simxFinish(-1) # just in case, close all opened connections
clientID=sim.simxStart('127.0.0.1',19999,True,True,5000,5) # Connect to CoppeliaSim
if clientID!=-1:
    print ('Connected to remote API server')

    # Now try to retrieve data in a blocking fashion (i.e. a service call):
    res,objs=sim.simxGetObjects(clientID,sim.sim_handle_all,sim.simx_opmode_blocking)
    if res==sim.simx_return_ok:
        print ('Number of objects in the scene: ',len(objs))
    else:
        print ('Remote API function call returned with error code: ',res)

    time.sleep(2)

    # Now retrieve streaming data (i.e. in a non-blocking fashion):
    startTime=time.time()
    sim.simxGetIntegerParameter(clientID,sim.sim_intparam_mouse_x,sim.simx_opmode_streaming) # Initialize streaming
    while time.time()-startTime < 1:
        returnCode,data=sim.simxGetIntegerParameter(clientID,sim.sim_intparam_mouse_x,sim.simx_opmode_buffer) # Try to retrieve the streamed data
        if returnCode==sim.simx_return_ok: # After initialization of streaming, it will take a few ms before the first value arrives, so check the return code
            print ('Mouse position x: ',data) # Mouse position x is actualized when the cursor is over CoppeliaSim's window
        time.sleep(0.005)

    # Now send some data to CoppeliaSim in a non-blocking fashion:
    sim.simxAddStatusbarMessage(clientID,'Hello CoppeliaSim!',sim.simx_opmode_oneshot)
    
    # inspiré par https://python.hotexamples.com/examples/vrep/-/simxGetVisionSensorImage/python-simxgetvisionsensorimage-function-examples.html
    # et surtout https://github.com/nemilya/vrep-api-python-opencv/blob/master/handle_vision_sensor.py
    res, v0 = sim.simxGetObjectHandle(clientID, '/VisionSensor', sim.simx_opmode_oneshot_wait)
    res, v1 = sim.simxGetObjectHandle(clientID, '/v1', sim.simx_opmode_oneshot_wait)
    err, resolution, image = sim.simxGetVisionSensorImage(clientID, v0, 0, sim.simx_opmode_streaming)
    time.sleep(1)
    while time.time()-startTime < 3:
        err, resolution, image = sim.simxGetVisionSensorImage(clientID, v0, 0, sim.simx_opmode_buffer)
        # print(image)
        # image = image.astype(np.uint8)
        # print(image.shape, image.dtype)
        # image_byte_array = array.array('b', image)
        # # print(image_byte_array.shape, image_byte_array.dtype)
        # image_buffer = I.frombuffer("RGB", (resolution[0],resolution[1]), image_byte_array, "raw", "RGB", 0, 1)
        # image2 = np.asarray(image_buffer)
        image2=np.array(image).reshape((256,256,3)).astype(np.uint8)
        # image2 = cv.flip(cv.cvtColor(image2, cv.COLOR_BGR2RGB), 0)
        # print(image2.shape, image2.dtype)
        # print(np.array(image).reshape((256,256,3)))
        cv.imshow('frame',image2)
        time.sleep(2)
        if err == sim.simx_return_ok:
            sim.simxSetVisionSensorImage(clientID, v1, image, 0, sim.simx_opmode_oneshot)
        elif err == sim.simx_return_novalue_flag:
            print("no image yet")
        else:
            print(err)

    # image = np.asarray(image)
    # cv.imshow('frame',image)
    # vrep.simxSetVisionSensorImage(clientID, v1, img2, 0, vrep.simx_opmode_oneshot)

    # while (time.time()-startTime) < 10:
    #     img, [resX, resY] = sim.simxGetVisionSensorImage(visionSensorHandle)
    #     img = np.frombuffer(img, dtype=np.uint8).reshape(resY, resX, 3)

    #     # In CoppeliaSim images are left to right (x-axis), and bottom to top (y-axis)
    #     # (consistent with the axes of vision sensors, pointing Z outwards, Y up)
    #     # and color format is RGB triplets, whereas OpenCV uses BGR:
    #     img = cv.flip(cv.cvtColor(img, cv.COLOR_BGR2RGB), 0)

    #     cv.imshow('', img)
    #     cv.waitKey(1)
    #     sim.step()  # triggers next simulation step

    # sim.stopSimulation()

    # cv.destroyAllWindows()

    # print('Program ended')

    # Before closing the connection to CoppeliaSim, make sure that the last command sent out had time to arrive. You can guarantee this with (for example):
    sim.simxGetPingTime(clientID)

    # Now close the connection to CoppeliaSim:
    sim.simxFinish(clientID)
else:
    print ('Failed connecting to remote API server')
print ('Program ended')
