local meta = FindMetaTable("Player")
if not IsValid(meta) then return end

function meta:GetWallet()
	return self:GetNWInt("money")
end
function meta:SetWallet(a)
	if SERVER then
		self:SetNWInt("money", a)
		return true
	end
end
function meta:ChargeWallet(a)
	if SERVER then
		local m = self:GetNWInt("money")
		if a > m then return false end
		m = m - a
		self:SetNWInt("money", m)
	end
end