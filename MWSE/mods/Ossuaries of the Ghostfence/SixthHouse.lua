local log = require("logging.logger").new({
    name = "OotG Sixth House Quest",
    logLevel = "DEBUG"
})
local sixthHouseQuestID = "GG_6thHouse"
local isWesternCatacombsRunner = {
    ["GG_defender_01"] = true,
    ["GG_defender_02"] = true,
    ["GG_runner_01"] = true,
    ["GG_runner_02"] = true,
    ["GG_sergeant_01"] = true,
    ["GG_sergeant_02"] = true
}
local bouncerID = "GG_broder_favel"
local bouncerForceGreetInfoID = "2020366741859230377"
local bouncerDoorID = "GG_Ex_V_cantondoor_6th"
local dreamerID = "GG_dreamer"
-- local dreamerFader = nil
local dagothID = "GG_6_ash_ghoul_nasro"
local troopers = {
    "GG_alynu_menas", "GG_dartis_iba", "GG_dralane_murith", "GG_tennus_dolovas"
}

local function fleshsHeartTooltip(e)
    if e.object.id == "GG_Bleeding_Skull_Identified" then
        local block = e.tooltip:createBlock{}
        block.minWidth = 1
        block.maxWidth = 440
        block.autoWidth = true
        block.autoHeight = true
        block.paddingAllSides = 4
        local label = (block:createLabel{
            id = tes3ui.registerID("GG_Bleeding_Skull_desc"),
            text = "Save One Life"
        })
        label.wrapText = true
    end
end
event.register("uiObjectTooltip", fleshsHeartTooltip)

--- @param e damageEventData
local function bleedingSkullEffect(e)
    if tes3.getItemCount({
        reference = tes3.player,
        item = "GG_Misc_Bleeding_Skull"
    }) > 0 then
        if e.reference == tes3.player then
            if e.damage >= tes3.player.mobile.health.current then
                tes3.removeItem({
                    reference = tes3.player,
                    item = "GG_Misc_Bleeding_Skull",
                    playSound = false
                })
                tes3.playSound({sound = "restoration hit"})
                tes3.messageBox({message = "The Bleeding Skull saved one life."})
                return false
            end
        end
    end
end
event.register("damage", bleedingSkullEffect)

local function trooperForceGreetPlayer()
    if tes3.player.cell.id == "Western Catacombs" then
        local dagothRef = tes3.getReference(dagothID)
        if tes3.getJournalIndex {id = sixthHouseQuestID} < 60 then
            if dagothRef.mobile.isDead then
                for _, trooperID in pairs(troopers) do
                    local trooperRef = tes3.getReference(trooperID)
                    if not trooperRef.mobile.inCombat and
                        trooperRef.mobile.playerDistance < 224 then
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
end

local function allTroopsAreDead()
    return tes3.getReference("GG_alynu_menas").mobile.isDead and
               tes3.getReference("GG_dartis_iba").mobile.isDead and
               tes3.getReference("GG_dralane_murith").mobile.isDead and
               tes3.getReference("GG_tennus_dolovas").mobile.isDead
end

--- @param e deathEventData
local function onDagothNasroDeath(e)
    if tes3.player.cell.id == "Western Catacombs" then
        local dagothRef = tes3.getReference(dagothID)
        if e.reference == dagothRef then
            if allTroopsAreDead() then
                tes3.updateJournal({id = sixthHouseQuestID, index = 50})
            else
                tes3.updateJournal({id = sixthHouseQuestID, index = 55})
            end
        end
    end
end

local function dagothForceGreetPlayer()
    if tes3.player.cell.id == "Western Catacombs" then
        local dagothRef = tes3.getReference(dagothID)
        if not dagothRef.mobile.isDead and dagothRef.mobile.playerDistance < 224 then
            if tes3.testLineOfSight({
                reference1 = dagothRef,
                reference2 = tes3.player
            }) and not tes3.player.data.OotG.dagothGreeted then
                local wasShown = tes3.showDialogueMenu({reference = dagothID})
                if wasShown then
                    tes3.player.data.OotG.dagothGreeted = true
                end
            end
        end
    end
end

