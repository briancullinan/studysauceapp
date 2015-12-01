from sikuli import *

App.focus("Simulator")
wait(1)
simulator = Region(App.focusedWindow())
simulator.click("Screen Shot 2015-12-01 at 1.18.19 PM.png")
simulator.click("Screen Shot 2015-12-01 at 1.19.29 PM.png")
simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
simulator.click("Screen Shot 2015-12-01 at 9.41.56 AM.png")
while not simulator.exists("Screen Shot 2015-12-01 at 1.22.15 PM.png"):
    simulator.click("Screen Shot 2015-12-01 at 1.22.55 PM.png")
    simulator.click("Screen Shot 2015-12-01 at 1.23.22 PM.png")
simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")