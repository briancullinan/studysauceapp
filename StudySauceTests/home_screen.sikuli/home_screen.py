from sikuli import *

sequence = [{0: true, 1: true, 2: true, 3: false, 4: true, 5: true, 6: true, 7: true, 8: true, 9: true, 10:true, 11: true, 12: true, 13: true, 14: true, 15: true},
        {0: true, 1: true, 2: true, 3: false, 4: true, 5: true, 6: true, 7: true, 8: true, 9: true, 10:true, 11: true, 12: true, 13: true, 14: true, 15: true}]

def home_download:
    simulator.click("Screen Shot 2015-12-01 at 1.18.19 PM.png")
    wait(1)
    simulator.click("Screen Shot 2015-12-01 at 1.19.29 PM.png")
    wait(1)
    simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
    wait(1)
    simulator.click("Screen Shot 2015-12-07 at 7.13.50 PM.png")
    wait(1)
    simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
    wait(1)
    simulator.click("Screen Shot 2015-12-07 at 7.15.05 PM.png")
    wait(1)
    simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
    wait(1)
    simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
    wait(1)
    
App.focus("Simulator")
wait(1)
simulator = Region(App.focusedWindow())
simulator.click("Screen Shot 2015-12-01 at 9.41.56 AM.png")
wait(1)
# get the first one wrong
simulator.click("Screen Shot 2015-12-01 at 1.22.55 PM.png")
wait(1)
simulator.click("Screen Shot 2015-12-02 at 10.30.33 AM.png")
wait(1)
while not simulator.exists("Screen Shot 2015-12-01 at 1.22.15 PM.png"):
    simulator.click("Screen Shot 2015-12-01 at 1.22.55 PM.png")
    wait(1)
    simulator.click("Screen Shot 2015-12-01 at 1.23.22 PM.png")
    wait(1)
simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
wait(1)
# redo the card we missed
simulator.click("Screen Shot 2015-12-01 at 9.41.56 AM.png")
wait(1)
simulator.click("Screen Shot 2015-12-01 at 1.22.55 PM.png")
wait(1)
simulator.click("Screen Shot 2015-12-01 at 1.23.22 PM.png")
wait(1)
simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
wait(1)
