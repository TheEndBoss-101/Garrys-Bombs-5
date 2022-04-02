AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  ""        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ENT.GBOWNER                          =  nil            
ENT.MAX_RANGE                        = 0
ENT.SHOCKWAVE_INCREMENT              = 0
ENT.DELAY                            = 0

function ENT:Initialize()
     if (SERVER) then
        self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		
		self:SetUseType( ONOFF_USE ) -- doesen't fucking work
		
		local phys = self:GetPhysicsObject()
		 if (phys:IsValid()) then
			 phys:SetMass(55555)
			 phys:Wake()
			 phys:EnableGravity( false )
		 end 
		 self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
		 
		 self.Bursts = 0
		 self.CURRENTRANGE = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
		 
		 local pos = self:GetPos()
		 self.PULLPLY = 0
		 self.PULLPROP = 0
     	 self.EventHorizon = 1
		 

     end
end
function ENT:Think()
     if (SERVER) then
     if not self:IsValid() then return end
	 local pos = self:GetPos()
	 self.CURRENTRANGE = self.CURRENTRANGE+self.SHOCKWAVE_INCREMENT
	 
	 for k, v in pairs(ents.FindInSphere(pos,self.CURRENTRANGE)) do
		 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
			 local i = 0
			 while i < v:GetPhysicsObjectCount() do
				 phys = v:GetPhysicsObjectNum(i)
				 if (phys:IsValid() and v~=self) then
					 local mass = phys:GetMass()
					 local F_ang = self.PULLPROP
					 local dist = (pos - v:GetPos()):Length()
					 local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
					 local F_dir = (v:GetPos() - pos):GetNormal() * self.PULLPROP
					 phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
					 phys:AddVelocity(F_dir)
				 end
				 if (v:IsPlayer()) then
					 v:SetMoveType( MOVETYPE_WALK )
					 local mass = phys:GetMass()
					 local F_ang = self.PULLPLY
					 local dist = (pos - v:GetPos()):Length()
					 local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
					 local F_dir = (v:GetPos() - pos):GetNormal() * self.PULLPLY	 
					 v:SetVelocity( F_dir )		
				 end
			 i = i + 1
			 end
		 end
 	 end
	 for k, v in pairs(ents.FindInSphere(pos,self.EventHorizon)) do
		 if v:IsValid() or v:IsPlayer() then
			 local i = 0
			 while i < v:GetPhysicsObjectCount() do
				 phys = v:GetPhysicsObjectNum(i)
				 if (phys:IsValid() and not v:IsPlayer() and v:GetClass()~=self:GetClass()) then
					v:Remove()
				 end
				 if (v:IsPlayer()) or (v:IsNPC()) then
					 local dmg = DamageInfo()
			         dmg:SetDamage(math.random(100))
			         dmg:SetDamageType(DMG_RADIATION)
			         dmg:SetAttacker(self.GBOWNER)
					 v:TakeDamageInfo(dmg)
				 end
			 i = i + 1
			 end
		 end
 	 end
	 self.PULLPLY = self.PULLPLY-25
     self.PULLPROP = self.PULLPROP-2
	 self.Bursts = self.Bursts + 1
	 self.EventHorizon = self.EventHorizon + 2
	 if (self.CURRENTRANGE >= self.MAX_RANGE) then
	     self:Remove()
	 end
	 self:NextThink(CurTime() + self.DELAY)
	 return true
	 end
end
	

function ENT:Draw()
	self:DrawModel()
     return true
end