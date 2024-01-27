local plyCoords = GetEntityCoords(PlayerPedId())
local sid = GetPlayerServerId(PlayerId())
local proximity = 3.0

-------------------------------------------------------------------
---- FUNCTIONS
-------------------------------------------------------------------

local function ProximityCheck(ply)
	local tgtPed = GetPlayerPed(ply)
	local distance = proximity * 5
	return #(plyCoords - GetEntityCoords(tgtPed)) < distance
end

local function GetNearbyPlayers()
	plyCoords = GetEntityCoords(PlayerPedId())
	MumbleClearVoiceTargetChannels(1)
	MumbleAddVoiceChannelListen(sid)
	local players = GetActivePlayers()
	for i = 1, #players do
		local ply = players[i]
		if ProximityCheck(ply) then
			local serverId = GetPlayerServerId(ply)
			MumbleAddVoiceTargetChannel(1, serverId)
		end
	end
end

local function handleInitialState()
	MumbleSetTalkerProximity(proximity)
	MumbleClearVoiceTarget(1)
	MumbleSetVoiceTarget(1)
	MumbleSetVoiceChannel(sid)
	while MumbleGetVoiceChannelFromServerId(sid) ~= sid do
		Wait(250)
		MumbleSetVoiceChannel(sid)
	end
	print('Mumble Audio: Initalized')
	GetNearbyPlayers()
end

-------------------------------------------------------------------
---- HANDLER & COMMANDS
-------------------------------------------------------------------

AddEventHandler('mumbleConnected', handleInitialState)

RegisterCommand("fixvoice", handleInitialState)

RegisterCommand('cycleproximity', function()
	local newvoice = proximity <= 3.0 and proximity * 2 or 1.5
	proximity = newvoice
	MumbleSetTalkerProximity(newvoice)
end, false)

-------------------------------------------------------------------
---- THREADS
-------------------------------------------------------------------

CreateThread(function()
	while not MumbleIsConnected() do Wait(1000) end
	while true do
		GetNearbyPlayers()
		Wait(500)
	end
end)
