from sikuli import *
import start_simulator
reload(start_simulator)
import reset_database
reload(reset_database)
import check_mailinator
reload(check_mailinator)

start_simulator.run()
App.focus("Simulator")
wait(1)
simulator = Region(App.focusedWindow())
reset_database.run()
check_mailinator.run()
simulator.click("Screen Shot 2015-11-30 at 4.15.22 PM.png")
simulator.click("Screen Shot 2015-12-01 at 12.04.19 PM.png")
wait(3)
simulator.click("Screen Shot 2015-12-01 at 12.24.10 PM.png")
simulator.click("Screen Shot 2015-12-01 at 12.24.49 PM.png")
wait(1)
simulator.click("Screen Shot 2015-12-01 at 12.25.19 PM.png")
wait(3)