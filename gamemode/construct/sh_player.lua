local meta = FindMetaTable("Player")
if not meta then
	print("player not valid or something")
	return
end

function meta:GetWallet()
	return self:GetNWInt("wallet")
end
function meta:SetWallet(a)
	if SERVER then
		self:SetNWInt("wallet", a)
		return true
	end
end
function meta:ChargeWallet(a)
	if SERVER then
		a = tonumber(a)
		local m = tonumber(self:GetNWInt("wallet"))
		if m - a < 0 then return false end
		m = math.floor(m - a)
		self:SetNWInt("wallet", m)
		return true
	end
end

if SERVER then
	util.AddNetworkString("notify")
end
function meta:Notify(text, enum, length, sound)
	if CLIENT then
		notification.AddLegacy(text, _G[enum], length)
		if sound and sound ~= "" then
			surface.PlaySound(sound)
		end
	elseif SERVER then
		net.Start("notify")
			net.WriteString(text)
			net.WriteString(enum)
			net.WriteUInt(length, 8)
			net.WriteString(sound or "")
		net.Send(self)
	end
end
if CLIENT then
	net.Receive("notify", function()
		LocalPlayer():Notify(net.ReadString(), net.ReadString(), net.ReadUInt(8), net.ReadString())
	end)
end