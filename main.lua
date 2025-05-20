local Options = {
    ["Render Distance"] = 400,
    ["Name"] = {
        ["Color"] = {255, 255, 255},
        ["Font"] = 5
    },
    ["updateTime"] = .01
}

local Drawings = {}
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

function addDraw(campos,playerpos,itemName)
    if CalculateDistance(campos,playerpos) > Options["Render Distance"] then return end

    local playerpos, OnScreen = WorldToScreenPoint({playerpos.x, playerpos.y, playerpos.z})

    if not OnScreen then return end

    local Name = Drawing.new("Text")
    Name.Visible = true
    Name.Color = Options.Name.Color
    Name.Size = 15
    Name.Font = Options.Name.Font
    Name.Outline = true
    Name.Text = string.match(itemName,"%s*%-+%s*(.-)%s*%-+")

    local textBounds = Name.TextBounds

    Name.Position = {playerpos.x-(textBounds.x/2),playerpos.y}

    table.insert(Drawings,Name)
end

while wait(Options["updateTime"]) do
    Drawing.clear()
    local CameraPos = getposition(Camera)
    local children2 = getchildren(Players)
    for i,plr in pairs(children2) do
        local vm = findVM(plr)
        if vm ~= nil and getname(vm) ~= "FirstPerson" then
            local character = getcharacter(plr)
            local head = findfirstchild(character,"HumanoidRootPart")
            if vm and character and head and getname(vm) ~= "FirstPerson" then
                addDraw(CameraPos,getposition(head),getname(vm))
            end
        end
    end
end
