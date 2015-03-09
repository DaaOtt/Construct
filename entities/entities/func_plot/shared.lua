ENT.Type = "brush"
function ENT:Initialize()
	self.ents = {}
	self.owners = {}
end
function ENT:StartTouch(ent)
	print("in", ent, self)
	self.ents[ent] = true
	if ent:IsPlayer() and ent:Alive() then
		if not IsValid(self:GetOwner()) then
			net.Start("lot_open")
			net.Send(ent)
		end
	end
end
function ENT:EndTouch(ent)
	print("out", ent, self)
	self.ents[ent] = false
	if ent:IsPlayer() then
		net.Start("lot_leave")
		net.Send(ent)
	end
end
function ENT:Contains(a)
	return self.ents[a]
end

function ENT:AddOwner(a)
	self.owners[a] = true
end
function ENT:RemoveOwner(a)
	self.owners[a] = nil
end
function ENT:IsOwner(a)
	return self.owners[a]
end