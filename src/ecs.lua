-- Sets up the Tiny Entity-Component-System and registers the systems

updateSystem = require("src.systems.updateSystem")
drawSystem = require("src.systems.drawSystem")
lifetimeSystem = require("src.systems.lifetimeSystem")

ecsWorld = tiny.world(lifetimeSystem, updateSystem, drawSystem)
gameObjects = {}
