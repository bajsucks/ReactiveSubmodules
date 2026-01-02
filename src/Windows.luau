--[[
    Windows reactive submodule
    To be used with ReactiveTags

    Dependency: jTools https://github.com/bajsucks/jTools has to be placed in ReplicatedStorage.Packages
    ^ If you don't want to install it, you can just download jUtil and Janitor separately. jUtil is only used for .HasProperty() function.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local TweenService = game:GetService("TweenService")

local Janitor = require(ReplicatedStorage.Packages.jTools.Janitor)
local jUtil = require(ReplicatedStorage.Packages.jTools.jUtil)
local module = {}
local WindowObj = {}
WindowObj.__index = WindowObj

local RegisterUID = {} :: {string:WindowObj}
local RegisterType = {} :: {string:{WindowObj}}

function module.FromWindowUID(WindowUID:string): WindowObj
    return RegisterUID[WindowUID]
end

function module.CloseAllType(Type:string, Anim:string?, IgnoreSelf:boolean?, self:WindowObj?)
    for _, obj:WindowObj in RegisterType[Type] do
        if IgnoreSelf and obj == self then continue end
        if not obj:GetState() then continue end
        if Anim == "None" then
            obj:SetState(false)
        else
            obj:SetState(false, Anim or self.DefaultCloseAnim)
        end
    end
end

function WindowObj.CloseOthers(self:WindowObj, Anim:string?)
    for _, obj:WindowObj in RegisterUID do
        if obj == self then continue end
        if not obj:GetState() then continue end
        if Anim == "None" then
            obj:SetState(false)
        else
            obj:SetState(false, Anim or self.DefaultCloseAnim)
        end
    end
end

function module.WindowNew(Window:GuiObject)
    if Window:IsDescendantOf(StarterGui) then return end
    local self = setmetatable({}, WindowObj)
    assert(Window:IsA("GuiObject"), "The only eligable class for windows is GuiObject!")
    
    local UID = Window:GetAttribute("WindowUID") :: string?
    local Type = Window:GetAttribute("WindowType") :: string?
    local DefaultCloseAnim = Window:GetAttribute("DefaultCloseAnim") :: string?
    local FoundUIScale = Window:FindFirstChildWhichIsA("UIScale")
    if FoundUIScale then
        print(Window)
    end
    assert(not FoundUIScale, `Windows cannot be controlled by UIScale! If you *need* UIScale, change it's hierarchy, so it's not a direct child of the window.`)

    local UIScale = Instance.new("UIScale")
    UIScale.Parent = Window
    if Window.Visible then
        UIScale.Scale = 1
    else
        UIScale.Scale = 0
    end

    self.UID = UID
    self.Type = Type
    self.Window = Window
    self.Action = nil
    self.DefaultCloseAnim = DefaultCloseAnim
    self.Janitor = Janitor.new()
    RegisterUID[UID] = self
    if Type then
        RegisterType[Type] = RegisterType[Type] or {}
        table.insert(RegisterType[Type], self)
    end
    return self
end

function WindowObj.GetState(self:WindowObj)
    local state = self.Window.Visible
    if self.Action == "Close" then
        return not state
    else
        return state
    end
end

function WindowObj.SetState(self:WindowObj, state:boolean, Anim:string?, Speed:number?)
    if Anim == "Pop" then
        self:Pop(state, Speed)
    else
        if jUtil.HasProperty(self.Window, "Visible") then
            self.Window.Visible = state
        elseif jUtil.HasProperty(self.Window, "Enabled") then
            self.Window.Enabled = state
        end
    end
end

function WindowObj.Pop(self:WindowObj, state:boolean, speed:number?)
    self.Janitor:Cleanup()
    self.Action = state and "Open" or "Close"
    if state then
        self.Window.Visible = state
    end
    local Window:GuiObject = self.Window
    local UIScale = Window:FindFirstChildWhichIsA("UIScale") :: UIScale
    if not UIScale then
        warn("No UIScale present!")
    end
    local tween: Tween
    if state then
        tween = TweenService:Create(UIScale, TweenInfo.new(speed or 0.35, Enum.EasingStyle.Back), {Scale = 1})
    else
        tween = TweenService:Create(UIScale, TweenInfo.new(speed or 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 0})
    end
    tween:Play()
    self.Janitor:Add(tween.Completed:Once(function()
        self.Window.Visible = state
        self.Action = nil
    end))
end

function module.ButtonNew(Button:GuiButton)
    if Button:IsDescendantOf(StarterGui) then return end
    local TargetUID = Button:GetAttribute("TargetUID") :: string?
    assert(TargetUID, "Failed to create a WindowManager: TargetUID is not specified!")
    local ButtonType = Button:GetAttribute("ButtonType") or "Switch"
    local CloseOthers = Button:GetAttribute("CloseOthers") or false
    local CloseOthersOfType = Button:GetAttribute("CloseOthersOfType") or false
    local AnimOpen = Button:GetAttribute("AnimOpen") :: string?
    local AnimOpenSpeed = Button:GetAttribute("AnimOpenSpeed") :: number?
    local AnimClose = Button:GetAttribute("AnimClose") :: string? -- "None" will FORCE the window to nil. If not "None", CloseOthers and CloseOthersOfType will use DefaultCloseAnim from window.
    local AnimCloseSpeed = Button:GetAttribute("AnimCloseSpeed") :: number?
    Button.Activated:Connect(function()
        local self = module.FromWindowUID(TargetUID)
        if not self then return end
        if CloseOthers then
            self:CloseOthers(AnimClose)
        elseif CloseOthersOfType then
            module.CloseAllType(CloseOthersOfType, AnimClose, true, self)
        end
        if ButtonType == "Open" then
            if self:GetState() then return end
            self:SetState(true, AnimOpen, AnimOpenSpeed)
        elseif ButtonType == "Close" then
            if not self:GetState() then return end
            self:SetState(false, AnimClose, AnimCloseSpeed)
        elseif ButtonType == "Switch" then
            local TargetState = not self:GetState()
            local Anim = TargetState and AnimOpen or AnimClose
            local speed = TargetState and AnimOpenSpeed or AnimCloseSpeed
            self:SetState(TargetState, Anim, speed)
        end
    end)
end

module.Tags = {
    Window = module.WindowNew,
    WindowManager = module.ButtonNew
}

export type WindowObj = typeof(module.WindowNew())

return module