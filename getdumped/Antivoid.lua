-- Function to safely set FallenPartsDestroyHeight to NaN
local function setDestroyHeightToNaN()
    -- Generate a NaN value
    local nan = 0/0  -- 0/0 produces a NaN ("Not a Number")

    -- Ensure that the workspace exists before attempting to modify it
    if not workspace then
        warn("Workspace is not available!")
        return
    end

    -- Set the property to NaN
    workspace.FallenPartsDestroyHeight = nan
    print("FallenPartsDestroyHeight has been set to NaN (0/0).")
    
    -- Optionally, you can print out the value to confirm,
    -- although comparisons with NaN will always return false.
    print("Current FallenPartsDestroyHeight:", workspace.FallenPartsDestroyHeight)
end

-- Execute the function to apply the change
setDestroyHeightToNaN()