--[[local function stageBattle()
    if tes3.player.cell.id == "Western Catacombs" then
        if tes3.getJournalIndex {id = sixthHouseQuestID} >= 60 then
            return
        end
        if tes3.getJournalIndex {id = sixthHouseQuestID} >= 10 then
            if tes3.menuMode() then return end
            if tes3.getReference("GG_alynu_menas").mobile.playerDistance < 512 and
                not tes3.player.data.OotG.alynuStartCombatOnce then
                tes3.getReference("GG_alynu_menas").mobile:startCombat(
                    tes3.getReference("ascended_sleeper").mobile)
                tes3.getReference("GG_alynu_menas").mobile:startCombat(
                    tes3.getReference("corprus_stalker").mobile)
                tes3.getReference("GG_alynu_menas").mobile:startCombat(
                    tes3.getReference("GG_6_GrotesqueCorprus").mobile)
                tes3.player.data.OotG.alynuStartCombatOnce = true
            end
            if tes3.getReference("GG_tennus_dolovas").mobile.playerDistance <
                512 and not tes3.player.data.OotG.tennusStartCombatOnce then
                tes3.getReference("GG_tennus_dolovas").mobile:startCombat(
                    tes3.getReference("GG_6_GrotesqueCorprus").mobile)
                tes3.getReference("GG_tennus_dolovas").mobile:startCombat(
                    tes3.getReference("ascended_sleeper").mobile)
                tes3.getReference("GG_tennus_dolovas").mobile:startCombat(
                    tes3.getReference("corprus_stalker").mobile)
                tes3.player.data.OotG.tennusStartCombatOnce = true
            end
            if tes3.getReference("GG_dralane_murith").mobile.playerDistance <
                512 and not tes3.player.data.OotG.dralaneStartCombatOnce then
                tes3.getReference("GG_dralane_murith").mobile:startCombat(
                    tes3.getReference("ash_ghoul").mobile)
                tes3.getReference("GG_dralane_murith").mobile:startCombat(
                    tes3.getReference("ash_slave").mobile)
                tes3.getReference("GG_dralane_murith").mobile:startCombat(
                    tes3.getReference("ash_zombie").mobile)
                tes3.player.data.OotG.dralaneStartCombatOnce = true
            end
            if tes3.getReference("GG_dartis_iba").mobile.playerDistance < 512 and
                not tes3.player.data.OotG.dartisStartCombatOnce then
                tes3.getReference("GG_dartis_iba").mobile:startCombat(
                    tes3.getReference("ash_zombie").mobile)
                tes3.getReference("GG_dartis_iba").mobile:startCombat(
                    tes3.getReference("ash_ghoul").mobile)
                tes3.getReference("GG_dartis_iba").mobile:startCombat(
                    tes3.getReference("ash_slave").mobile)
                tes3.player.data.OotG.dartisStartCombatOnce = true
            end
        end
    end
end]]

--- @param e deathEventData
local function dreamerExplode(e)
    if tes3.player.cell.id == "Western Catacombs" then
        if e.reference.baseObject.id == dreamerID then
            tes3.updateJournal({
                id = sixthHouseQuestID,
                index = 30,
                showMessage = true
            })
        end
    end
end

--- @param e damageEventData
local function blockDreamerDamage(e)
    if e.reference == tes3.getReference(dreamerID) then
        if e.attacker == tes3.mobilePlayer then
            if tes3.testLineOfSight({
                reference1 = e.reference,
                reference2 = tes3.player
            }) and not tes3.player.data.OotG.dreamerGreeted then
                local wasShown = tes3.showDialogueMenu({reference = dreamerID})
                if wasShown then
                    tes3.player.data.OotG.dreamerGreeted = true
                end
            end
            return false
        elseif e.magicSourceInstance.id == "GG_dreamer_self_destruct" then
            return true
        elseif e.source == "script" then
            return true
        end
    end
end

