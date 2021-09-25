local PriorityQueue = class("PriorityQueue")

-- PriorityQueue is implemented as a mildly extended doubly linked list
function PriorityQueue:init()
    self.start = nil
    self.size = 0
end

function PriorityQueue:enqueue(priority, object)
  local newNode = {priority=priority, object=object, next=nil, prev=nil}
  if self.size == 0 then
    self.start = newNode
  else
    local prev = nil
    local cur = self.start

    -- Node in traversal is more important than incoming node
    while cur and cur.priority < priority do
      prev = cur
      cur = cur.next
    end

    -- Idea: Traversal is set up so incoming node goes between prev and cur
    if cur and not prev then
      -- Case 1: Front of list (prev is null, cur isn't)
      newNode.next = cur
      cur.prev = newNode
      self.start = newNode
    elseif prev and not cur then
      -- Case 2: End of list (prev isn't null, but cur is)
      prev.next = newNode
      newNode.prev = prev
    else
      -- Default case: Middle of list
      prev.next = newNode
      newNode.prev = prev
      newNode.next = cur
      cur.prev = newNode
    end


  end
  self.size = self.size + 1
end

function PriorityQueue:dequeue()
  if self.size == 0 then return nil end

  local result = self.start
  self.start = self.start.next
  self.size = self.size-1
  return result

end

function PriorityQueue:isEmpty()
  return self.size == 0
end

return PriorityQueue
