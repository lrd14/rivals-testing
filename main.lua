local Options = {
    ["Render Distance"] = 400,
    ["Name"] = {
        ["Color"] = {255, 255, 255},
        ["Font"] = 5
    },
    ["updateTime"] = .01
}

local users = {}
local Workspace = findfirstchildofclass(Game, "Workspace")
local Players = findfirstchildofclass(Game, "Players")
local viewmodels = findfirstchild(Workspace,"ViewModels")
local Camera = findfirstchild(Workspace, "Camera")

local function CalculateDistance(Position1, Position2)
    return math.sqrt((Position1.x - Position2.x) ^ 2 + (Position1.y - Position2.y) ^ 2 + (Position1.z - Position2.z) ^ 2)
end

function findVM(plr)
    local children = getchildren(viewmodels)
    for _,viewmodel in pairs(children) do
        if getname(viewmodel):find(getname(plr)) then
            return viewmodel
        end
    end
    return nil
end

function updateDraw(campos,playerpos,itemName,plrTable)
    if CalculateDistance(campos,playerpos) > Options["Render Distance"] then plrTable["Text"].Visible = false return end

    local playerpos, OnScreen = WorldToScreenPoint({playerpos.x, playerpos.y, playerpos.z})

    if not OnScreen then plrTable["Text"].Visible = false return end

    plrTable["Text"].Visible = true
    plrTable["Text"].Text = string.match(itemName,"%s*%-+%s*(.-)%s*%-+")

    local textBounds = plrTable["Text"].TextBounds

    plrTable["Text"].Position = {playerpos.x-(textBounds.x/2),playerpos.y}
end

function createUser(plr)
    local Name = Drawing.new("Text")
    Name.Visible = true
    Name.Color = Options.Name.Color
    Name.Size = 15
    Name.Font = Options.Name.Font
    Name.Outline = true
    Name.Text = "waiting for tool..."
    local newTable = {["Player"] = plr, ["Text"] = Name}
    table.insert(users,newTable)
end

function checkForNewPlayer(plr)
    for i,v in pairs(users) do
        if v["Player"] == plr then
            return false
        end
    end
    return true
end

spawn(function()
    while wait(Options["updateTime"]) do
        local CameraPos = getposition(Camera)
        for i,plrTable in pairs(users) do
            local vm = findVM(plrTable["Player"])
            if vm ~= nil and getname(vm) ~= "FirstPerson" then
                local character = getcharacter(plrTable["Player"])
                local head = findfirstchild(character,"HumanoidRootPart")
                if vm and character and head and getname(vm) ~= "FirstPerson" then
                    updateDraw(CameraPos,getposition(head),getname(vm),plrTable)
                end
            end
        end
    end
end)

spawn(function()
    while wait(2) do
        local children2 = getchildren(Players)
        for i,plr in pairs(children2) do
            if checkForNewPlayer(plr) then
                createUser(plr)
            end
        end
    end
end)
