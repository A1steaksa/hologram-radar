include("shared.lua")
local prefix = "hologram-radar-"

local MATERIAL_COLOR = Material( "color" )

local renderTarget = GetRenderTarget( prefix .. "RenderTarget", ScrW(), ScrH() )
local renderTargetMaterial = CreateMaterial( 
    prefix .. "RenderTargetMaterial",
    "UnlitGeneric",
    {
	    ["$basetexture"] = renderTarget:GetName(),
        ["$translucent"] = "1",
    } 
)

function ENT:Initialize()
    hook.Add( "RenderScene", self, self.DrawFullViewToRenderTarget )
end

---@return Vector pos The location we are currently viewing, which is a location in the world
function ENT:GetFullViewPos()
    return Vector( 0, 45, 100 )
end

---@return Vector pos The location of the Full View camera relative to the Full View position
function ENT:GetFullViewCameraPos()
    local smallToFullScalar = self:GetFullViewRadius() / self:GetSmallViewRadius()

    local cameraPosRelativeToSelf = EyePos() - self:GetSmallViewPos()
    
    return self:GetFullViewPos() + ( cameraPosRelativeToSelf * smallToFullScalar )
end

function ENT:GetFullViewCameraAngle()
    return EyeAngles()
end

---@return Vector pos The location where this Entity is displaying the scaled-down Small View of the Full View position
function ENT:GetSmallViewPos()
    return self:GetPos() + self:GetUp() * 35
end

function ENT:DrawFullViewSphere()
    render.DrawSphere( self:GetFullViewPos(), self:GetFullViewRadius(), 20, 20, Color( 0, 100, 200, 100 )  )
end

function ENT:DrawSmallViewSphere()
    render.DrawSphere( self:GetSmallViewPos(), self:GetSmallViewRadius(), 20, 20, Color( 0, 200, 100, 100 )  )
end

function ENT:GetFullViewNearClippingPlaneDistance()
    return self:GetFullViewCameraPos():Distance( self:GetFullViewPos() ) - self:GetFullViewRadius()
end

function ENT:GetFullViewFarClippingPlaneDistance()

end

function ENT:DrawFullViewToRenderTarget()

    if not self.GetFullViewCameraPos or not self.GetFullViewCameraAngle then return end

    render.PushRenderTarget( renderTarget )
    --render.Clear( 255, 255, 255, 255 )
    render.SetWriteDepthToDestAlpha( false )
    render.RenderView( {
        x = 0,
        y = 0,
        origin = self:GetFullViewCameraPos(),
        angles = self:GetFullViewCameraAngle(),
        drawhud = false,
        drawviewmodel = false,
        --znear = self:GetFullViewNearClippingPlaneDistance()
    } )
    render.SetWriteDepthToDestAlpha( true )
    render.PopRenderTarget()
end

function ENT:DebugVisualize()

    render.SetMaterial( MATERIAL_COLOR )

    -- Visualize the Small View sphere
    self:DrawSmallViewSphere()

    -- Visualize the Full View sphere
    self:DrawFullViewSphere()
    
    -- Visualize the location we're tracking
    render.DrawSphere( self:GetFullViewPos(), 10, 5, 5, Color( 0, 100, 200 ) )

    -- Visualize the Full View camera
    render.DrawWireframeBox( self:GetFullViewCameraPos(), self:GetFullViewCameraAngle(), Vector( -1, -1, -1 ) * 10, Vector( 1, 1, 1 ) * 10, Color( 255, 255, 255, 255 ) )

    -- Visualize the Full View camera's direction
    render.DrawBeam( self:GetFullViewCameraPos(), self:GetFullViewCameraPos() + self:GetFullViewCameraAngle():Forward() * 10000, 3, 0, 1, Color( 255, 255, 255, 255 ) )

    -- Visualize the near cliping plane
    render.DrawQuadEasy( self:GetFullViewCameraPos() + self:GetFullViewCameraAngle():Forward() * self:GetFullViewNearClippingPlaneDistance(), self:GetFullViewCameraAngle():Forward(), 300, 300, Color( 100, 100, 100, 100 ), 0 )
end

function ENT:DrawScaledView()

    render.SetMaterial( MATERIAL_COLOR )

    render.SetStencilEnable( true )
    render.SetStencilTestMask( 255 )
    render.SetStencilWriteMask( 255 )
    render.SetStencilPassOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation( STENCIL_KEEP )

    render.SetStencilFailOperation( STENCIL_REPLACE )
    render.SetStencilCompareFunction( STENCIL_NEVER )
    render.SetStencilReferenceValue( 1 )

    -- Mask with the small view sphere
    self:DrawSmallViewSphere()
    
    render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilCompareFunction( STENCIL_EQUAL )

    cam.Start2D()
    surface.SetDrawColor( Color( 100, 0, 0 ) )
    surface.DrawRect( 0, 0, ScrW(), ScrH() )

    surface.SetMaterial( renderTargetMaterial )
    surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
    cam.End2D()
    
    render.SetStencilEnable( false )

    
end

function ENT:Draw()
    self:DrawModel()
    self:DrawScaledView()
end

function ENT:OnSmallViewRadiusChanged( name, old, new )
end

function ENT:OnFullViewRadiusChanged( name, old, new )
end

hook.Add( "PostDrawTranslucentRenderables", prefix .. "DrawRadar", function()
    if render.GetRenderTarget() ~= nil then
        for _, radar in ipairs( ents.FindByClass( "hologram-radar" ) ) do
            radar:DebugVisualize()
        end
    end
end )
