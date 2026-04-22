function GUI()
    UI.RemoveTab("SKIBIDI MENU")
    UI.AddTab("SKIBIDI MENU", function(tab)
        local left = tab:Section("Movement", "Left")

        left:Button("Swing For Brainrots", "Swing For Brainrots", function()
            UI.RemoveTab("SKIBIDI MENU")
        end)

        left:Button("Bike For Brainrots", "Bike", function()
            UI.RemoveTab("SKIBIDI MENU")
        end)
    end)

    notify("SKIBIDI MENU", "YOUR SO SIGMA", 5)
end

GUI()
