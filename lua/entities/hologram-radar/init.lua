AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SetInitialValues()
    self:SetSmallViewRadius( 30 )
    self:SetFullViewRadius( 200 )
end

function ENT:Initialize()
    self:SetModel( "models/props_combine/combine_mine01.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end

    self:SetInitialValues()
end

function ENT:OnReloaded()
    self:SetInitialValues()
end

function ENT:OnSmallViewRadiusChanged( name, old, new )
end

function ENT:OnFullViewRadiusChanged( name, old, new )
end

