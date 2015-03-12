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

local money = 0

local function updatehealth()
	if not IsValid(LocalPlayer()) then return end
	money = LocalPlayer():GetWallet()

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

local function drawhealth()
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
hook.Add("HUDPaint", "DrawHealth", drawhealth)


surface.CreateFont("Wallet", {
	font = "Courier",
	size = 24,

})
local function drawwallet()
	surface.SetFont("Wallet")
	local text = "$" .. money
	local w, h = surface.GetTextSize(text)
	local width = math.ceil((w + 32) / 64) * 64

	surface.SetDrawColor(Color(0, 0, 0, 128))
	surface.DrawRect(ScrW() - 64 - width, 0, width, 64)

	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(ScrW() - 64 - width / 2 - w / 2, 32 - h / 2)
	surface.DrawText(text)
end
hook.Add("HUDPaint", "DrawWallet", drawwallet)

local lotmsg
net.Receive("lot_enter", function()
	local owner = net.ReadEntity()
	if owner:IsPlayer() then
		lotmsg = notification.Add("Lot owned by: " .. owner:Nick(), Color(0, 0, 0), 5)
	else
		lotmsg = notification.Add("This lot is available! Press F2 for more options.", Color(0, 255, 0))
	end
end)
net.Receive("lot_leave", function()
	notification.Dismiss(lotmsg)
end)