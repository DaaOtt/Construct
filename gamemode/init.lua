AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function GM:PlayerSpawnObject(ply, model, skin)
	return true
end

function GM:PlayerLoadout(ply)
	ply:Give("weapon_physgun")
	ply:Give("gmod_tool")
	ply:Give("tool_build")

	ply:SetRunSpeed(200)
	ply:SetWalkSpeed(150)	
end

function GM:GetFallDamage(ply, speed)
	return (speed - 526.5) * (100 / 396) -- the Source SDK value
end

function GM:PlayerSpawnProp(ply, mdl)
	local prop = ents.Create("prop_physics")
	prop:SetModel(mdl)
	prop:Spawn()
	local obj = prop:GetPhysicsObject()
	if IsValid(prop) and IsValid(obj) then
		local mass = obj:GetMass()
		local size = obj:GetVolume()
		prop:Remove()
		return ply:ChargeWallet(math.sqrt(size + mass))
	else
		prop:Remove()
		return false
	end
end
function GM:PlayerSpawnedProp(ply, mdl, prop)
	prop:SetHealth(0)
	prop:SetMaxHealth(100)
	local obj = prop:GetPhysicsObject()
	if IsValid(obj) then
		print(obj:GetVolume()/500)
		prop:SetMaxHealth(obj:GetVolume()/500)
	end
	prop:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	prop:SetMaterial("models/wireframe")
end