local sixthHouseQuestID = "GG_6thHouse"
local westernCatacombsRunners = {
    "GG_defender_01", "GG_defender_02", "GG_runner_01", "GG_runner_02",
    "GG_sergeant_01", "GG_sergeant_02"
}
local bouncerID = "GG_broder_favel"
local bouncerRef = tes3.getReference(bouncerID)
local bouncerForceGreetInfoID = "2020366741859230377"
local bouncerDoorID = "GG_Ex_V_cantondoor_6th"
local sergeantFollowInfoID = "975176561115111786"
local dreamerID = "GG_dreamer"
local dagothID = "GG_6_ash_ghoul_nasro"
local dagothRef = tes3.getReference(dagothID)

--- @param e deathEventData
local function onDagothNasroDeath(e)
    if e.reference == dagothRef then
        -- count how many buoyant armigers and ghosts have survived
    end
end
event.register("death", onDagothNasroDeath)

local function dagothForceGreetPlayer()
    if tes3.player.cell.id == "Western Catacombs" then
        if not dagothRef.mobile.isDead and dagothRef.mobile.playerDistance < 224 then
            if tes3.testLineOfSight({
                reference1 = dagothRef,
                reference2 = tes3.player
            }) and not dagothRef.data.OotG.greeted then
                local wasShown = tes3.showDialogueMenu({reference = dagothID})
                if wasShown then
                    tes3.getReference(dagothID).data.OotG.greeted = true
                end
            end
        end
    end
end

--- @param e journalEventData
local function sergeantFlee(e)
    if e.topic == sixthHouseQuestID and e.index == 30 then
        if tes3.player.cell.id == "Western Catacombs" then
            tes3.getReference("GG_Sergeant_Llevi").mobile.actionData
                .aiBehaviorState = tes3.aiBehaviorState.flee
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
            }) and not e.reference.data.OotG.greeted then
                local wasShown = tes3.showDialogueMenu({reference = dreamerID})
                if wasShown then
                    e.reference.data.OotG.greeted = true
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

--- @param e infoGetTextEventData
local function forceExitSergeantDialog(e)
    if e.info.id == sergeantFollowInfoID then
        e.info.text = "Follow me!"
        tes3.updateJournal({id = sixthHouseQuestID, index = 20})
        timer.start {
            duration = 1,
            type = timer.real,
            callback = function()
                tes3.closeDialogueMenu({})
                -- Sergeant Llevi runs to set marker
                tes3.getReference("GG_Sergeant_Llevi").mobile.forceRun = true
                tes3.getReference("GG_Sergeant_Llevi").mobile.speed.current =
                    tes3.mobilePlayer.speed.current - 10
                tes3.getReference("GG_Sergeant_Llevi").mobile.weaponReady = true
                tes3.setAITravel({
                    reference = tes3.getReference("GG_Sergeant_Llevi"),
                    destination = tes3vector3.new(2180.349, 12067.575, 1040.956)
                })
            end
        }
        event.unregister("infoGetText", forceExitSergeantDialog)
    end
end

--- @param e infoGetTextEventData
local function onBouncerInfoGetText(e)
    if e.info.id == bouncerForceGreetInfoID then
        if bouncerRef.data.OotG.playerEnteredFromWesternCatacombs then
            e.text =
                "Hey, you're not one of the Ghosts. How did you get in there?"
        end
    end
end

local function bouncerForceGreetPlayer()
    if tes3.player.cell.id == "Ossuary of Ayem, Bone Pit" then
        if not bouncerRef.mobile.isDead and bouncerRef.mobile.playerDistance <
            224 then
            local wasShown = tes3.showDialogueMenu({reference = bouncerID})
            if wasShown then
                tes3.getReference(bouncerID).data.OotG.greeted = true
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
        elseif tes3.getJournalIndex {id = sixthHouseQuestID} >= 10 and
            not bouncerRef.data.OotG.greeted then
            tes3.setEnabled({reference = bouncerID, enabled = true})
            tes3.setEnabled({reference = bouncerDoorID, enabled = true})
            if e.previousCell.id == "Western Catacombs" then
                tes3.getReference(bouncerID).data.OotG
                    .playerEnteredFromWesternCatacombs = true
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
            for _, runner in pairs(westernCatacombsRunners) do
                tes3.setEnabled({reference = runner, enabled = true})
            end
            tes3.setEnabled({reference = "AB_Fx_Blood02", enabled = false})
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
            for _, runner in pairs(westernCatacombsRunners) do
                tes3.setEnabled({reference = runner, enabled = false})
            end
            -- knock over the urns
            tes3.getReference("GG_o_UrnAsh_03_6th_01").position =
                tes3vector3.new(2359.604, 11822.049, 1063.146)
            tes3.getReference("GG_o_UrnAsh_03_6th_01").rotation =
                tes3vector3.new(263.6, 176.7, 48.7)
            tes3.getReference("GG_o_UrnAsh_03_6th_02").position =
                tes3vector3.new(2126.290, 11717.522, 1059.083)
            tes3.getReference("GG_o_UrnAsh_03_6th_02").rotation =
                tes3vector3.new(251.1, 130.8, 11.5)
        elseif tes3.getJournalIndex {id = sixthHouseQuestID} < 30 then
            tes3.setEnabled({reference = "AB_Fx_Blood02", enabled = false})
        end
    end
end

local function onLoaded()
    -- Only register this event if the player hasn't reported back to the Prefect
    if tes3.getJournalIndex {id = sixthHouseQuestID} < 70 then
        event.register("cellChanged", onWesternCatacombsCellChanged)
    end
    -- Only register this event if the player hasn't killed Dagoth Nasro
    if tes3.getJournalIndex {id = sixthHouseQuestID} < 50 then
        event.register("cellChanged", onOssuaryOfAyemCellChanged)
        event.register("simulate", bouncerForceGreetPlayer)
        event.register("infoGetText", onBouncerInfoGetText)
        event.register("damage", blockDreamerDamage)
        event.register("journal", sergeantFlee)
        event.register("simulate", dagothForceGreetPlayer)
        event.register("death", onDagothNasroDeath)
    end
    -- Only register this event if the player hasn't spoken to Sergeant Llevi
    if tes3.getJournalIndex {id = sixthHouseQuestID} < 20 then
        event.register("infoGetText", forceExitSergeantDialog)
    end
end
event.register("loaded", onLoaded)
