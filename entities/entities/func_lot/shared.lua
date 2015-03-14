ENT.Type = "brush"
function ENT:Initialize()
	self.ents = {}
	self.owners = {}
	CONSTRUCT.lots[self] = true
end
function ENT:StartTouch(ent)
	print("in", ent, self)
	self.ents[ent] = true
	if ent:IsPlayer() then
		if ent:Alive() then
			if not IsValid(self:GetOwner()) then
				net.Start("lot_enter")
				net.Send(ent)
			else
				net.Start("lot_enter")
					net.WriteEntity(self:GetOwner())
				net.Send(ent)
			end
		end
	elseif ent:GetClass() == "prop_physics" then
		if ent:GetNWEntity("owner", Entity(0)):IsPlayer() then
			if not self:IsOwner(ent:GetNWEntity("owner")) then
				ent:Remove()
				ent:GetNWEntity("owner"):Notify("Your props aren't allowed here!", Color(255, 0, 0), 5)
				ent.removed = true
			end
		end
	end
end
function ENT:EndTouch(ent)
	print("out", ent, self)
	self.ents[ent] = nil
	if ent:IsPlayer() then
		net.Start("lot_leave")
		net.Send(ent)
	elseif ent:GetClass() == "prop_physics" and not ent.removed then
		if ent:GetNWEntity("owner", Entity(0)):IsPlayer() then
			ent:Remove()
			ent:GetNWEntity("owner"):Notify("Your prop was removed because it exited the lot!", Color(255, 0, 0), 5)
		end
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
function ENT:ClearOwners()
	self.owners = {}
end
function ENT:IsOwner(a)
	return self.owners[a] or a == self:GetOwner()
end
function ENT:GetOwners()
	local tab = {}
	for o in pairs(self.owners) do
		tab[#tab + 1] = o
	end
	return tab
end