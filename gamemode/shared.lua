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