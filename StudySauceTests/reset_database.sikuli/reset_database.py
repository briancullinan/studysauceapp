from sikuli import *

def returnToHome():
    switchApp("Simulator")
    wait(1)
    simulator = Region(App.focusedWindow())
    while simulator.exists("Screen Shot 2015-11-29 at 1.57.31 PM.png"):
        simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
    if simulator.exists("Screen Shot 2016-01-07 at 3.43.15 PM.png"):
        simulator.click("Screen Shot 2016-01-07 at 3.43.15 PM.png")
        

def run():
    returnToHome()
    switchApp("Simulator")
    wait(1)
    simulator = Region(App.focusedWindow())
    if simulator.exists("Screen Shot 2015-11-28 at 9.39.12 PM.png"):
        simulator.click("Screen Shot 2015-11-28 at 9.39.12 PM.png")
    if simulator.exists("Screen Shot 2016-01-07 at 2.46.11 PM.png"):
        simulator.click("Screen Shot 2016-01-07 at 2.46.11 PM.png")
    wait(1)
    if simulator.exists("Screen Shot 2016-01-07 at 2.49.26 PM.png"):
        for x in range(0, 10):
            simulator.click("Screen Shot 2016-01-07 at 2.49.26 PM.png")