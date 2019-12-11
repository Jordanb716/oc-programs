component = require("component")
holo = component.hologram
geo = component.geolyzer

local overXMul = 2
local overZMul = 1

local overX = overXMul * 10
local overZ = overZMul * 10

local sWidth = 2
local sDepth = 4
local sHeight = 8

local offsetX = -1*(sWidth*overX/2)
local offsetY = -1
local offsetZ = -1*(sDepth*overZ/2)

local densityCutoff = 0.1

holo.clear()

local i = 1

for ox = 0, overX-1 do
  for oz = 0, overZ-1 do
    local scan = geo.scan(offsetX+(ox*sWidth), offsetZ+(oz*sDepth), offsetY, sWidth, sDepth, sHeight)
    for y = 1, sHeight do
      for z = 1, sDepth do
        for x = 1, sWidth do
          if y <= -1 * offsetY then
            color = 1
          else
            color = 2
          end

          if scan[i] > densityCutoff then
            holo.set(x+(ox*sWidth),y,z+(oz*sDepth),color)
          end
          i=i+1
        end
      end
    end
    i=1
  end
end