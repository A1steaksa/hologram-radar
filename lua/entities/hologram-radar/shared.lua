ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Hologram Radar"
ENT.Author = "A1steaksa"
ENT.Category = "A1's Entities"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- This block is to convince Lua Language Server that the functions exist
if false then
    function ENT:GetSmallViewRadius() return 0 end
    function ENT:SetSmallViewRadius( radius ) end

    function ENT:GetFullViewRadius() return 0 end
    function ENT:SetFullViewRadius( radius ) end
end

function ENT:SetupDataTables()
    self:NetworkVar( "Float", 1, "SmallViewRadius" )
    self:NetworkVar( "Float", 2, "FullViewRadius" )

    self:NetworkVarNotify( "SmallViewRadius", self.OnSmallViewRadiusChanged )
    self:NetworkVarNotify( "FullViewRadius", self.OnFullViewRadiusChanged )
end

