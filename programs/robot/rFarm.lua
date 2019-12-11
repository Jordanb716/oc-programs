-- rFarm
local version = "1.3.2"
-- Farming Program for robots.
-- Works with potatoes, carrots, wheat, beetroots, pumpkins, melons, nether warts, and hemp.
-- Expects a 2x2 grid of 9x9 fields, with 3 spaces between fields.
-- Expects a ceiling charger in the middle of the grid 4 spaces off the ground.
-- Place robot under charger and start program.

component = require("component")
sides = require("sides")
computer = require("computer")
robot = require("robot")
fs = require("filesystem")
geo = component.geolyzer

-- Startup
os.execute("clear")
print("Starting rFarm v" .. version)

-- Functions
function findName()
  local scan = geo.analyze(sides.forward)
  if scan.name == "minecraft:potatoes" then return "potato"
  elseif scan.name == "minecraft:carrots" then return "carrot"
  elseif scan.name == "minecraft:wheat" then return "wheat"
  elseif scan.name == "minecraft:beetroots" then return "beetroot"
  elseif scan.name == "minecraft:melon_block" then return "melon"
  elseif scan.name == "minecraft:pumpkin" then return "pumpkin"
  elseif scan.name == "minecraft:nether_wart" then return "nether wart"
  elseif scan.name == "immersiveengineering:hemp" then return "hemp"
  else return "unknown"
  end
end

function waitForCharge(charge)
  while(computer.energy()/computer.maxEnergy() <= charge) do
    os.sleep(1)
  end
end

function forward(steps)
  steps = steps or 1
  for i=1,steps do
    while robot.forward() ~= true do end
  end
end

function tryPlant()
  if robot.placeDown() ~= true then
    for i=1,robot.inventorySize() do
      robot.select(i)
      if robot.placeDown() == true then
        break
      end
    end
    robot.select(1)
  end
end

function strike(crop, scan)
  if crop == "potato" then
    if scan.properties.age == 7 then
      robot.swingDown()
      robot.placeDown()
    elseif scan.name == "minecraft:air" then
      tryPlant()
    end
  elseif crop == "carrot" then
    if scan.properties.age == 7 then
      robot.swingDown()
      robot.placeDown()
    elseif scan.name == "minecraft:air" then
      tryPlant()
    end
  elseif crop == "wheat" then
    if scan.properties.age == 7 then
      robot.swingDown()
      tryPlant()
    elseif scan.name == "minecraft:air" then
      tryPlant()
    end
  elseif crop == "beetroot" then
    if scan.properties.age == 3 then
      robot.swingDown()
      tryPlant()
    elseif scan.name == "minecraft:air" then
      tryPlant()
    end
  elseif crop == "pumpkin" or crop == "melon" then
    if scan.name == "minecraft:pumpkin" or scan.name == "minecraft:melon_block" then
      robot.swingDown()
    end
  elseif crop == "nether wart" then
    if scan.properties.age == 3 then
      robot.swingDown()
      robot.placeDown()
    elseif scan.name == "minecraft:air" then
      tryPlant()
    end
  elseif crop == "hemp" then
    if scan.name ~= "minecraft:air" then
      robot.swingDown()
    end
  end
end

function harvest(crop)
  -- If unknown, skip.
  if crop == "unknown" then
    robot.turnLeft()
    return
  end

  -- Set color
  if crop == "potato" then
    robot.setLightColor(0xFFFDD0)
  elseif crop == "carrot" then
    robot.setLightColor(0xFF7518)
  elseif crop == "wheat" then
    robot.setLightColor(0xF5DEB3)
  elseif crop == "beetroot" then
    robot.setLightColor(0xC71558)
  elseif crop == "pumpkin" then
    robot.setLightColor(0xD87F33)
  elseif crop == "melon" then
    robot.setLightColor(0x7FCC19)
  elseif crop == "nether wart" then
    robot.setLightColor(0x993333)
  elseif crop == "hemp" then
    robot.setLightColor(0x013220)
  end

  --Initial Position
  forward(2)
  robot.turnRight()
  forward(2)
  
  --Harvest crop
  if crop ~= "hemp" then
    robot.down()
  end
  for i = 1,4 do
    for x = 1,9 do
      local scan = geo.analyze(sides.down)
      strike(crop, scan)
      if x<9 then forward() end
    end
    robot.turnLeft()
    forward()
    robot.turnLeft()
    for x = 1,9 do
      local scan = geo.analyze(sides.down)
      strike(crop, scan)
      if x<9 then forward() end
    end
    robot.turnRight()
    forward()
    robot.turnRight()
  end
  for i=1,9 do
    local scan = geo.analyze(sides.down)
    strike(crop, scan)
    if i<9 then forward() end
  end

  if crop ~= "hemp" then
    robot.up()
  end
  robot.turnRight()
  forward(10)
  robot.turnRight()
  forward(9)
  for i=1,2 do
    while robot.down() == false do end
  end

  --Dropoff  
  for i=1,robot.inventorySize() do
    robot.select(i)
    if robot.dropDown() == false then
      robot.drop()
    end
  end
  robot.select(1)
  for i=1,2 do
    while robot.up() == false do end
  end
  forward()
end

-- Scan quadrants
print("Scanning Crops...")
forward(2)
robot.turnRight()
for i=1,2 do
  while robot.down() == false do end
end
forward()
local quad1 = findName()
robot.turnAround()
forward(2)
local quad4 = findName()
robot.turnLeft()
forward(4)
robot.turnRight()
local quad3 = findName()
robot.turnAround()
forward(2)
local quad2 = findName()
robot.turnAround()
forward()
robot.turnRight()
forward(2)
for i=1,2 do
  while robot.up() == false do end
end
print("Quadrant 1: " .. quad1)
print("Quadrant 2: " .. quad2)
print("Quadrant 3: " .. quad3)
print("Quadrant 4: " .. quad4)

-- Main Loop
print("Starting harvesting loop...")
while(true) do
  waitForCharge(0.9)
  harvest(quad1)
  if fs.exists("/home/rFarm") ~= true then break end
  waitForCharge(0.9)
  harvest(quad4)
  if fs.exists("/home/rFarm") ~= true then break end
  waitForCharge(0.9)
  harvest(quad3)
  if fs.exists("/home/rFarm") ~= true then break end
  waitForCharge(0.9)
  harvest(quad2)
  if fs.exists("/home/rFarm") ~= true then break end
end
