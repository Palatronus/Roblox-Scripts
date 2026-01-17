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
	local i = TB.Text:lower()
	if i == "" then TgN = "" return end
	for _, v in P:GetPlayers() do
		if v ~= LP and (v.Name:lower():find(i) or v.DisplayName:lower():find(i)) then
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
	local nJ, gR, cW, rp = 0, 0, 0, RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	while true do
		task.wait()
		if En and TgN ~= "" then
			local Tgt = P:FindFirstChild(TgN)
			if Tgt then
				local lP, lT = Vector3.zero, 0
				while En and Tgt.Parent and TgN == Tgt.Name do
					local c, tc = LP.Character, Tgt.Character
					local hrp, thrp = c and c:FindFirstChild("HumanoidRootPart"), tc and tc:FindFirstChild("HumanoidRootPart")
					local th, hum = tc and tc:FindFirstChild("Humanoid"), c and c:FindFirstChild("Humanoid")
					if hum and hrp then
						rp.FilterDescendantsInstances = {c}
						if not workspace:Raycast(hrp.Position, Vector3.new(0, -200, 0), rp) then hum.Health = 0 end
					end
					if hrp and thrp and th and th.Health > 0 then
						local dT = tick() - lT
						if dT > 0.1 then
							if (thrp.Position - lP).Magnitude / dT > 50 then 
								gR = 0 
								sethiddenproperty(hrp, "PhysicsRepRootPart", nil)
							end
							lP, lT = thrp.Position, tick()
						end
						local goal = thrp.CFrame * CFrame.new(0, -6, 0)
						local d = (hrp.Position - goal.Position).Magnitude
						if d >= 50 then
							if gR ~= 0 then cW = tick() + 1 CL.Text = "Waiting..." end
							gR = 0
							if tick() >= nJ and tick() >= cW then
								CL.Text = "Chasing..."
								hrp.CFrame = hrp.CFrame + (goal.Position - hrp.Position).Unit * 50
								nJ = tick() + 1
							end
						else
							RL:FireServer(Tgt)
							cW = 0
							if gR == 0 then gR = tick() + 1 end
							if tick() >= gR then
								CL.Text = "Killing..."
								hrp.CFrame = goal
								sethiddenproperty(hrp, "PhysicsRepRootPart", thrp)
							else
								CL.Text = "Locking..."
							end
						end
					else
						CL.Text = "Respawn/Team Change..."
						gR, cW = 0, 0
					end
					RS.Heartbeat:Wait()
				end
			end
			CL.Text = "Ready"
		end
	end
end)
]]
if queue_on_teleport then queue_on_teleport(script_source) end
loadstring(script_source)()
