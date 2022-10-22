local log = require("logging.logger").new({
    name = "Ossuaries of the Ghostfence",
    logLevel = "DEBUG"
})
local validCells = {
    ["Eastern Catacombs"] = true,
    ["Ghostgate, Hall of Ghosts"] = true,
    ["Ghostgate, Tower of Dawn"] = true,
    ["Southern Catacombs"] = true,
    ["Western Catacombs"] = true
}
local isGhosty = {
    ["ancestor_ghost"] = true,
    ["ancestor_ghost_greater"] = true,
    ["ancestor_ghost_summon"] = true
}
local calmLevel = {
    ["GG_Order_of_Ghosts_Boots"] = 1.49,
    ["GG_Order_of_Ghosts_Bracer_L"] = 0.55875,
    ["GG_Order_of_Ghosts_Bracer_R"] = 0.55875,
    ["GG_Order_of_Ghosts_Cuirass"] = 3.3525,
    ["GG_Order_of_Ghosts_greaves"] = 2.6075,
    ["GG_Order_of_Ghosts_Hood"] = 0.745,
    ["GG_Order_of_Ghosts_Pauld_L"] = 0.894,
    ["GG_Order_of_Ghosts_Pauld_R"] = 0.894
}

local function getCalmLevel()
    local level = 0
    for equipmentStack in tes3.iterate(tes3.player.object.equipment) do
        if calmLevel[equipmentStack.object.id] then
            level = level + calmLevel[equipmentStack.object.id]
        end
    end
    return level
end

local function calmGhosties()
    for _, cell in pairs(tes3.getActiveCells()) do
        -- if not validCells[cell.id] then return end
        for reference in cell:iterateReferences(tes3.objectType.creature) do
            local mobile = reference.mobile
            local calmLevel = getCalmLevel()
            if calmLevel > 0 and isGhosty[reference.baseObject.id] then
                if not reference.data.OoGInitFight then
                    reference.data.OoGInitFight = mobile.fight
                end
                if reference.data.OoGInitFight > 50 then
                    mobile.fight = math.max(50, reference.data.OoGInitFight -
                                                calmLevel)
                end
            elseif calmLevel == 0 and reference.data.OoGInitFight and
                reference.data.OoGInitFight ~= mobile.fight then
                mobile.fight = reference.data.OoGInitFight
            end
        end
    end
end
event.register("simulate", calmGhosties)

--[[
    At the start of every frame, 
    scan for any creature nearby,
    if the player is wearing Order of Ghosts armor,
    and if the creature is a ghost,
    store their initial fight value,
    if the ghost is hostile,
    set their fight value as initial fight value minus calmLevel, mininum is 50.
    if you are not wearing enough pieces of armor
    the ghost return being hostile
]]
