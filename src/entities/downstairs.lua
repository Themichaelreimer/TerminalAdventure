local UpStairs = require('src.entities.upstairs')
local DownStairs = UpStairs:extend("DownStairs")

DownStairs.isUp = false  -- This looks weird, reason I did it this was
-- because I originally intended to have a stairs class with isUp as
-- a parameter, except the inconsistent number of args for restoring
-- entities was a headache, so it was easier to just subtype 
-- downstairs from upstairs. Bad design, but free-hobby code.
-- what are you gonna do
--
-- See Upstairs for basically all the code

return DownStairs
