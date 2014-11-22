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
SWEP.SlotPos			= 3
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
function SWEP:Initialize()
    self:SetWeaponHoldType( self.HoldType )
end


function SWEP:PrimaryAttack()
	self.Weapon:EmitSound(sound_single)
	self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)	
	self.Weapon:SetNextPrimaryFire(CurTime() + .5)

	
	local trace = util.TraceLine{
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 75,
		filter = self.Owner,
		mask = MASK_SOLID,
	}
	
	--local trace = self.Owner:GetEyeTrace()

	if trace.Hit then
	--if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
		self.Weapon:EmitSound(sound_hit)
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		if SERVER and trace.Entity:GetClass() == "prop_physics" then
			trace.Entity:SetHealth(math.min(trace.Entity:GetMaxHealth(), trace.Entity:Health() + 25))

			if trace.Entity:Health() == trace.Entity:GetMaxHealth() then
				trace.Entity:SetMaterial("")
				trace.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
			end
		end
	else
		
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end

end


function SWEP:SecondaryAttack()
end

--[[
AddCSLuaFile()

SWEP.HoldType			= "melee"

if CLIENT then
	SWEP.PrintName			= "Crowbar"
	SWEP.Slot				= 0
	SWEP.ViewModelFOV = 54
end

SWEP.UseHands			= true
--SWEP.Base				= "weapon_tttbase"
SWEP.ViewModel			= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"
SWEP.Weight			= 5
SWEP.DrawCrosshair		= false
SWEP.ViewModelFlip		= false
SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay = 0.5
SWEP.Primary.Ammo		= "none"
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.Delay = 5

SWEP.Kind = WEAPON_MELEE
SWEP.WeaponID = AMMO_CROWBAR


SWEP.NoSights = true
SWEP.IsSilent = true

SWEP.AutoSpawnable = false

SWEP.AllowDelete = false -- never removed for weapon reduction
SWEP.AllowDrop = false

local sound_single = Sound("Weapon_Crowbar.Single")
local sound_open = Sound("DoorHandles.Unlocked3")

if SERVER then
	CreateConVar("ttt_crowbar_unlocks", "1", FCVAR_ARCHIVE)
	CreateConVar("ttt_crowbar_pushforce", "395", FCVAR_NOTIFY)
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if not IsValid(self.Owner) then return end

	local spos = self.Owner:GetShootPos()
	local sdest = spos + (self.Owner:GetAimVector() * 70)

	local tr_main = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
	local hitEnt = tr_main.Entity

	self.Weapon:EmitSound(sound_single)

	if IsValid(hitEnt) or tr_main.HitWorld then
		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

		if not (CLIENT and (not IsFirstTimePredicted())) then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(tr_main.Normal)
			edata:SetEntity(hitEnt)
			util.Effect("Impact", edata)
		end
	else
		self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
	end
end

function SWEP:SecondaryAttack()
	return true
end

function SWEP:OnDrop()
	self:Remove()
end
--]]