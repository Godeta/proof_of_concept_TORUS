import time

import numpy as np
import cv2

print('Program started')

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
# sim.setVisionSensorImage(passiveVisionSensorHandle, byte_im)
# print(type(img))
img2 = np.frombuffer(img, dtype=np.uint8).reshape(resY, resX, 3)

# In CoppeliaSim images are left to right (x-axis), and bottom to top (y-axis)
# (consistent with the axes of vision sensors, pointing Z outwards, Y up)
# and color format is RGB triplets, whereas OpenCV uses BGR:
img2 = cv2.flip(cv2.cvtColor(img2, cv2.COLOR_BGR2RGB), 0)

cv2.imshow('t', img2)
cv2.imwrite("testIMG.bmp", img2) 
cv2.waitKey(1)

cap.release()

cv2.destroyAllWindows()

print('Program ended')

# pistes : https://copyprogramming.com/howto/how-to-convert-an-image-into-an-array-of-it-s-raw-pixel-data 
# https://stackoverflow.com/questions/22351254/python-script-to-convert-image-into-byte-array
# or using BytesIO
# io_buf = io.BytesIO(im_buf_arr)
# byte_im = io_buf.getvalue()