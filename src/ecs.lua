-- Sets up the Tiny Entity-Component-System and registers the systems

updateSystem = require("src.systems.updateSystem")
drawSystem = require("src.systems.drawSystem")
lifetimeSystem = require("src.systems.lifetimeSystem")
lightingSystem = require("src.systems.lightingSystem")
--collisionDamageSystem = require('src.systems.collisionDamageSystem')
asciiDrawSystem = require("src.systems.asciiDrawSystem")
aiSystem = require("src.systems.aiSystem")
waterSystem = require("src.systems.waterSystem")
lavaSystem = require("src.systems.lavaSystem")
FireSystem = require("src.systems.firesystem")
RecoverySystem = require("src.systems.RecoverySystem")

-- ECS world, as opposed to the physics world
ecsWorld = tiny.world(lifetimeSystem, updateSystem, RecoverySystem, drawSystem, lightingSystem, asciiDrawSystem, aiSystem, waterSystem, lavaSystem, FireSystem)

-- Table of all ECS entities currently loaded
-- This table is cleaned by updateSystem every frame
gameObjects = {}
