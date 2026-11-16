local button = script.Parent
local replicatedStorage = game:GetService("ReplicatedStorage")

local growingComputer = replicatedStorage:WaitForChild("GrowingComputer")
local soundService = game:GetService("SoundService")
local clickSound = soundService["Click sound"]



button.MouseButton1Click:Connect(function()
	local clickSoundCopy = clickSound:Clone()
	clickSoundCopy.Parent = button
	clickSoundCopy:Play()
	growingComputer:FireServer("Select")
	clickSoundCopy.Ended:Wait()
	clickSoundCopy:Destroy()
end)

