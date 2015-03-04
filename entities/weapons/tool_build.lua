AddCSLuaFile()

SWEP.PrintName = "Crowbar"
SWEP.Author			= ""
SWEP.Instructions		= "Left mouse to unleash your fury."

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 0
SWEP.SlotPos			= 0
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false

SWEP.ViewModel			= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"
SWEP.Base = "weapon_base" 
SWEP.HoldType 				=  "melee"

local sound_single = Sound("Weapon_Crowbar.Single")
local sound_hit = Sound("Weapon_Crowbar.Melee_HitWorld")
local function entvalid(trace)
	local ent = trace.Entity
	if trace.Hit then
		if trace.HitWorld then
			return true
		end
		if IsValid(ent) then
			if ent:GetClass() == "prop_physics" then
				return true
			end
		end
	end
end
local function getcorners(ent)
	local mins, maxs = ent:GetModelBounds()
	return {
		mins, --back_left_bottom
		Vector(mins[1], maxs[2], mins[3]), --back_right_bottom
		Vector(maxs[1], maxs[2], mins[3]), --front_right_bottom
		Vector(maxs[1], mins[2], mins[3]), --front_left_bottom
		Vector(mins[1], mins[2], maxs[3]), --back_left_top
		Vector(mins[1], maxs[2], maxs[3]), --back_right_top
		maxs, --front_right_top
		Vector(maxs[1], mins[2], maxs[3]), --front_left_top
	}
end
local wep
function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	wep = self
end


function SWEP:PrimaryAttack()
	self.Weapon:EmitSound(sound_single)
	self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)	
	self.Weapon:SetNextPrimaryFire(CurTime() + .5)

	
	local trace = util.TraceLine{
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 75,
		filter = self.Owner,
		mask = MASK_SHOT + CONTENTS_GRATE,
	}
	
	--local trace = self.Owner:GetEyeTrace()

	if trace.Hit then
	--if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
		self.Weapon:EmitSound(sound_hit)
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		local ent = trace.Entity
		if SERVER and ent:GetClass() == "prop_physics" and hook.Call("PlayerBuild", nil, self.Owner, ent) then
			ent:SetHealth(math.min(ent:GetMaxHealth(), ent:Health() + 25))

			if ent:Health() == ent:GetMaxHealth() and not ent:GetNWBool("built") then
				ent:SetNWBool("built", true)
				ent:SetMaterial("")
				ent:SetCollisionGroup(COLLISION_GROUP_NONE)
				local obj = ent:GetPhysicsObject()
				if IsValid(obj) then
					
					local filter = player.GetAll()
					table.insert(filter, ent)
					local traces = {}
					local corners = getcorners(ent)
					local pass = false
					for i = 1, #corners do
						for j = 1, #corners do
							local normi = Vector()
							local normj = Vector()
							normi:Set(corners[i])
							normj:Set(corners[j])
							normi:Normalize()
							normj:Normalize()
							local tr = util.TraceLine{
								start = ent:LocalToWorld(corners[i] + normi),
								endpos = ent:LocalToWorld(corners[j] + normj),
								mask = MASK_SHOT + CONTENTS_GRATE,
								filter = filter,
							}
							if entvalid(tr) then
								pass = true
								break
							end
						end
					end
					if not pass then
						obj:EnableMotion(true)
						obj:Wake()
					end
				end
			end
		end
	else
		
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end

end


function SWEP:SecondaryAttack()
end