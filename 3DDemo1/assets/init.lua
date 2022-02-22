-- plugins
require "scenemanager"
require "easing"
r3d=require "reactphysics3d"
-- globals
myappleft, myapptop, myappright, myappbot = application:getLogicalBounds()
myappwidth, myappheight = myappright - myappleft, myappbot - myapptop
--print("app left", myappleft, "app top", myapptop, "app right", myappright, "app bot", myappbot)
--print("app width", myappwidth, "app height", myappheight)
-- global prefs
g_current_level = 1
