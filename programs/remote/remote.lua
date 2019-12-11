local component = require("component")
local io = require("io")
local event = require("event")

local modem = component.modem

modem.setStrength(100)
modem.open(67)

while(true)
do
  local cmd = io.read()
  if cmd == "q" then break end
  modem.broadcast(66, cmd)
  local _, _, _, _, _, ret = event.pull(1, "modem_message")
  print(ret)
end