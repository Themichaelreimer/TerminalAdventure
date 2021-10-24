NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

imageTiles = {
  wall=love.graphics.newImage("assets/tiles/catacombs_0.png"),
  floor=love.graphics.newImage("assets/tiles/cobble_blood_1_new.png"),
  water=love.graphics.newImage("assets/tiles/deep_water.png"),
  lava=love.graphics.newImage("assets/tiles/lava_0.png"),
  up=love.graphics.newImage("assets/tiles/stone_stairs_up.png"),
  down=love.graphics.newImage("assets/tiles/stone_stairs_down.png"),
}

tiles={
  floor = {char='.', img=imageTiles.floor, solid=false, colour='lightGray', aiAvoid=false},
  floor1 = {char=',', img=imageTiles.floor, solid=false, colour='lightGray', aiAvoid=false},
  floor2 = {char="'", img=imageTiles.floor, solid=false, colour='lightGray', aiAvoid=false},
  floor3 = {char='`', img=imageTiles.floor, solid=false, colour='lightGray', aiAvoid=false},
  wall = {char='#', img=imageTiles.wall, solid=true, colour='lightGray', aiAvoid=true},
  water = {char='~', img=imageTiles.water, solid=false, colour='blue', aiAvoid=true},
  lava = {char='~', img=imageTiles.lava, solid=false, colour='red', aiAvoid=true},
  upstairs = {char='<', solid=false, img=imageTiles.up, colour='lightGray', aiAvoid=false},
  downstairs = {char='>', solid=false, img=imageTiles.down, colour='lightGray', aiAvoid=false},
}
