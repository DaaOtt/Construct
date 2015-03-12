AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

CONSTRUCT = {}
CONSTRUCT.lots = {}
function GM:PlayerSpawnObject(ply, model, skin)
	return true
end

function GM:PlayerLoadout(ply)
	ply:Give("weapon_physgun")
	ply:Give("gmod_tool")
	ply:Give("tool_build")

	ply:SetRunSpeed(225)
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
		return ply:ChargeWallet(25)
	else
		prop:Remove()
		return false
	end
end

local props = {}
hook.Add("EntityRemoved", "proprefund", function(ent)
	if props[ent] then
		if IsValid(props[ent].ply) then
			props[ent].ply:ChargeWallet(-props[ent].refund + 25)
			props[ent] = nil
		end
	end
end)
function GM:PlayerSpawnedProp(ply, mdl, prop)
	prop:SetHealth(0)
	prop:SetMaxHealth(100)
	local obj = prop:GetPhysicsObject()
	if IsValid(obj) then
		local mass = obj:GetMass()
		local size = obj:GetVolume()
		prop:SetMaxHealth(size/500)
		obj:EnableMotion(false)
		props[prop] = {refund = (size / 500) - (size / 500) % 25, ply = ply}
	end
	prop:SetCollisionGroup(COLLISION_GROUP_WORLD)
	prop:SetMaterial("models/wireframe")
	prop:SetCustomCollisionCheck(true)
	prop:SetNWBool("built", false)
end

hook.Add("PlayerInitialSpawn", "salary", function(ply)
	timer.Create("salary" .. ply:EntIndex(), 300 / 2, 0, function()
		local amnt = 500
		ply:ChargeWallet(-amnt, "You received a salary of $" .. amnt .. "!", Color(0, 255, 0))
	end)
end)

function GM:CanPlayerUnfreeze()
	return false
end

local sounds = {
	"physics/metal/metal_box_strain4.wav",
	"physics/metal/metal_solid_strain5.wav",
}
hook.Add("PlayerBuild", "walletcheck", function(ply, ent)
	if not ent:GetNWBool("built") then
		ent:EmitSound(table.Random(sounds), 165, math.random(90, 110))
		return ply:ChargeWallet(25)
	end
end)

hook.Add("AdvDupe_FinishPasting", "nocolllide", function(tab)
	local ents = tab[1].CreatedEntities
	for _, ent in pairs(ents) do
		if ent:GetClass() == "prop_physics" then
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
			ent:SetMaterial("models/wireframe")
		end
	end
end)

function GM:ShowTeam(ply)
	local lot
	for l in pairs(CONSTRUCT.lots) do
		if l:Contains(ply) then
			lot = l
			break
		end
	end
	print(lot)
	if IsValid(lot) then
		net.Start("lot_menu")
			net.WriteEntity(lot:GetOwner())
			net.WriteTable(lot:GetOwners())
		net.Send(ply)
	end
end

net.Receive("lot_buy", function(len, ply)
	local lot
	for l in pairs(CONSTRUCT.lots) do
		if l:Contains(ply) then
			lot = l
			break
		end
	end
	if IsValid(lot) then
		if IsValid(lot:GetOwner()) then
			lot:SetOwner(nil)
			net.Start("lot_open")
			net.Send(ply)
		else
			lot:SetOwner(ply)
			net.Start("lot_leave")
			net.Send(ply)
		end
	end
end)
util.AddNetworkString("lot_enter")
util.AddNetworkString("lot_leave")
util.AddNetworkString("lot_menu")
util.AddNetworkString("lot_buy")