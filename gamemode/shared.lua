GM.Name = "Construct"
GM.Author = "Ott"
GM.Email = "N/A"
GM.Website = "https://github.com/DaaOtt/Construct"
DeriveGamemode("sandbox")

print("Loading files...")
local files, folders = file.Find("construct/gamemode/construct/*", "LUA")
local function load(s)
	print("\tLoaded file " .. s)
	include(s)
end
for k, v in pairs(files) do
	if string.sub(v, -4) == ".lua" then
		if string.sub(v, 1, 3) == "sv_" and SERVER then
			load("construct/" .. v)
		end
		if string.sub(v, 1, 3) == "cl_" and CLIENT then
			load("construct/" .. v)
		end
		if string.sub(v, 1, 3) == "cl_" and SERVER then
			print("\tSent construct/" .. v .. " to clients")
			AddCSLuaFile("construct/" .. v)
		end
		if string.sub(v, 1, 3) == "sh_" then
			if SERVER then
				print("\tSent construct/" .. v .. " to clients")
				AddCSLuaFile("construct/" .. v)
			end
			load("construct/" .. v)
		end
		if string.sub(v, 1, 3) == "cs_" then
			if SERVER then
				print("\tSent construct/" .. v .. " to clients")
				AddCSLuaFile("construct/" .. v)
			end
		end
	end
end

function GM:PlayerNoClip(ply, s)
	if s then
		return ply:IsAdmin()
	else 
		return true
	end
end

function GM:FinishMove()
end

local function drop(ply, ent)
	local obj = ent:GetPhysicsObject()
	if IsValid(obj) then
		obj:EnableMotion(false)
	end
end
hook.Add("PhysgunDrop", "DropFreeze", drop)

local function grab(ply, ent)
	if ent:GetNWBool("built") then
		return false
	end
end
hook.Add("PhysgunPickup", "PickupDisable", grab)


hook.Add("ShouldCollide", "push", function(ent1, ent2)
	local c1, c2 = ent1:GetCollisionGroup(), ent2:GetCollisionGroup()
	local prop, ply
	if c1 == COLLISION_GROUP_PUSHAWAY and c2 == COLLISION_GROUP_PUSHAWAY then
		return false
	end
	if c1 ~= COLLISION_GROUP_PUSHAWAY and c2 ~= COLLISION_GROUP_PUSHAWAY then
		return true
	end
	if c1 then
		prop = ent1
		ply = ent2
	elseif c2 then
		prop = ent2
		ply = ent1
	end
	if not ply:IsPlayer() then return false end
	if not ply:Alive() then return false end
	local tr = util.TraceHull{
		start = ply:GetPos(),
		endpos = ply:GetPos(),
		mins = Vector(-24, -24, -8),
		maxs = Vector(24, 24, 80),
		filter = {ply},
		ignoreworld = true,
	}
	if tr.Hit and tr.Entity == prop then
		return false
	end
end)
hook.Add("SetupMove", "push", function(ply, mv, cmd)
	local tr = util.TraceHull{
		start = ply:GetPos(),
		endpos = ply:GetPos(),
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 72),
		filter = ply,
		ignoreworld = true,
	}
	if tr.Hit and tr.Entity and tr.Entity:GetCollisionGroup() == COLLISION_GROUP_PUSHAWAY then
		local prop = tr.Entity
		local velvec = ply:GetPos() - prop:WorldSpaceCenter()
		velvec.z = 0
		velvec:Normalize()
		mv:SetVelocity(mv:GetVelocity() + velvec * 5)
	end
end)