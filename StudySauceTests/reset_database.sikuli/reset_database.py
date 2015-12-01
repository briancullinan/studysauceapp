from sikuli import *

switchApp("Simulator")
wait(1)
simulator = Region(App.focusedWindow())
while simulator.exists("Screen Shot 2015-11-29 at 1.57.31 PM.png"):
    simulator.click("Screen Shot 2015-11-29 at 1.57.31 PM.png")
simulator.click("Screen Shot 2015-11-28 at 9.39.12 PM.png")
for x in range(0, 10):
    simulator.click("Screen Shot 2015-11-29 at 2.18.57 PM.png")

