-- Sets up the Tiny Entity-Component-System and registers the systems

updateSystem = require("src.systems.updateSystem")
drawSystem = require("src.systems.drawSystem")
lifetimeSystem = require("src.systems.lifetimeSystem")
lightingSystem = require("src.systems.lightingSystem")
--collisionDamageSystem = require('src.systems.collisionDamageSystem')

-- ECS world, as opposed to the physics world
ecsWorld = tiny.world(lifetimeSystem, updateSystem, drawSystem, lightingSystem)

-- Table of all ECS entities currently loaded
-- This table is cleaned by updateSystem every frame
gameObjects = {}
