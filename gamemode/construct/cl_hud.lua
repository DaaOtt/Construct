include("cs_easing.lua")

local function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery"})do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "HideHud", hidehud)

local heart = Material("icon16/heart.png")
local healthbar = {}
healthbar.w = 8
healthbar.h = 180
healthbar.th = 180
healthbar.ph = 180
healthbar.x = 28
healthbar.y = ScrH() - 64 - 24 - healthbar.h
healthbar.ratio = 0
healthbar.delta = 0

local function updatehealth()
	if not IsValid(LocalPlayer()) then return end
	local ph = healthbar.th
	healthbar.th = LocalPlayer():Health() / 100 * 180
	healthbar.y = ScrH() - 64 - 24 - healthbar.h
	if ph ~= healthbar.th then
		healthbar.ph = ph
		healthbar.ratio = 0
		healthbar.delta = healthbar.th - healthbar.ph
	end
end
hook.Add("Tick", "UpdateHealth", updatehealth)

local function drawhud()
	healthbar.ratio = math.min(1, healthbar.ratio + FrameTime() * 2)
	healthbar.h = healthbar.ph + easing.easeOutBounce(healthbar.ratio, 1, 0, 1) * healthbar.delta

	surface.SetDrawColor(Color(0, 0, 0, 128))
	surface.DrawRect(0, ScrH() - 64 - 256, 64, 256)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawRect(healthbar.x, healthbar.y, healthbar.w, healthbar.h)
	surface.SetMaterial(heart)
	surface.DrawTexturedRect(24, ScrH() - 64 - 256 + 24, 16, 16)
end
hook.Add("HUDPaint", "DrawHud", drawhud)