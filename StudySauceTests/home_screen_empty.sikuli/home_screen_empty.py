from sikuli import *

App.focus("Simulator")
wait(1)
simulator = Region(App.focusedWindow())
simulator.find("Screen Shot 2015-12-02 at 10.45.09 AM.png")