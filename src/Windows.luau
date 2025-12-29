--[[
    Windows reactive submodule
    To be used with ReactiveTags
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")

local Janitor = require(ReplicatedStorage.Packages.jTools.Janitor)
local module = {}
local WindowObj = {}
WindowObj.__index = WindowObj

module.Tags = {
    Window = module.WindowNew,
    WindowManager = module.ButtonNew
}

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
    local self = setmetatable({}, WindowObj)
    assert(Window:IsA("GuiObject"), "The only eligable class for windows is GuiObject!")
    
    local UID = Window:GetAttribute("WindowUID") :: string?
    local Type = Window:GetAttribute("WindowType") :: string?
    local DefaultCloseAnim = Window:GetAttribute("DefaultCloseAnim") :: string?

    assert(not Window:FindFirstChildWhichIsA("UIScale"), "Windows cannot be controlled by UIScale! If you *need* UIScale, change it's hierarchy, so it's not a direct child of the window.")

    local UIScale = Instance.new("UIScale")
    UIScale.Parent = Window

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

function WindowObj.SetState(self:WindowObj, state:boolean, Anim:string?)
    if Anim == "Pop" then
        self:Pop(state)
    else
        self.Window.Visible = state
    end
end

function WindowObj.Pop(self:WindowObj, state:boolean)
    self.Janitor:Cleanup()
    self.Action = state and "Open" or "Close"
    if state then
        self.Window.Visible = state
    end
    local Window:GuiObject = self.Window
    local UIScale = Window:FindFirstChildWhichIsA("UIScale") :: UIScale
    local tween: Tween
    if state then
        tween = TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Scale = 1})
    else
        tween = TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 0})
    end
    tween:Play()
    self.Janitor:Add(tween.Completed:Once(function()
        self.Window.Visible = state
        self.Action = nil
    end))
end

function module.ButtonNew(Button:GuiButton)
    local TargetUID = Button:GetAttribute("TargetUID") :: string?
    assert(TargetUID, "Failed to create a WindowManager: TargetUID is not specified!")
    local ButtonType = Button:GetAttribute("ButtonType") or "Switch"
    local CloseOthers = Button:GetAttribute("CloseOthers") or false
    local CloseOthersOfType = Button:GetAttribute("CloseOthersOfType") or false
    local AnimOpen = Button:GetAttribute("AnimOpen") :: string?
    local AnimClose = Button:GetAttribute("AnimClose") :: string? -- "None" will FORCE the window to nil. If not "None", CloseOthers and CloseOthersOfType will use DefaultCloseAnim from window.
    Button.Activated:Connect(function()
        print("activate happened")
        local self = module.FromWindowUID(TargetUID)
        if not self then return end
        if ButtonType == "Open" then
            if self:GetState() then return end
            if CloseOthers then
                self:CloseOthers(AnimClose)
            elseif CloseOthersOfType then
                module.CloseAllType(CloseOthersOfType, AnimClose, true, self)
            end
            self:SetState(true, AnimOpen)
        elseif ButtonType == "Close" then
            if not self:GetState() then return end
            self:SetState(false, AnimClose)
        elseif ButtonType == "Switch" then
            local TargetState = not self:GetState()
            local Anim = TargetState and AnimOpen or AnimClose
            self:SetState(TargetState, Anim)
        end
    end)
end

export type WindowObj = typeof(module.WindowNew())

return module