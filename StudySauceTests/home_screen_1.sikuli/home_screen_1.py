from sikuli import *

App.focus("Simulator")
wait(1)
simulator = Region(App.focusedWindow())
simulator.find("Screen Shot 2015-12-02 at 10.41.31 AM.png")
simulator.click("Screen Shot 2015-12-01 at 9.41.56 AM.png")
wait(1)
simulator.click("Screen Shot 2015-12-01 at 1.22.55 PM.png")
wait(1)
simulator.click("Screen Shot 2015-12-01 at 1.23.22 PM.png")
wait(1)
simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
wait(1)
