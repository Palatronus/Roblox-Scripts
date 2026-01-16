local script_source = [[
workspace.Gravity = 0
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
	local nextJump, glueReady, chaseWait = 0, 0, 0
	while true do
		task.wait()
		if En and TgN ~= "" then
			local Tgt = P:FindFirstChild(TgN)
			if Tgt then
				CL.Text = "Tracking..."
				while En and Tgt.Parent and TgN == Tgt.Name do
					local char, tChar = LP.Character, Tgt.Character
					local hrp, tHrp = char and char:FindFirstChild("HumanoidRootPart"), tChar and tChar:FindFirstChild("HumanoidRootPart")
					local tH = tChar and tChar:FindFirstChild("Humanoid")
					if hrp and tHrp and tH and tH.Health > 0 then
						local dist = (hrp.Position - tHrp.Position).Magnitude
						if dist >= 50 then
							if glueReady ~= 0 then chaseWait = tick() + 1 end
							glueReady = 0
							if tick() >= nextJump and tick() >= chaseWait then
								hrp.CFrame = hrp.CFrame + (tHrp.Position - hrp.Position).Unit * 50
								nextJump = tick() + 1
							end
						else
							chaseWait = 0
							if glueReady == 0 then glueReady = tick() + 1 end
							if tick() >= glueReady then
								hrp.CFrame = tHrp.CFrame * CFrame.new(0, -5.35, 0)
								sethiddenproperty(hrp, "PhysicsRepRootPart", tHrp)
								RL:FireServer(Tgt)
							end
						end
					end
					RS.Heartbeat:Wait()
				end
				CL.Text = "Ready"
			end
		end
	end
end)
]]
if queue_on_teleport then queue_on_teleport(script_source) end
loadstring(script_source)()
