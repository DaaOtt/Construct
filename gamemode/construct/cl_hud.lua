include("cs_easing.lua")

local function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery"})do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "HideHud", hidehud)

local heart = Material("icon16/heart.png")
local healthbar = {}
healthbar.h = 180
healthbar.th = 180
healthbar.ph = 180
healthbar.y = ScrH() - 64 - 24 - healthbar.h
healthbar.ratio = 0
healthbar.delta = 0
local health = {}
health.x = 0
health.tx = 0
health.px = 0
health.ratio = 0

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

	local px = health.tx
	if LocalPlayer():Health() >= 100 then
		health.tx = -65
	else
		health.tx = 0
	end
	if px ~= health.tx then
		if px < health.tx then
			health.ratio = 1
		elseif px > health.tx then
			health.ratio = 0
		end
		health.px = px
	end
end
hook.Add("Tick", "UpdateHealth", updatehealth)

local function drawhud()
	healthbar.ratio = math.min(1, healthbar.ratio + FrameTime() * 2)
	healthbar.h = healthbar.ph + easing.easeOutBounce(healthbar.ratio, 1, 0, 1) * healthbar.delta

	local healthchange = FrameTime() * 2
	if health.px == -65 then
		healthchange = FrameTime() * -2
	end
	health.ratio = math.max(0, math.min(1, health.ratio + healthchange))
	health.x = easing.easeInBack(health.ratio, 1, 0, 1) * (health.tx + health.px)

	surface.SetDrawColor(Color(0, 0, 0, 128))
	surface.DrawRect(health.x, ScrH() - 64 - 256, 64, 256)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.DrawRect(28 + health.x, healthbar.y, 8, healthbar.h)
	surface.SetMaterial(heart)
	surface.DrawTexturedRect(24 + health.x, ScrH() - 64 - 256 + 24, 16, 16)
end
hook.Add("HUDPaint", "DrawHud", drawhud)