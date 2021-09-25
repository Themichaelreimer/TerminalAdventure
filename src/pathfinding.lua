PriorityQueue = require('src.datastructures.PriorityQueue')

---------------------------------------------------------------
local Node = class("SearchNode")
function Node:init(x, y)
  self.x = x
  self.y = y
end

function Node:equals(other)
  return self.x == other.x and self.y == other.y
end
---------------------------------------------------------------


function findPath(startX, startY, endX, endY)
  local q = PriorityQueue()
  local start = Node(startX,startY)

end

local function g(node)
  -- Cost of moving from start to node

end

local function h(node, endNode)
  -- Heuristic function via manhatten distance
  return math.abs(node.x-endNode.x) + math.abs(node.y-endNode.y)
end
