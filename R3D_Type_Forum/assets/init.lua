-- plugins
require "scenemanager"
require "easing"
r3d = require "reactphysics3d"
-- globals
myappleft, myapptop, myappright, myappbot = application:getLogicalBounds()
myappwidth, myappheight = myappright - myappleft, myappbot - myapptop
--print("app left", myappleft, "app top", myapptop, "app right", myappright, "app bot", myappbot)
--print("app width", myappwidth, "app height", myappheight)

-- global prefs
g_current_level = 1

-- LIQUIDFUN: here we store all possible contact TYPE -- NO LIMIT :-)
G_GROUND = 2^0
G_WALL = 2^1
G_PLAYER = 2^2
G_PLAYER_BULLET = 2^3
G_ENEMY01 = 2^4
G_ENEMY_BULLET = 2^5
G_EXIT = 2^6
G_DEAD = 2^7
G_COIN = 2^8
-- LIQUIDFUN: here we define some category BITS (that is those objects can collide) -- 2^15 = MAX
G_BITSOLID = 2^0
G_BITPLAYER = 2^1
G_BITPLAYERBULLET = 2^2
G_BITENEMY = 2^3
G_BITENEMYBULLET = 2^4
G_BITSENSOR = 2^5
-- and their appropriate masks (that is what can collide with what)
solidcollisions = G_BITSOLID + G_BITPLAYER + G_BITPLAYERBULLET + G_BITENEMY + G_BITENEMYBULLET
playercollisions = G_BITSOLID + G_BITENEMY + G_BITENEMYBULLET + G_BITSENSOR
playerbulletcollisions = G_BITSOLID + G_BITENEMY + G_BITENEMYBULLET
nmecollisions = G_BITSOLID + G_BITPLAYER + G_BITPLAYERBULLET + G_BITENEMY
nmebulletcollisions = G_BITSOLID + G_BITPLAYER + G_BITPLAYERBULLET
