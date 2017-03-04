from sikuli import *


switchApp("Simulator")
wait(1)
simulator = Region(App.focusedWindow())
# TODO: go back to home screen if we can
simulator.click("Screen Shot 2015-12-01 at 9.32.35 AM.png")
wait(1)
simulator.click("Screen Shot 2015-12-01 at 10.50.55 AM.png")
wait(1)
simulator.type("Screen Shot 2015-12-01 at 10.51.27 AM.png", 'brian@studysauce.com')
simulator.click("Screen Shot 2015-12-01 at 10.51.54 AM.png")

import check_mailinator

simulator.click("Screen Shot 2015-12-01 at 11.23.57 AM.png")
simulator.click("Screen Shot 2015-12-01 at 11.24.30 AM.png")
# TODO: open with app
wait(1)
simulator.type("Screen Shot 2015-12-01 at 11.25.11 AM.png", 'password')
simulator.click("Screen Shot 2015-12-01 at 10.51.54 AM.png")