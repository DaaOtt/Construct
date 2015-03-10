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


surface.CreateFont("LotOpen", {
	font = "Roboto",
	size = 18,
	weight = 200,
})
local up = -32
local goingup = false
local goingdown = false
local delta = 0
local color = Color(0, 255, 0, 128)
local text = "This lot is available! Press F2 for options."
hook.Add("HUDPaint", "LotOpen", function()
	local w, h = ScrW(), ScrH()
	surface.SetDrawColor(color)
	surface.DrawRect(w - 300, h - 32 - up, 300, 32 + 16)
	draw.DrawText(text, "LotOpen", w - 150, h - 24 - up, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end)
hook.Add("Think", "LotOpen", function()
	if goingup then
		if up >= 0 then
			up = 0
			delta = 0
			goingup = false
		else
			delta = delta + FrameTime()
			up = easing.easeOut(delta, 1, 0, 1) * 32 * 2 - 32
		end
	elseif goingdown then
		if up <= -32 then
			delta = 0
			up = -32
			goingdown = false
		else
			delta = delta + FrameTime()
			up = -easing.easeIn(delta, 1, 0, 1) * 32 * 2
		end
	end
end)
net.Receive("lot_enter", function()
	local ply = net.ReadEntity()
	if ply:IsPlayer() then
		color = Color(0, 0, 0, 128)
		text = "Lot owner: " .. ply:Nick()
		timer.Simple(3, function()
			goingup = false
			goingdown = true
		end)
	else
		color = Color(0, 255, 0, 128)
		text = "This lot is available! Press F2 for options."
	end
	goingup = true
	goingdown = false
end)
net.Receive("lot_leave", function()
	goingdown = true
	goingup = false
end)