--[[local waypoint1 = tes3vector3.new(1779, 13517, 1042)
local waypoint2 = tes3vector3.new(1807, 12505, 1042)
local waypoint3 = tes3vector3.new(1760, 12054, 1042)
local waypoint4 = tes3vector3.new(2120, 12288, 1042)

local function sergeantAITravel()
    if tes3.player.cell.id == "Western Catacombs" then
        if tes3.getJournalIndex {id = sixthHouseQuestID} >= 20 and
            tes3.player.data.OotG.sergeantAITravel then
            -- aiTravel waypoint
            if tes3.getReference("GG_Sergeant_Llevi").mobile.position:distance(
                waypoint4) < 128 then
                log:debug("Sergeant stops traveling!")
                tes3.player.data.OotG.sergeantAITravel = false
                event.unregister("simulate", sergeantAITravel)
                return
            end
            if tes3.getReference("GG_Sergeant_Llevi").mobile.position:distance(
                waypoint3) < 128 then
                log:debug("Sergeant is traveling to waypoint 4!")
                tes3.setAITravel({
                    reference = tes3.getReference("GG_Sergeant_Llevi"),
                    destination = waypoint4,
                    reset = false
                })
                return
            end
            if tes3.getReference("GG_Sergeant_Llevi").mobile.position:distance(
                waypoint2) < 128 then
                log:debug("Sergeant is traveling to waypoint 3!")
                tes3.setAITravel({
                    reference = tes3.getReference("GG_Sergeant_Llevi"),
                    destination = waypoint3,
                    reset = false
                })
                return
            end
            if tes3.getReference("GG_Sergeant_Llevi").mobile.position:distance(
                waypoint1) < 128 then
                log:debug("Sergeant is traveling to waypoint 2!")
                tes3.setAITravel({
                    reference = tes3.getReference("GG_Sergeant_Llevi"),
                    destination = waypoint2,
                    reset = false
                })
                return
            end
            log:debug("Sergeant is traveling to waypoint 1!")
            tes3.setAITravel({
                reference = tes3.getReference("GG_Sergeant_Llevi"),
                destination = waypoint1
            })
        end
    end
end]]

--[[--- @param e journalEventData
local function forceExitSergeantDialog(e)
    if e.topic.id == sixthHouseQuestID and e.index == 20 then
        timer.start {
            duration = 1,
            type = timer.real,
            callback = function()
                tes3.closeDialogueMenu({})
                -- Sergeant Llevi runs to set marker
                tes3.getReference("GG_Sergeant_Llevi").mobile.forceRun = true
                tes3.getReference("GG_Sergeant_Llevi").mobile.speed.current =
                    tes3.mobilePlayer.speed.current - 10
                tes3.player.data.OotG.sergeantAITravel = true
            end
        }
        event.unregister("journal", forceExitSergeantDialog)
    end
end]]

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

local function bouncerForceGreetPlayer()
    if tes3.player.cell.id == "Ossuary of Ayem, Bone Pit" then
        if not tes3.player.data.OotG.bouncerGreeted then
            local bouncerRef = tes3.getReference(bouncerID)
            if not bouncerRef.mobile.isDead and bouncerRef.mobile.playerDistance <
                224 then
                local wasShown = tes3.showDialogueMenu({reference = bouncerID})
                if wasShown then
                    tes3.player.data.OotG.bouncerGreeted = true
                end
            end
        end
    end
end

--- @param e cellChangedEventData
local function onOssuaryOfAyemCellChanged(e)
    if e.cell.id == "Ossuary of Ayem, Bone Pit" then
        -- the player has reported back to the Prefect, re-disable Broder Favel and the locked door
        if tes3.getJournalIndex {id = sixthHouseQuestID} >= 50 then
            tes3.setEnabled({reference = bouncerID, enabled = false})
            tes3.setEnabled({reference = bouncerDoorID, enabled = false})
            event.unregister("cellChanged", onOssuaryOfAyemCellChanged)
            return
            -- the player has received the Sixth House quest,
            -- enable Broder Favel and forcegreet the player
        elseif tes3.getJournalIndex {id = sixthHouseQuestID} >= 10 then
            tes3.setEnabled({reference = bouncerID, enabled = true})
            tes3.setEnabled({reference = bouncerDoorID, enabled = true})
            if e.previousCell.id == "Western Catacombs" then
                tes3.player.data.OotG.playerEnteredFromWesternCatacombs = true
            end
            -- the player hasn't received the Sixth House quest,
            -- disable Broder Favel
        else
            tes3.setEnabled({reference = bouncerID, enabled = false})
            tes3.setEnabled({reference = bouncerDoorID, enabled = false})
        end
    end
