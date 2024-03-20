local col = Color(0, 0, 0, 0)

hook.Add("PostDrawTranslucentRenderables", "fog", function()
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.SetStencilReferenceValue(0)

    render.SetStencilCompareFunction(STENCIL_ALWAYS)

    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()

    render.SetColorMaterial()

    local targets = ents.FindByClass("npc_hunter")

    if #targets == 0 then
        return
    end

    render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilZFailOperation(STENCIL_REPLACE)

        for _, v in pairs(targets) do
            render.DrawSphere(v:GetPos(), -200, 50, 50, col)
        end

        render.SetStencilCompareFunction(STENCIL_EQUAL)

        render.SetStencilPassOperation(STENCIL_INCR)
        render.SetStencilZFailOperation(STENCIL_KEEP)

        for _, v in pairs(targets) do
            render.DrawSphere(v:GetPos(), 200, 50, 50, col)
        end

        render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
        render.SetStencilReferenceValue(2)

        cam.Start2D()
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        cam.End2D()
    render.SetStencilEnable(false)
end)