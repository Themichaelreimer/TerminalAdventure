NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

tiles={
  floor = {char='.', solid=false, colour='lightGray', aiAvoid=false},
  floor1 = {char=',', solid=false, colour='lightGray', aiAvoid=false},
  floor2 = {char="'", solid=false, colour='lightGray', aiAvoid=false},
  floor3 = {char='`', solid=false, colour='lightGray', aiAvoid=false},
  wall = {char='#', solid=true, colour='lightGray', aiAvoid=true},
  water = {char='~', solid=false, colour='blue', aiAvoid=true},
  lava = {char='~', solid=false, colour='red', aiAvoid=true},
  upstairs = {char='<', solid=false, colour='lightGray', aiAvoid=false},
  downstairs = {char='>', solid=false, colour='lightGray', aiAvoid=false},
}