end

--- @param e cellChangedEventData
local function onWesternCatacombsCellChanged(e)
    if e.cell.id == "Western Catacombs" then
        -- the player has killed Dagoth Nasro, 
        -- re-enable the regular patrol the next time the player enter the Western Catacombs
        if tes3.getJournalIndex {id = sixthHouseQuestID} >= 50 then
            for npcRef in e.cell:iterateReferences() do
                if isWesternCatacombsRunner[npcRef.baseObject.id] then
                    tes3.setEnabled({reference = npcRef, enabled = true})
                end
            end
            -- position the urns
            tes3.getReference("GG_o_UrnAsh_03_6th_01").position =
                tes3.getReference("GG_o_UrnAsh_03_6th_01").startingPosition
            tes3.getReference("GG_o_UrnAsh_03_6th_01").rotation =
                tes3.getReference("GG_o_UrnAsh_03_6th_01").startingOrientation
            tes3.getReference("GG_o_UrnAsh_03_6th_02").position =
                tes3.getReference("GG_o_UrnAsh_03_6th_02").startingPosition
            tes3.getReference("GG_o_UrnAsh_03_6th_02").rotation =
                tes3.getReference("GG_o_UrnAsh_03_6th_02").startingOrientation
            event.unregister("cellChanged", onWesternCatacombsCellChanged)
            return
        elseif tes3.getJournalIndex {id = sixthHouseQuestID} >= 10 then
            -- the player has received the Sixth House quest,
            -- disable the regular patrol the next time the player enter the Western Catacombs
            for npcRef in e.cell:iterateReferences() do
                if isWesternCatacombsRunner[npcRef.baseObject.id] then
                    tes3.setEnabled({reference = npcRef, enabled = false})
                end
            end
            -- knock over the urns
            tes3.getReference("GG_o_UrnAsh_03_6th_01").position =
                tes3vector3.new(2359.604, 11822.049, 1063.146)
            tes3.getReference("GG_o_UrnAsh_03_6th_01").orientation =
                tes3vector3.new(0.73, 0.49, 0.13)
            tes3.getReference("GG_o_UrnAsh_03_6th_02").position =
                tes3vector3.new(2126.290, 11717.522, 1059.083)
            tes3.getReference("GG_o_UrnAsh_03_6th_02").orientation =
                tes3vector3.new(0.69, 0.36, 0.03)
        end
    end
end

--[[local function createDreamerFader()
    dreamerFader = tes3fader.new()
    dreamerFader:setTexture("Textures/vfx_alpha_bolt01.tga")
    dreamerFader:setColor({color = {0.77, 0.25, 0.22}})
    event.register("enterFrame", function() dreamerFader:update() end)
end
event.register("fadersCreated", createDreamerFader)]]

local function onLoaded()
    tes3.player.data.OotG = tes3.player.data.OotG or {}
    -- Only register this event if the player hasn't reported back to the Prefect
    if tes3.getJournalIndex {id = sixthHouseQuestID} < 70 then
        event.register("cellChanged", onWesternCatacombsCellChanged)
    end
    -- Only register this event if the player hasn't killed Dagoth Nasro or has killed Dagoth but hasn't received the Bleeding Skull 
    if tes3.getJournalIndex {id = sixthHouseQuestID} < 50 then
        event.register("cellChanged", onOssuaryOfAyemCellChanged)
        event.register("simulate", bouncerForceGreetPlayer)
        event.register("infoGetText", onBouncerInfoGetText)
        -- event.register("simulate", sergeantAITravel)
        event.register("damage", blockDreamerDamage)
        event.register("death", dreamerExplode)
        -- event.register("simulate", stageBattle)
        event.register("simulate", dagothForceGreetPlayer)
        event.register("death", onDagothNasroDeath)
        event.register("simulate", trooperForceGreetPlayer)
    end
    -- Only register this event if the player hasn't spoken to Sergeant Llevi
    --[[if tes3.getJournalIndex {id = sixthHouseQuestID} < 20 then
        event.register("journal", forceExitSergeantDialog)
    end]]
end
event.register("loaded", onLoaded)
