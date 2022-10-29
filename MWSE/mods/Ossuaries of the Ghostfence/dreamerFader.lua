local dreamerFader = nil
local function createDreamerFader()
    dreamerFader = tes3fader.new()
    dreamerFader:setTexture("vfx_alpha_bolt01.tga")
    dreamerFader:setColor({color = {0.77, 0.25, 0.22}})
    event.register("enterFrame", function() dreamerFader:update() end)
end
event.register("fadersCreated", createDreamerFader)
return dreamerFader
