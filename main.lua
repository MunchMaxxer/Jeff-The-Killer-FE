local player = game.Players.LocalPlayer
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

-- Fling other players on touch
character:WaitForChild("HumanoidRootPart").Touched:Connect(function(hit)
    local otherPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
    if otherPlayer and otherPlayer ~= player then
        local otherHumanoidRootPart = hit.Parent:FindFirstChild("HumanoidRootPart")
        if otherHumanoidRootPart then
            -- Apply fling force
            local direction = (otherHumanoidRootPart.Position - character.HumanoidRootPart.Position).unit
            local flingForce = Instance.new("BodyVelocity")
            flingForce.MaxForce = Vector3.new(100000, 100000, 100000)  -- High force
            flingForce.Velocity = direction * 100  -- Adjust fling strength here
            flingForce.Parent = otherHumanoidRootPart
            
            -- Clean up fling force after a brief period
            game.Debris:AddItem(flingForce, 0.1)
        end
    end
end)

-- Tool animation logic
local function onToolActivated(tool, animationId)
    -- Create and load the tool animation
    local toolAnimation = Instance.new("Animation")
    toolAnimation.AnimationId = animationId

    -- Load animation for the humanoid
    local toolAnimationTrack = animator:LoadAnimation(toolAnimation)

    -- Play animation when the tool is activated
    tool.Activated:Connect(function()
        if not toolAnimationTrack.IsPlaying then
            toolAnimationTrack:Play()
        end
        
        -- Play sound when the tool is used
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4678745096"  -- Sound ID
        sound.Parent = tool.Handle  -- Attach sound to the tool's handle
        sound:Play()

        -- Cleanup sound after it finishes playing
        sound.Ended:Connect(function()
            sound:Destroy()
        end)

        -- Apply invisible spinning force to the character for 0.4 seconds
        local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.MaxTorque = Vector3.new(100000, 100000, 100000)  -- High torque
        bodyAngularVelocity.AngularVelocity = Vector3.new(0, 1000, 0)  -- Very fast spin (Y axis)
        bodyAngularVelocity.Parent = character:WaitForChild("HumanoidRootPart")

        -- Remove the spin after 0.4 seconds
        wait(0.4)
        bodyAngularVelocity:Destroy()

        -- NO THRUST or MOVEMENT applied to the character, just invisible spin for 0.4 seconds
    end)
end

-- Create the tools
local function createTool(toolName, animationId)
    local tool = Instance.new("Tool")
    tool.Name = toolName
    tool.Parent = player.Backpack  -- Add tool to player's backpack

    -- Add a part to the tool (this is optional, for visuals)
    local part = Instance.new("Part")
    part.Name = "Handle"
    part.Size = Vector3.new(1, 5, 1)
    part.Anchored = false
    part.CanCollide = false
    part.Parent = tool

    -- Bind the animation to the tool
    onToolActivated(tool, animationId)

    return tool
end

-- Create the two tools
local downStabTool = createTool("DownStabTool", "rbxassetid://94161088")
local stabPunchTool = createTool("StabPunchTool", "rbxassetid://94161333")
