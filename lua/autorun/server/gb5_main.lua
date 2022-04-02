util.AddNetworkString( "gbombs5_cvar" )
util.AddNetworkString( "gbombs5_net" )
util.AddNetworkString( "gbombs5_romulancloak" )
util.AddNetworkString( "gbombs5_romulancloak_phys" )
util.AddNetworkString( "gbombs5_general" )
util.AddNetworkString( "gbombs5_sunbomb" )
util.AddNetworkString( "gbombs5_announcer" )
SetGlobalString ( "gb_ver", 5 )

TOTAL_BOMBS = 0
net.Receive( "gbombs5_cvar", function( len, pl ) 
	if( not pl:IsAdmin() ) then return end
	local cvar = net.ReadString();
	local val = net.ReadFloat();
	
	if not (cvar:sub(1, 4) == "gb5_") then return end
	
	if( GetConVar( tostring( cvar ) ) == nil ) then return end
	if( GetConVarNumber( tostring( cvar ) ) == tonumber( val ) ) then return end

	game.ConsoleCommand( tostring( cvar ) .." ".. tostring( val ) .."\n" );

end );

function gb5_tiberium_cleanup( ply, command, arguments )
	local crystals = 0
    if ply:IsAdmin() or ply:IsSuperAdmin() then
		for k, v in pairs(ents.GetAll()) do
			if v:GetClass()=="gb5_tiberium_crystal" then
				crystals = crystals + 1
				v:EmitSound("npc/stalker/stalker_die2.wav")
				v:Remove()
			end
		end
		ply:ChatPrint("[Admin] Removed about "..tostring(crystals).." crystals.")
	end
end
concommand.Add( "gb5_tiberium_cleanup", gb5_tiberium_cleanup )

function gb5_spawn(ply)
	ply.gasmasked=false
	ply.hazsuited=false
	net.Start( "gbombs5_net" )        
		net.WriteBit( false )
		ply:StopSound("breathing")
	net.Send(ply)
end
hook.Add( "PlayerSpawn", "gb5_spawn", gb5_spawn )
