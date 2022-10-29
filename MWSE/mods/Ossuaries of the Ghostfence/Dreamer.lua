-- this file is used in the forcegreeting dialog result box by Dreamer
local dreamerRef = tes3.getReference("GG_dreamer")
local dreamerFader = require("Ossuaries of the Ghostfence.dreamerFader")
local sixthHouseQuestID = "GG_6thHouse"
tes3.playSound({sound = "GG_Argh"})
timer.start {
    duration = 1,
    type = timer.real,
    callback = function()
        tes3.closeDialogueMenu({})
        tes3.cast({
            reference = dreamerRef,
            target = dreamerRef,
            spell = "GG_dreamer_self_destruct",
            instant = true,
            alwaysSucceeds = true,
            bypassResistances = true
        })
        tes3.getReference("GG_dreamer").mobile:kill()
        dreamerFader:activate()
        tes3.fadeOut({fader = dreamerFader, duration = 0.01})
        tes3.setEnabled({reference = "GG_dreamer", enabled = false})
        tes3.setEnabled({reference = "AB_Fx_Blood02", enabled = true})
        tes3.setStatistic {
            reference = tes3.player,
            name = "fatigue",
            current = -1
        }
        if tes3.getReference("GG_Sergeant_Llevi").mobile.playerDistance < 128 then
            tes3.setStatistic {
                reference = tes3.getReference("GG_Sergeant_Llevi"),
                name = "fatigue",
                current = -1
            }
        end
        tes3.fadeIn({fader = dreamerFader, duration = 10})
        dreamerFader:deactivate()
        tes3.updateJournal({
            id = sixthHouseQuestID,
            index = 30,
            showMessage = true
        })
    end
}
