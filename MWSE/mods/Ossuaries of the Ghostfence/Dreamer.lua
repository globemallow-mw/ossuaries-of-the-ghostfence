-- this file is used in the forcegreeting dialog result box by Dreamer
local dreamerRef = tes3.getReference("GG_dreamer")
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
        tes3.cast({
            reference = dreamerRef,
            target = tes3.player,
            spell = "GG_dreamer_self_destruct",
            instant = true,
            alwaysSucceeds = true,
            bypassResistances = true
        })
        tes3.setStatistic {
            reference = tes3.player,
            name = "fatigue",
            current = -1
        }
        tes3.getReference("GG_dreamer").mobile:kill()
    end
}
