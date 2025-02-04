local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Set walkspeed
humanoid.WalkSpeed = 50

-- Create and load the animation for walking
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://252557606"

local animator = humanoid:FindFirstChild("Animator")
if not animator then
    animator = Instance.new("Animator")
    animator.Parent = humanoid
end

local animationTrack = animator:LoadAnimation(animation)

-- Play animation when running
humanoid.Running:Connect(function(speed)
    if speed > 0 then
        if not animationTrack.IsPlaying then
            animationTrack:Play()
        end
    else
        animationTrack:Stop()
    end
end)

-- Fling function (runs for 0.4 seconds)
local function fling()
    local startTime = tick()

    RunService.Heartbeat:Connect(function()
        if tick() - startTime >= 0.4 then
            return  -- Stop fling after 0.4 seconds
        end

        local c = player.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, 0.1, 0)
        end
    end)
end

-- Tool activation function
local function onToolActivated(tool, animationId)
    local toolAnimation = Instance.new("Animation")
    toolAnimation.AnimationId = animationId

    local toolAnimationTrack = animator:LoadAnimation(toolAnimation)

    tool.Activated:Connect(function()
        if not toolAnimationTrack.IsPlaying then
            toolAnimationTrack:Play()
        end

        -- Play sound
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4678745096"
        sound.Parent = tool.Handle
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)

        -- Start fling for 0.4 seconds
        fling()
    end)
end

-- Create tools
local function createTool(toolName, animationId)
    local tool = Instance.new("Tool")
    tool.Name = toolName
    tool.Parent = player.Backpack

    local part = Instance.new("Part")
    part.Name = "Handle"
    part.Size = Vector3.new(1, 5, 1)
    part.Anchored = false
    part.CanCollide = false
    part.Parent = tool

    onToolActivated(tool, animationId)
    return tool
end

-- Create tools with animations
local downStabTool = createTool("DownStabTool", "rbxassetid://94161088")
local stabPunchTool = createTool("StabPunchTool", "rbxassetid://94161333")
