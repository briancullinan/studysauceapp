from sikuli import *

def goto(site):
    App.focus("Simulator")
    wait(1)
    simulator = Region(App.focusedWindow())
    simulator.type('h', KeyModifier.SHIFT + KeyModifier.CMD)
    wait(1)
    simulator.click("Screen Shot 2015-11-30 at 3.30.33 PM.png")
    wait(1)
    if simulator.exists("Screen Shot 2015-11-30 at 3.43.45 PM.png"):
        simulator.click("Screen Shot 2015-11-30 at 3.43.45 PM.png")
    wait(1)
    if simulator.exists("Screen Shot 2015-11-30 at 3.50.28 PM.png"):
        simulator.click("Screen Shot 2015-11-30 at 3.50.28 PM.png")
    wait(1)
    if simulator.exists("Screen Shot 2015-11-30 at 3.51.34 PM.png"):
        simulator.click("Screen Shot 2015-11-30 at 3.51.34 PM.png")
    else:
        simulator.click("Screen Shot 2015-11-30 at 3.31.13 PM.png")
    wait(1)
    simulator.click("Screen Shot 2015-12-01 at 2.32.36 PM.png")
    wait(1)
    simulator.type('  ' + site)
    simulator.type(Key.ENTER)
    wait(3)
