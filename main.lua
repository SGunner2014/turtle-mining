-- A mining program for CC:Tweaked
-- This uses the GPS API!
-- The aim is to dig straight down :o
-- then, mine at y=11 for diamonds, gold, redstone

-- Define some constants
local DIR_DOWN = 0
local DIR_UP = 1
local DIR_FORWARDS = 4
local DIR_BACK = 5
local TURN_LEFT = 6
local TURN_RIGHT = 7
local interested_blocks = {
    "minecraft:diamond_ore",
    "minecraft:redstone_ore",
    "minecraft:gold_ore"
}

-- Emulate a stack, using a list
local stack = {}
function stack:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Adds a new item to the top of the stack
function stack:push(item)
    if self.items == nil then
        self.items = {}
    end

    self.items[#self.items + 1] = item
end

-- Takes an item off the top of the stack and returns it
function stack:pop()
    if self.items == nil then
        return nil
    elseif #self.items == 0 then
        return nil
    end

    local item = self.items[#self.items]
    self.items[#self.items] = nil
    return item
end

-- Returns the item on the top of the stack, but doesn't remove it
function stack:peek()
    if self.items == nil then return nil end
    return self.items[#self.items]
end

-- Returns the number of items remaining in the stack.
function stack:count()
    if self.items == nil then return 0 end
    return #self.items
end

-- returns the opposite to the direction supplied.
local function getOppositeDir(dir)
    if dir == DIR_DOWN then
        return DIR_UP
    elseif dir == DIR_UP then
        return DIR_DOWN
    elseif dir == DIR_FORWARDS then
        return DIR_BACK
    elseif dir == DIR_BACK then
        return DIR_FORWARDS
    elseif dir == TURN_LEFT then
        return TURN_RIGHT
    elseif dir == TURN_RIGHT then
        return TURN_LEFT
    end
end

-- Moves in a specified action and adds it to the stack.
local function move(stack, dir)
    if dir == DIR_DOWN then
        turtle.down()
    elseif dir == DIR_UP then
        turtle.up()
    elseif dir == DIR_FORWARDS then
        turtle.forward()
    elseif dir == DIR_BACK then
        turtle.back()
    elseif dir == TURN_LEFT then
        turtle.turnLeft()
    elseif dir == TURN_RIGHT then
        turtle.turnRight()
    end

    -- If we're going back on ourselves, don't worry about recording it
    -- in fact, remove the last action
    if stack:peek() == getOppositeDir(dir) then
        stack:pop()
    else
        stack:push(dir)
    end

    return stack
end

-- Checks if a list contains a value
local function listContains(list, val)
    for i = 1, #list do
        if list[i] == val then
            return true
        end
    end

    return false
end

-- Reverses a set number of steps
local function reverse(stack, count)
    local opp_dir

    for i = 1, count do
        opp_dir = getOppositeDir(stack:peek())
        stack = move(stack, opp_dir)
    end

    return stack
end

local function branch(stack, dir)
    count = 0

    if dir == 1 then -- left
        stack = move(stack, TURN_LEFT)
        count = count + 1
    elseif dir == -1 then
        stack = move(stack, TURN_RIGHT)
        count = count + 1
    end

    -- Mine the block, ditch it if it's not (diamond, redstone, gold)
    for i = 1, 16 do
        -- account for gravel, sand
        while turtle.inspect() and turtle.getFuelLevel() > (stack:count() + 2) do
            turtle.dig()
        end

        if turtle.getFuelLevel() <= (stack:count() + 2) then
            return stack, false
        end

        move(stack, DIR_FORWARDS)

        count = count + 1
    end

    return reverse(stack, count), true
end

local function main()
    local x, y, z = gps.locate()
    local path_taken = stack:new()

    -- Move down to the mining level we want
    for i = 1, (y - 11) do
        -- Only dig the block beneath us if we really need to.
        local block = turtle.inspectDown()
        if block then
            turtle.digDown()
        end
        path_taken = move(path_taken, DIR_DOWN)
    end

    -- Now we can do some strip-mining
    -- We're going to dig a straight path with branches off of the side with length 16.
    while turtle.getFuelLevel() > (path_taken:count() + 2) do -- 2 for some wiggle room
        path_taken, success = branch(path_taken, 1)
        if not success then -- we need to return to base, presumably for fuel.
            path_taken = reverse(path_taken, path_taken:count())
            break
        end
        path_taken, success = branch(path_taken, -1)
        if not success then -- we need to return to base, presumably for fuel.
            path_taken = reverse(path_taken, path_taken:count())
            break
        end

        -- only carry on if we have enough fuel
        if turtle.getFuelLevel() <= (path_taken:count() + 2) then
            path_taken = reverse(path_taken, path_taken:count())
            break
        end

        -- Now we can move forwards 5 steps and repeat it all again
        for i = 1, 5 do
            while turtle.inspect() do
                turtle.dig()
            end
            path_taken = move(path_taken, DIR_FORWARDS)
        end
    end
end

main()