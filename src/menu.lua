local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/TaPo4eK-top/N3kolZmenu/main/src/menu.lua'))()

local Window = OrionLib:MakeWindow({
    Name = "N3kolZHub", 
    HidePremium = false, 
    ConfigFolder = "KlorPeTest"
})

local PlayerTab = Window:MakeTab({
    Name = "То что тебе нужно",
    Icon = "rbxassetid://17404114716",
    PremiumOnly = false
})
