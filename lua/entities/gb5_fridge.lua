AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  true       
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Fridge"
ENT.Author			                 =  "natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Vehicles"

ENT.Model                            =  "models/rogue/tibe.mdl"           
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""   
ENT.EffectWater                      =  "" 
ENT.ExplosionSound                   =  ""                   
ENT.ParticleTrail                    =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false      
ENT.ShouldExplodeOnImpact            =  false         
ENT.Flamable                         =  false        
ENT.UseRandomSounds                  =  false       
ENT.UseRandomModels                  =  false

ENT.ExplosionDamage                  =  1          
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  3           
ENT.SpecialRadius                    =  4            
ENT.MaxIgnitionTime                  =  1           
ENT.Life                             =  300        
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  0        
ENT.ImpactSpeed                      =  0           
ENT.Mass                             =  100
ENT.Shocktime                        = 1
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:ExploSound(pos)
     if not self.Exploded then return end
	 if self.UseRandomSounds then
         sound.Play(table.Random(ExploSnds), pos, 160, 130,1)
     else
	     sound.Play(self.ExplosionSound, pos, 160, 130,1)
	 end
end

function ENT:SpawnFunction( ply, tr )
     if ( not tr.Hit ) then return end
		 
	local ent = ents.Create("prop_vehicle_prisoner_pod") 
	ent:SetModel("models/vehicles/prisoner_pod_inner.mdl") 
	ent:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")
	ent:SetPos(tr.HitPos) 
	ent:Spawn()
	ent:Activate()
	
	local ent2 = ents.Create("prop_physics") 
	ent2:SetModel("models/props_c17/furniturefridge001a.mdl") 
	ent2:SetPos(ent:GetPos()+Vector(-10,0,50)) 
	ent2:Spawn()
	ent2:Activate()
	
	ent2:SetParent(ent)
	ent2:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	ent:SetNoDraw(true)
	
	 		 	 
     return ent
end
