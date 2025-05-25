local Terrain = workspace.Terrain
local Lighting = game:GetService("Lighting")

-- Usuwanie tekstur
Terrain.WaterWaveSize = 0
Terrain.WaterWaveSpeed = 0
Terrain.WaterReflectance = 0
Terrain.WaterTransparency = 0

Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9 -- Maksymalna wartość mgły
Lighting.Brightness = 0 -- Ciemność

-- Usuwanie dekoracji
for _, child in pairs(workspace:GetDescendants()) do
    if child:IsA("BasePart") and child.Name ~= "Terrain" then
        child.Material = Enum.Material.Plastic
        child.Reflectance = 0
    elseif child:IsA("Decal") or child:IsA("Texture") then
        child:Destroy()
    elseif child:IsA("ParticleEmitter") or child:IsA("Fire") or child:IsA("Smoke") then
        child.Enabled = false
    elseif child:IsA("Explosion") then
        child.Visible = false
    end
end
