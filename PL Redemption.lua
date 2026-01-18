local plrs, rs, rep = game:GetService("Players"), game:GetService("RunService"), game:GetService("ReplicatedStorage")
workspace.Gravity = 0
local evt, lp = rep:WaitForChild("meleeEvent"), plrs.LocalPlayer
local on, tgn, tgt, idle = false, "", nil, CFrame.new(888.61, 41.10, 2353.52)
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local f = Instance.new("Frame", sg)
f.Size, f.Position, f.BackgroundColor3 = UDim2.new(0, 150, 0, 90), UDim2.new(0.5, -75, 0.1, 0), Color3.new(0.1, 0.1, 0.1)
local tb = Instance.new("TextBox", f)
tb.Size, tb.Position, tb.PlaceholderText, tb.Text = UDim2.new(1, 0, 0.33, 0), UDim2.new(0, 0, 0, 0), "Player Name", ""
local bt = Instance.new("TextButton", f)
bt.Size, bt.Position, bt.Text, bt.BackgroundColor3, bt.TextColor3 = UDim2.new(1, 0, 0.33, 0), UDim2.new(0, 0, 0.33, 0), "Toggle: OFF", Color3.new(0.2, 0.2, 0.2), Color3.new(1, 1, 1)
local cl = Instance.new("TextLabel", f)
cl.Size, cl.Position, cl.Text, cl.BackgroundColor3, cl.TextColor3 = UDim2.new(1, 0, 0.34, 0), UDim2.new(0, 0, 0.66, 0), "Ready", Color3.new(0.15, 0.15, 0.15), Color3.new(1, 1, 1)
tb.FocusLost:Connect(function(ep)
    if not ep or tb.Text == "" then tgn, tgt = "", nil return end
    local inp = tb.Text:lower()
    for _, v in pairs(plrs:GetPlayers()) do
        if v ~= lp and (v.Name:lower():find(inp) or v.DisplayName:lower():find(inp)) then
            tgn, tgt, tb.Text = v.Name, v, v.Name
            break
        end
    end
end)
bt.MouseButton1Click:Connect(function()
    on = not on
    bt.Text, bt.BackgroundColor3 = on and "Toggle: ON" or "Toggle: OFF", on and Color3.new(0, 0.5, 0) or Color3.new(0.2, 0.2, 0.2)
    if not on then cl.Text = "Ready" end
end)
rs.Heartbeat:Connect(function()
    local chr = lp.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if tgn ~= "" and (not tgt or not tgt.Parent) then tgt = plrs:FindFirstChild(tgn) end
    if on and tgt and tgt.Character then
        local tchr, hum = tgt.Character, chr:FindFirstChild("Humanoid")
        local thrp, thum = tchr:FindFirstChild("HumanoidRootPart"), tchr:FindFirstChild("Humanoid")
        if thrp and thum and hum then
            if thum.Health > 0 then
                cl.Text, hrp.CFrame, hrp.Velocity = "Killing...", thrp.CFrame * CFrame.new(0, -9, 0), Vector3.new(0,0,0)
                evt:FireServer(tgt)
                if sethiddenproperty then sethiddenproperty(hrp, "PhysicsRepRootPart", thrp) end
            else
                task.delay(4, function() if hum then hum.Health = 0 end end)
            end
        end
    else
        hrp.CFrame, hrp.Velocity = idle, Vector3.new(0,0,0)
    end
end)
