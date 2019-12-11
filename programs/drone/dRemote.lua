-- Remote control program for drones.
local version = "1.4.1"

modem = component.proxy(component.list("modem")())
drone = component.proxy(component.list("drone")())
nav = component.list("navigation")()
if nav ~= nil then
  nav = component.proxy(nav)
end
ic = component.list("inventory_controller")()
if ic ~= nil then
  ic = component.proxy(ic)
end

modem.setStrength(20)
modem.open(66)
modem.setWakeMessage("wakeup")

drone.setStatusText("dRemote\nv" .. version)

while(true)
do
    while(true) do
    name, _, _, _, _, message = computer.pullSignal()
    if name == "modem_message" then
      break
    end
  end
  
  if message ~= nil then
    func = load("ret = nil " .. message .. " return ret")
    _,ret = pcall(func)
    modem.broadcast(67, ret)
  end
end