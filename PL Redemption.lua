local M, S = 12, 64
local P, RS = game:GetService("Players"), game:GetService("RunService")
local LP, TgN, En = P.LocalPlayer, "", false
local SG = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", SG)
F.Size, F.Position, F.BackgroundColor3 = UDim2.new(0, 150, 0, 70), UDim2.new(0.5, -75, 0.1, 0), Color3.new(0.1, 0.1, 0.1)
local TB, BT = Instance.new("TextBox", F), Instance.new("TextButton", F)
TB.Size, TB.Position, TB.PlaceholderText, TB.Text = UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 0, 0, 0), "Player Name", ""
BT.Size, BT.Position, BT.Text, BT.BackgroundColor3, BT.TextColor3 = UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 0, 0.5, 0), "Toggle: OFF", Color3.new(0.2, 0.2, 0.2), Color3.new(1, 1, 1)
TB.FocusLost:Connect(function(EP)
	if not EP then return end
	local input = TB.Text:lower()
	if input == "" then Tgt = nil return end
	for _, v in P:GetPlayers() do
		if v ~= LP and (v.Name:lower():find(input) or v.DisplayName:lower():find(input)) then
			TgN, TB.Text = v.Name, v.Name
			break
		end
	end
end)
BT.MouseButton1Click:Connect(function()
	En = not En
	BT.Text, BT.BackgroundColor3 = En and "Toggle: ON" or "Toggle: OFF", En and Color3.new(0, 0.5, 0) or Color3.new(0.2, 0.2, 0.2)
end)
local go, ocf, ohrp = nil, nil, nil
task.spawn(function()
	while true do
		local dt = RS.Heartbeat:Wait()
		local Tgt = P:FindFirstChild(TgN)
		local char, tChar = LP.Character, Tgt and Tgt.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local hrp = char.HumanoidRootPart
			if not (LP.TeamColor == BrickColor.new("Really red") and char:FindFirstChildOfClass("ForceField")) then
				if En then
					if tChar and tChar:FindFirstChild("HumanoidRootPart") then
						local tHrp = tChar.HumanoidRootPart
						go = tHrp.CFrame * CFrame.new(0, -5.35, 0)
						if (hrp.Position - tHrp.Position).Magnitude < 12 then
							sethiddenproperty(hrp, "PhysicsRepRootPart", tHrp)
						end
					end
				end
				if ohrp ~= hrp then
					if ohrp and ohrp.CFrame.Position == ohrp.CFrame.Position then
						go = ohrp.CFrame
					end
					ohrp, ocf = hrp, nil
				end
				if go then
					if not ocf then ocf = hrp.CFrame end
					local dist = (ocf.Position - go.Position).Magnitude
					local adv = dt * S
					if adv < dist then
						ocf = ocf:Lerp(go, adv / dist)
					else
						ocf, go = go, nil
					end
					hrp.CFrame = ocf
					hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
				end
			end
		end
	end
end)
