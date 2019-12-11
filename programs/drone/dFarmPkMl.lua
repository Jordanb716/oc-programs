-- Drone farming program. For pumpkins.
-- v0.9.8
-- Expects to be started with the drone one square out of the NW norner of a 9x9 farm plot.
-- Expects a charger, with a waypoint pointing at it within 12 blocks, with a crate two spaces below.

local drone = component.proxy(component.list("drone")())
local nav = component.proxy(component.list("navigation")())
local geo = component.proxy(component.list("geolyzer")())

drone.setLightColor(0xD87F33)

--Functions.
local function sleep(seconds)
  local time = os.time()/72
  while(os.difftime(os.time()/72, time) <= seconds) do end
end

-- Settle.
sleep(2)

-- Setup
drone.move(1,1,1)
--local sX,sY,sZ = nav.getPosition()
wp = nav.findWaypoints(12)
wpX = wp[1]["position"][1]
wpY = wp[1]["position"][2]
wpZ = wp[1]["position"][3]

if wpX > 0 and wpZ > 0 then
  wpOffsetX = -1
  wpOffsetZ = 0
elseif wpX > 0 and wpZ < 0 then
  wpOffsetX = 0
  wpOffsetZ = 1
elseif wpX < 0 and wpZ < 0 then
  wpOffsetX = 1
  wpOffsetZ = 0
else
  wpOffsetX = 0
  wpOffsetZ = -1
end

-- Main loop.
while(true) do

  -- Harvest loop.
  for z = 1,8 do
    for x = 1,8 do
      drone.move(0,0,1)
      sleep(2)
      if geo.analyze(0)["name"] == "minecraft:pumpkin" then
        one = true
      end
      if geo.analyze(0)["name"] == "minecraft:pumpkin" then
        two = true
      end
      if one and two then
        drone.swing(0)
      end
    end
    drone.move(1,0,-8)
    sleep(4)
  end

  -- Deliver and recharge.
  drone.move(-8,0,-8)
  drone.move(wpX+wpOffsetX, wpY-1, wpZ+wpOffsetZ)
  for i=1,drone.inventorySize() do
    drone.select(i)
    drone.drop(0)
  end
  drone.move(0,1,0)
  drone.select(1)
  sleep(60)
end