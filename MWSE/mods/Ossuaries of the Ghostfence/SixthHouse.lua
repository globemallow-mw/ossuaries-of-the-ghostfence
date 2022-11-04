local log = require("logging.logger").new({
    name = "OotG Sixth House Quest",
    logLevel = "INFO"
})
local sixthHouseQuestID = "GG_6thHouse"
local bouncerForceGreetInfoID = "2020366741859230377"
local dagothID = "GG_6_ash_ghoul_nasro"
local troopers = {
    "GG_alynu_menas", "GG_dartis_iba", "GG_dralane_murith", "GG_tennus_dolovas"
}
local skullID = "GG_Bleeding_Skull_Identified"

local function fleshsHeartTooltip(e)
    if e.object.id == skullID then
        local block = e.tooltip:createBlock{}
        block.minWidth = 1
        block.maxWidth = 440
        block.autoWidth = true
        block.autoHeight = true
        block.paddingAllSides = 4
        local label = (block:createLabel{
            id = tes3ui.registerID("GG_Bleeding_Skull_desc"),
            text = "Take One Death Blow for the Carrier"
        })
        label.wrapText = true
    end
end
event.register("uiObjectTooltip", fleshsHeartTooltip)

--- @param e damageEventData
local function bleedingSkullEffect(e)
    if tes3.getItemCount({reference = tes3.player, item = skullID}) > 0 then
        log:debug("player has a bleeding skull in their inventory")
        if e.reference == tes3.player then
            if e.attacker then
                log:debug("player is taking damage from %s!", e.attacker)
            else
                log:debug("player is taking damage!")
            end
            if e.damage >= tes3.player.mobile.health.current then
                log:debug(
                    "the damage the player will take will kill the player!")
                tes3.removeItem({
                    reference = tes3.player,
                    item = skullID,
                    playSound = false
                })
                tes3.playSound({sound = "restoration hit"})
                tes3.messageBox({
                    message = "The Bleeding Skull took the damage for you."
                })
                return false
            end
        end
    end
end

local function trooperForceGreetPlayer()
    if tes3.player.cell.id ~= "Western Catacombs" then return end
    local dagothRef = tes3.getReference(dagothID)
    if tes3.getJournalIndex {id = sixthHouseQuestID} >= 60 then return end
    if tes3.player.data.OotG.trooperGreeted then return end
    if not dagothRef.mobile.isDead then return end
    for _, trooperID in pairs(troopers) do
        log:debug("%s scanned", trooperID)
        local trooperRef = tes3.getReference(trooperID)
        if not trooperRef.mobile.inCombat then
            log:debug("%s is not in combat", trooperID)
            if trooperRef.mobile.playerDistance < 256 then
                log:debug("%s is close to the player", trooperID)
                if trooperRef.mobile.position:distance(dagothRef.mobile.position) >=
                    256 then
                    log:debug("%s is far away enough from dagoth nasro",
                              trooperID)
                    if tes3.testLineOfSight({
                        reference1 = trooperRef,
                        reference2 = tes3.player
                    }) then
                        local wasShown =
                            tes3.showDialogueMenu({reference = trooperRef})
                        if wasShown then
                            tes3.player.data.OotG.trooperGreeted = true
                            return
                        end
                    end
                end
            end
        end
    end
end

--- @param e infoGetTextEventData
local function onBouncerInfoGetText(e)
    if e.info.id == bouncerForceGreetInfoID then
        if tes3.player.cell.id == "Ossuary of Ayem, Bone Pit" then
            if tes3.player.data.OotG.playerEnteredFromWesternCatacombs then
                e.text =
                    "Hey, you're not one of the Ghosts. How did you get in there?"
            end
        end
    end
end

--- @param e cellChangedEventData
local function checkIfEnterFromWesternCatacombs(e)
    if e.cell.id == "Ossuary of Ayem, Bone Pit" then
        if tes3.getJournalIndex {id = sixthHouseQuestID} >= 10 then
            if e.previousCell.id == "Western Catacombs" then
                tes3.player.data.OotG.playerEnteredFromWesternCatacombs = true
            end
        end
    end
end

local function onLoad()
    tes3.player.data.OotG = tes3.player.data.OotG or {}
    event.register("cellChanged", checkIfEnterFromWesternCatacombs)
    event.register("infoGetText", onBouncerInfoGetText)
    event.register("simulate", trooperForceGreetPlayer)
    event.register("damage", bleedingSkullEffect)
end
event.register("loaded", onLoad)

local function changeBleedingSkullValue()
    local skull = tes3.getObject(skullID)
    if skull then skull.value = 250 end
end
event.register("initialized", changeBleedingSkullValue)

