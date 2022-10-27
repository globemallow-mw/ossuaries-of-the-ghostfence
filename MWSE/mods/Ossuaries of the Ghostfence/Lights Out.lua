local log = require("logging.logger").new({
    name = "Ossuaries of the Ghostfence",
    logLevel = "DEBUG"
})

local lightsBackOn
local done

local function lightsOn(e)
    if lightsBackOn then return end
    if e.cell.id == "Western Catacombs" and done then
        -- renable lights
        tes3.runLegacyScript({command = "GG_light_sconce10_west1->Enable"})
        tes3.runLegacyScript({command = "GG_light_sconce10_west2->Enable"})
    end
end
event.register("cellChanged", lightsOn)

local function lightsOut()
    if tes3.player.cell.id ~= "Western Catacombs" then return end
    if not done then
        if tes3.getReference("GG_sc_invisibility_west").disabled then
            -- Fade for 10 seconds
            tes3.fadeOut({duration = 0.01})
            tes3.fadeIn({duration = 10})
            -- force unequip equipped light
            local equippedLight = tes3.getEquippedItem({
                actor = tes3.player,
                objectType = tes3.objectType.light
            })
            if equippedLight then
                log:debug("%s unequipped", equippedLight.object.id)
                tes3.player.mobile:unequip({type = tes3.objectType.light})
            end
            -- disable lights
            tes3.runLegacyScript({command = "GG_light_sconce10_west1->Disable"})
            tes3.runLegacyScript({command = "GG_light_sconce10_west2->Disable"})
            done = true
        end
    end
end
event.register("simulate", lightsOut)
