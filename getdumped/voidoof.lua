local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local function forceResetToVoid()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        character = player.CharacterAdded:Wait()
    end
    
    -- Save current position and camera settings
    local savedPosition = character.HumanoidRootPart.CFrame
    local savedCameraSubject = camera.CameraSubject
    local savedCameraType = camera.CameraType
	-- Use the fixed offset here
    local savedCameraOffset = Vector3.new(0, -50000, 0)
    local savedCameraOrientation = camera.CFrame - camera.CFrame.Position  -- Capture the orientation part of the camera

    -- Freeze camera
    camera.CameraType = Enum.CameraType.Scriptable
    
    -- Teleport to an even lower position in the void (lower Y-coordinate)
    character:SetPrimaryPartCFrame(CFrame.new(80, -448, -35) - Vector3.new(0, 50, 0))  -- Further lowered Y-coordinate
    
    -- Set up respawn handler
    local connection
    connection = player.CharacterAdded:Connect(function(newCharacter)
        connection:Disconnect()
        
        -- Wait for essential parts
        local humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
        local humanoid = newCharacter:WaitForChild("Humanoid")
        
        -- Ensure character is fully loaded
        task.wait(0.1)
        
        -- Teleport back
        newCharacter:SetPrimaryPartCFrame(savedPosition)
        
        -- Reset camera properly
        task.wait(0.1)
        
        -- Restore camera settings
        camera.CameraType = savedCameraType
        camera.CameraSubject = humanoid
        
        -- Smooth camera transition without changing orientation
        local function smoothCameraReset()
            local startCFrame = camera.CFrame
            local endCFrame = savedPosition * CFrame.new(savedCameraOffset)
            
            -- Keep the same orientation, but lerp position
            local startOrientation = startCFrame - startCFrame.Position
            local endOrientation = savedCameraOrientation
            
            for i = 0, 1, 0.1 do
                if not newCharacter:IsDescendantOf(workspace) then break end
                camera.CFrame = startOrientation:Lerp(endOrientation, i) * CFrame.new(camera.CFrame.Position:Lerp(endCFrame.Position, i))
                task.wait()
            end
            
            -- Final position with orientation
            camera.CFrame = endOrientation * CFrame.new(endCFrame.Position)
        end
        
        -- Run the smooth transition
        task.spawn(smoothCameraReset)
        
        -- Lock mouse if it was locked before
        if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end)
    
    -- Force the reset
    task.wait(0.5)
end

-- Function to manually fix camera if needed
local function fixCamera()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        camera.CameraSubject = character.Humanoid
        camera.CameraType = Enum.CameraType.Custom
    end
end

-- Call the main function
forceResetToVoid()

-- Expose fix camera function
return {
    forceResetToVoid = forceResetToVoid,
    fixCamera = fixCamera
}
