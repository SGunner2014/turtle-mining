-- A mining program for CC:Tweaked
-- This uses the GPS API!
-- The aim is to dig straight down :o
-- then, mine at y=11 for diamonds, gold, redstone
--
-- This was made by SGunner2017
-- This uses the aeslua API by SquidDev
--
-- failure conditions:
-- 1) inventory full
-- 2) run out of fuel

-- Define some constants
local DIR_DOWN = 0
local DIR_UP = 1
local DIR_FORWARDS = 4
local DIR_BACK = 5
local TURN_LEFT = 6
local TURN_RIGHT = 7
local interested_blocks = {
    "minecraft:diamond",
    "minecraft:redstone",
    "minecraft:gold_ore",
    "minecraft:coal"
}
local DEBUG_INFO = true
local modem_side = "left"
local encrypt_key = "samiscool"

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
g_stack = stack

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
    if val == nil then return false end

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

-- Returns true if the inventory is sufficiently full to return to base
local function invSpaceFull()
    -- Scan through slots, return true if all slots have items & any are @ 64
    for i = 1, 16 do
        if not turtle.getItemDetail(i) then
            return false
        end
    end

    -- Check if we have any @ 64
    for i = 1, 16 do
        if turtle.getItemCount(i) == 64 then
            return true
        end
    end

    return false
end

-- Returns 0 if can carry on
-- Returns 1 if no inv space left
-- Returns 2 if no fuel
local function shouldEnd(stack)
    print("inv space: " .. tostring(invSpaceFull()))

    if turtle.getFuelLevel() <= (stack:count() + 2) then
        return 2
    elseif invSpaceFull() then
        return 1
    else
        return false
    end
end

-- Mines the ore to the direction specified
local function mineOre(direction, stack, vein_path)
    local count = 0

    if direction == TURN_LEFT or direction == TURN_RIGHT then -- move into position if it's either of these.
        vein_path = move(vein_path, direction)
        count = count + 1
    elseif direction == DIR_DOWN then -- if it's down or up, we can inspect, mine and move!
        local blockInfo = {turtle.inspectDown()}
        if listContains(interested_blocks, blockInfo[2].name) then
            while turtle.inspectDown() do -- sand, gravel
                turtle.digDown()
            end
            vein_path = move(vein_path, DIR_DOWN)
            vein_path = mineOreVein(stack, vein_path)
        end
    elseif direction == DIR_UP then
        local blockInfo = {turtle.inspectUp()}
        if listContains(interested_blocks, blockInfo[2].name) then
            while turtle.inspectUp() do -- sand, gravel
                turtle.digUp()
            end
            vein_path = move(vein_path, DIR_UP) -- move into position and repeat all over again
            vein_path = mineOreVein(stack, vein_path)
            count = count + 1
        end
    end

    if listContains({DIR_FORWARD, TURN_LEFT, TURN_RIGHT}, direction) then
        -- We should be facing in the right direction to check forward.
        local blockInfo = {turtle.inspect()}
        if listContains(interested_blocks, blockInfo[2].name) then
            while turtle.inspect() do -- sand, gravel
                turtle.dig()
            end
            vein_path = move(vein_path, DIR_UP)
            vein_path = mineOreVein(stack, vein_path)
            count = count + 1
        end
    end

    -- Reverse back to where we started
    vein_path = reverse(vein_path, count)
    return vein_path
end

-- Attempts to mine a connected vein of ores in a recursive fashion.
local function mineOreVein(stack, vein_path)
    -- stack is the path taken up until when we encountered the ore patch.
    -- vein_path is the path that we have taken in the ore vein so far.
    local directions = {
        DIR_FORWARD,
        TURN_LEFT,
        TURN_RIGHT,
        DIR_DOWN,
        DIR_UP
    }

    -- Mine in each direction and terminate if we should end
    for i = 1, #directions do
        vein_path, terminate = mineOre(directions[i], stack, vein_path)
    end

    return vein_path
end

-- Branches to one side or the other
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
        -- Check if there's a vein we need to mine
        local blockInfo = {turtle.inspect()}
        if listContains(interested_blocks, blockInfo[2].name) then
            mineOreVein(stack, g_stack:new())
        end

        -- account for gravel, sand
        while turtle.inspect() and turtle.getFuelLevel() > (stack:count() + 2) do
            turtle.dig()
        end

        if shouldEnd(stack) then
            return stack, false
        end

        move(stack, DIR_FORWARDS)

        count = count + 1
    end

    return reverse(stack, count), true
end

-- Broadcasts a message to listening computers.
-- Injects some useful data to the listener
local function broadcastEvent(modem, event)
    event["id"] = os.getComputerID()
    event["label"] = os.getComputerLabel()
    event["fuel"] = turtle.getFuelLevel()
    local text = textutils.serializeJSON(event)
    aes.encrypt(encrypt_key, text)
    modem.transmit(1810, 1810, text)
end

-- Ditches all items not in interested_blocks
local function ditchUselessItems()
    local data

    -- Scan through the slots and drop all useless items
    for i = 1, 16 do
        data = turtle.getItemDetail(i)
        if data ~= nil then
            if not listContains(interested_blocks, data.name) then -- ditch items
                turtle.select(i)
                turtle.drop()
            end
        end
    end
end

local function main()
    local x, y, z = gps.locate()
    local path_taken = stack:new()
    local modem = peripheral.wrap(modem_side)
    os.loadAPI("aes.lua")

    broadcastEvent(modem, {
        status = "INITIALISING",
        message = "This turtle is initialising and reaching the initial y-value needed."
    })
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
    while not shouldEnd(stack) do -- 2 for some wiggle room
        
        path_taken, success = branch(path_taken, 1)
        ditchUselessItems()
        if not success then -- we need to return to base, presumably for fuel.
            broadcastEvent(modem, {
                status = "REVERSING",
                message = "The turtle has run out of fuel and is returning to base..."
            })
            path_taken = reverse(path_taken, path_taken:count())
            broadcastEvent(modem, {
                status = "END",
                message = "The turtle has run out of fuel and has returned."
            })
            break
        end
        path_taken, success = branch(path_taken, -1)
        ditchUselessItems()
        if not success then -- we need to return to base, presumably for fuel.
            broadcastEvent(modem, {
                status = "REVERSING",
                message = "The turtle has run out of fuel and is returning to base..."
            })
            path_taken = reverse(path_taken, path_taken:count())
            broadcastEvent(modem, {
                status = "END",
                message = "The turtle has run out of fuel and has returned."
            })
            break
        end

        -- only carry on if we have enough fuel
        if shouldEnd(stack) then
            broadcastEvent(modem, {
                status = "REVERSING",
                message = "The turtle has run out of fuel and is returning to base..."
            })
            path_taken = reverse(path_taken, path_taken:count())
            broadcastEvent(modem, {
                status = "END",
                message = "The turtle has run out of fuel and has returned."
            })
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

-- run the program
main()