local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Set walkspeed
humanoid.WalkSpeed = 50

-- Create and load the animation
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
