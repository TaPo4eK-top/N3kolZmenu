local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/TaPo4eK-top/N3kolZlib/main/source/N3kolZ_library'))()

local Window = OrionLib:MakeWindow({
    Name = "N3kolZHub", 
    HidePremium = false, 
    ConfigFolder = "N3kolZTest"
})

local GraphicTab = Window:MakeTab({
    Name = "Графіка",
    Icon = "rbxassetid://17404114716", 
    PremiumOnly = false
})
