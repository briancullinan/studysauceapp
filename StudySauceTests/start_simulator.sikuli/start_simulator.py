from sikuli import *

def run():
    switchApp("Xcode")
    wait(1)
    xcode = Region(App.focusedWindow())
    xcode.click("Screen Shot 2015-11-28 at 9.21.20 PM.png")
    wait(1)
    if xcode.exists("Screen Shot 2015-11-29 at 2.17.59 PM.png"):
        xcode.click("Screen Shot 2015-11-29 at 2.17.59 PM.png")
    wait(10)
