--[[
    WIP!
]]

    -- ["Shakey"] = function(v:Instance)
    --     -- safe error
    --     local function e(m)
    --         warn("Could not apply Shakey to instance", v, ":", m)
    --     end
    --     local x = v:GetAttribute("ShakeyX")
    --     local y = v:GetAttribute("ShakeyY")
    --     local rot = v:GetAttribute("ShakeyRot")
    --     -- default values are funky because all of those use the same sinus, so if speeds don't differ, they'll sync which is bad
    --     local speedx = v:GetAttribute("ShakeySpeedX") or 0.9
    --     local speedy = v:GetAttribute("ShakeySpeedY") or 1.05
    --     local speedrot = v:GetAttribute("ShakeySpeedRot") or 0.98
    --     if not x and not y and not rot then
    --         e("Tried to start Shakey without arguments!")
    --         return
    --     end
    --     x = x or 0
    --     y = y or 0
    --     rot = rot or 0
    --     local totaldt = 0
    --     local OrigPosition = v.Position
    --     local OrigRotation = v.Rotation
    --     local c = RunService.RenderStepped:Connect(function(dt)
    --         totaldt += dt
    --         CompoundRegister[v] = CompoundRegister[v] or {}
    --         v.Position = OrigPosition + UDim2.fromScale(math.sin(totaldt*speedx), math.sin(totaldt*speedy))
    --         v.Rotation = OrigRotation + math.sin(totaldt*speedrot)*rot - rot/2
    --     end)
    --     v.Destroying:Once(function()
    --         c:Disconnect()
    --     end)
    -- end
    -- temporary documentation:
--[[

Shakey:
    Change size using cos and sin always (smooth shaking fx)

HoverShakey:
    Change size using cos and sin while hovering (smooth shaking fx)

Hover:
    change size andor color on Hover

ClickBegin:
    change size andor color on Click

ClickEnded:
    change size andor color on Click Ended
    
]]