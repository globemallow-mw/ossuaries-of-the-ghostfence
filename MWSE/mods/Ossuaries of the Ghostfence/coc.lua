local locData = {
    ["ossuary of ayem"] = {
        exMarker = {
            position = tes3vector3.new(2064, 63008, 5072),
            orientation = tes3vector3.new(0, 0, -0.52)
        },
        inMarker = {
            cell = "Ossuary of Ayem",
            position = tes3vector3.new(6352, 5584, 17152),
            orientation = tes3vector3.new(0, 0, -3.14)
        }
    },
    ["ossuary of seht"] = {
        exMarker = {
            position = tes3vector3.new(56140, 59148, 776),
            orientation = tes3vector3.new(0, 0, -1.4)
        }
        -- inMarker = {
        --    cell = "Ossuary of Seht",
        --     position = tes3vector3.new(),
        --     orientation = tes3vector3.new()
        -- }
    },
    ["ossuary of vehk"] = {
        exMarker = {
            position = tes3vector3.new(11509, 100113, 9788),
            orientation = tes3vector3.new(0, 0, 1.37)
        }
        -- inMarker = {
        --    cell = "Ossuary of Vehk",
        --    position = tes3vector3.new(),
        --    orientation = tes3vector3.new()
        -- }
    },
    -- ["eastern catacombs"] = {
    --    inMarker = {
    --        cell = "Eastern Catacombs",
    --        position = tes3vector3.new(),
    --        orientation = tes3vector3.new()
    --    }
    -- },
    ["southern catacombs"] = {
        inMarker = {
            cell = "Southern Catacombs",
            position = tes3vector3.new(-384, 0, -48),
            orientation = tes3vector3.new(0, 0, 1.55)
        }
    }
    -- ["western catacombs"] = {
    --    inMarker = {
    --        cell = "Western Catacombs",
    --        position = tes3vector3.new(),
    --        orientation = tes3vector3.new()
    --    }
    -- }
}

event.register("UIEXP:sandboxConsole", function(e)
    e.sandbox.coc = function(locName, exOrIn)
        local isEx = (exOrIn == "ex")
        local isIn = (exOrIn == "in" or nil)
        if not ((isEx and locData[locName:lower()].exMarker) or
            (isIn and locData[locName:lower()].inMarker)) then
            tes3.messageBox("invalid location data")
            return
        end
        local executed
        if isEx then
            executed = tes3.positionCell({
                position = locData[locName:lower()].exMarker.position,
                orientation = locData[locName:lower()].exMarker.orientation
            })
        else
            executed = tes3.positionCell({
                cell = locData[locName:lower()].inMarker.cell,
                position = locData[locName:lower()].inMarker.position,
                orientation = locData[locName:lower()].inMarker.orientation
            })
        end
        if not executed then tes3.messageBox("command failed") end
    end
end)

-- lua console command:
-- coc("southern catacombs")
-- coc("ossuary of ayem","ex")
-- coc("ossuary of seht","ex")
-- coc("ossuary of vehk","ex")
