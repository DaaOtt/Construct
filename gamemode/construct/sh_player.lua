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
		if a > m then return false end
		m = math.floor(m - a)
		self:SetNWInt("wallet", m)
		return true
	end
end