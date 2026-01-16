local P, RS, RL = game:GetService("Players"), game:GetService("RunService"), game:GetService("ReplicatedStorage"):WaitForChild("meleeEvent")
local LP, TgN, En = P.LocalPlayer, "", false
local SG = Instance.new("ScreenGui", game:GetService("CoreGui"))
local F = Instance.new("Frame", SG)
F.Size, F.Position, F.BackgroundColor3 = UDim2.new(0, 150, 0, 90), UDim2.new(0.5, -75, 0.1, 0), Color3.new(0.1, 0.1, 0.1)
local TB, BT, CL = Instance.new("TextBox", F), Instance.new("TextButton", F), Instance.new("TextLabel", F)
TB.Size, TB.Position, TB.PlaceholderText, TB.Text = UDim2.new(1, 0, 0.33, 0), UDim2.new(0, 0, 0, 0), "Player Name", ""
BT.Size, BT.Position, BT.Text, BT.BackgroundColor3, BT.TextColor3 = UDim2.new(1, 0, 0.33, 0), UDim2.new(0, 0, 0.33, 0), "Toggle: OFF", Color3.new(0.2, 0.2, 0.2), Color3.new(1, 1, 1)
CL.Size, CL.Position, CL.Text, CL.BackgroundColor3, CL.TextColor3 = UDim2.new(1, 0, 0.34, 0), UDim2.new(0, 0, 0.66, 0), "Ready", Color3.new(0.15, 0.15, 0.15), Color3.new(1, 1, 1)
TB.FocusLost:Connect(function(EP)
	if not EP then return end
	local input = TB.Text:lower()
	if input == "" then TgN = "" return end
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
task.spawn(function()
	while true do
		task.wait()
		if En and TgN ~= "" then
			local Tgt = P:FindFirstChild(TgN)
			if Tgt and Tgt.Character and Tgt.Character:FindFirstChild("Humanoid") and Tgt.Character.Humanoid.Health > 0 then
				local tChar = Tgt.Character
				local tHrp = tChar:FindFirstChild("HumanoidRootPart")
				if tHrp then
					local sPos = nil
					CL.Text = "Killing..."
					while En and Tgt.Parent and Tgt.Character and Tgt.Character:FindFirstChild("Humanoid") and Tgt.Character.Humanoid.Health > 0 do
						local char = LP.Character
						local hrp = char and char:FindFirstChild("HumanoidRootPart")
						if hrp then
							if not sPos then sPos = hrp.CFrame end
							hrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.35, 0)
							sethiddenproperty(hrp, "PhysicsRepRootPart", tHrp)
							RL:FireServer(Tgt)
						end
						RS.Heartbeat:Wait()
					end
					local char = LP.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if hrp and sPos then hrp.CFrame = sPos end
					for i = 10, 1, -1 do
						if not En or TgN == "" then break end
						CL.Text = "Next Kill: " .. i .. "s"
						task.wait(1)
					end
					CL.Text = "Ready"
				end
			end
		end
	end
end)
