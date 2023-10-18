# création d'une fenêtre et ajout d'un texte, quelques widgets basics : https://tkdocs.com/tutorial/widgets.html
import tkinter as tk
from PIL import Image, ImageTk
import sim
import time
import sys
import keyboard

# import os 
# from controller_input import *

window = tk.Tk()
window.title("Kuka robot control")
canvas =tk.Canvas(window,width=600,height=300)
canvas.grid(columnspan=3, rowspan=6)

# affichage infos
label1= tk.Label(window, text= "", font= ('Helvetica 17 bold'))

# partie CoppeliaSIm
def simConnect():
    "Connection à CoppeliaSIm en local avec l'ID 22222"
    
    global clientID
    print("Program Started")
    sim.simxFinish(-1)
    clientID = sim.simxStart('127.0.0.1', 22222, True, True, 5000, 5)

    if(clientID != -1):
        print('Connected Successfully.')
    else:
        print('Failed To connect.')
    time.sleep(1)
    return clientID

def getControls():
    "Récupère les contrôles des joints du robot"
    error_code, joint1 = sim.simxGetObjectHandle(clientID, '/LBRiiwa7R800/joint', sim.simx_opmode_oneshot_wait)
    error_code, joint2 = sim.simxGetObjectHandle(clientID, '/LBRiiwa7R800/link2_resp/joint', sim.simx_opmode_oneshot_wait)
    error_code, joint3 = sim.simxGetObjectHandle(clientID, '/LBRiiwa7R800/link3_resp/joint', sim.simx_opmode_oneshot_wait)
    error_code, joint4 = sim.simxGetObjectHandle(clientID, '/LBRiiwa7R800/link3_resp/joint', sim.simx_opmode_oneshot_wait)
    return joint1, joint2, joint3, joint4

def keyBoardControls(event):
    "Manage controls with keyboard"
    label1.config(text="You pressed"+ event.keysym)
    if keyboard.is_pressed("a"):
        global jval1
        jval1=jval1+0.1
        print("\nYou pressed 'a'. %s" % jval1)
        error_code = sim.c_SetJointTargetPosition(clientID, joint1, jval1,sim.simx_opmode_oneshot_wait)
    if keyboard.is_pressed("z"):
        global jval2
        jval2=jval2+0.1
        print("You pressed 'z'.")
        error_code = sim.c_SetJointTargetPosition(clientID, joint2, jval2,sim.simx_opmode_oneshot_wait)
    if keyboard.is_pressed("e"):
        global jval3
        jval3=jval3+0.1
        print("You pressed 'e'.")
        error_code = sim.c_SetJointTargetPosition(clientID, joint3, jval3,sim.simx_opmode_oneshot_wait)
    if keyboard.is_pressed("r"):
        print("You pressed 'r'.")
        error_code = sim.c_SetJointTargetPosition(clientID, joint4 , 1,sim.simx_opmode_oneshot_wait)

def controller(event):
    "Manage controls with controller"
    

# autres
def launchOsAction(action,choice = "all"):
    "Fonction permettant d'agir sur le système "
    # f = open("url.txt", "w")
    # f.write(url)
    # f.close()
    # commande = 'cd traitement_donnees && php exe_application.php '+choice
    # os.system(commande)
    # print (url+ "\n"+choice)

# Partie interface
def printVal(val):
    "Mouvement vers position de base"
    print("You pressed the %s button" % val)
    error_code = sim.c_SetJointTargetPosition(clientID, joint1, 0,sim.simx_opmode_oneshot_wait)
    error_code = sim.c_SetJointTargetPosition(clientID, joint2, 0,sim.simx_opmode_oneshot_wait)
    error_code = sim.c_SetJointTargetPosition(clientID, joint3, 0,sim.simx_opmode_oneshot_wait)
    error_code = sim.c_SetJointTargetPosition(clientID, '/LBRiiwa7R800/link4_resp/joint' , 0,sim.simx_opmode_oneshot_wait)
    jval1=0
    jval2=0
    jval3=0

def createWindow():
    "Fonction principale contenant la création de la fenêtre et ses intéractions "
    label1.config(text="Appuyez sur une touche")
    label1.grid(column=1, row=0)

    btnMove = tk.Button(window, text="Move", command=lambda: printVal(1))
    btnMove.grid(column=2, row=0)

    # logo 
    logo = Image.open("logo.png")
    logo = logo.resize((100, 100))
    logo = ImageTk.PhotoImage(logo)
    logo_label = tk.Label(image=logo)
    logo_label.image = logo
    logo_label.grid(column=1, row=1)
    window.iconphoto(False,logo)

    # instructions
    instructions = tk.Label(window,text="Entrez 1, 2 ou 3 pour une action prédéfinie",font="Raleway")
    instructions.grid(columnspan=3,column=0,row=2)

    # Entrée de l'action
    label = tk.Label(window,text="Action",font="Raleway")
    entry = tk.Entry(fg="black", bg="white", width=50)
    label.grid(column=1,row=3)
    entry.grid(column =1, row=4)

    # boutton pour lancer le programme php
    launch_text = tk.StringVar()
    launch_btn = tk.Button(window,textvariable=launch_text,font="Raleway",
    bg="#46b86c",fg="white", 
    height=2, width=15,
    command= lambda:launchOsAction(entry.get()))
    launch_text.set("Executer l'action")
    launch_btn.grid(column=1,row=5)
    
    simConnect()
    label1.config(text="Statut connection :"+str(clientID))
    global joint1, joint2, joint3, joint4
    joint1, joint2, joint3, joint4 = getControls()
    # evenements
    global jval1, jval2, jval3
    jval1 =0
    jval2 =0
    jval3 =0
    window.bind('<Key>',keyBoardControls)
    window.mainloop()

#code principal executé lors de l'appel du fichier python

createWindow()
