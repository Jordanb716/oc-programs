-- pReg
-- Port Registrar
-- Stores port register, accepts requests on port 1
local version = 2.0

local component = require("component")
local term = require("term")
local event = require("event")
local io = require("io")

local modem = component.modem

-- Functions

function readRegister()
  local register = {}
  file = io.open("register")
  if file == nil then
    print("No register found.")
    return register
  else
    print("Loading register file...")
  end
  local _,cursor = term.getCursor()
  for i=1,(65535-9999) do
    local line = file:read()
    if line == "" then
      register[i+9999] = nil
    else
      register[i+9999] = line
    end
    if i % math.floor((65535-9999)*0.01) == 0 then
      local percent = i/(65535-9999)*100
      term.setCursor(1, cursor)
      print(percent+0.5-(percent+0.5)%1 .. "%...")
    end
  end
  print("Done!")
  file:close()
  return register
end

function writeRegister(register)
  print("Writing register.")
  file = io.open("register", "w")
  for i=10000,65535 do
    if register[i] == nil then
      file:write("")
    else
      file:write(register[i])
    end
    file:write("\n")
  end
  file:close()
  print("Done!")
end

function request(register, sender, name)
  if type(name) == "number" then
    modem.send(sender, 1, "pReg", "NAK", "Name is not a string.")
  end
  repeat
    port = math.random(10000,65535)
  until(register[port] == nil)
  
  local dup = false
  for i=1,65535 do
    if register[i] == name then
      dup = true
      break
    end
  end
  if dup == false then
    register[port] = name
    modem.send(sender, 1, "pReg", port)
    print("Registered port " .. port .. " as " .. name)
    writeRegister(register)
  else
    modem.send(sender, 1, "pReg", "NAK", "Name already registered")
  end
  return register

end

function free(register, sender, input)
  local port
  if type(input) == 'number' then
    port = input
    register[port] = nil
  else
    for i=10000,65535 do
      if register[i] == input then
        port = i
        register[port] = nil
        break
      end
    end
    if port == nil then
      print("Unable to free " .. input)
      modem.send(sender, 1, "pReg", "NAK", "Registration not found")
      return register
    end
  end
  modem.send(sender, 1, "pReg", "ACK")
  print("Freed port " .. port)
  writeRegister(register)
  return register
end

function whois(register, sender, input)
  local response
  if type(input) == 'number' then
    response = register[input]
  else
    for i=1,65535 do
      if register[i] == input then
        response = i
        break
      end
    end
  end
  if response == nil then
    modem.send(sender, 1, "pReg", "No entry found")
  else
    modem.send(sender, 1, "pReg", response)
  end
end

function handleSignal(register, eName, receiver, sender, port, distance, message1, message2)
  if message1 == "request" then
    register = request(register, sender, message2)
  elseif message1 == "free" then
    register = free(register, sender, message2)
  elseif message1 == "whois" then
    whois(register, sender, message2)
  elseif message1 == "help" then
    modem.send(sender, 1, "pReg", "Send 'request' to request a port, 'free' and a port to free a port, 'whois' and a port or purpose to check the register. See readme for details.")
  else
    modem.send(sender, 1, "pReg",  "pReg v" .. version .. " send 'help' for commands.")
  end
  return register
end

-- Main
print("pReg v" .. version)
print("Setting up...")
modem.setStrength(800)
modem.open(1)

local register = readRegister()
register[1] = "pReg"
register[2] = "Startup Coordination"
for i=3,9999 do
  register[i] = "Unmanaged"
end

print("Ready.")

-- Main loop
while true do
  local a,b,c,d,e,f,g = event.pull()
  if a == "modem_message" then
    register = handleSignal(register, a,b,c,d,e,f,g)
  elseif a == "interrupted" then
    break
  end
end