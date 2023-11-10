local AccumName = "james-rail-accumulator"
local HiddenPoleName = "james-rail-pole"

local function CheckTableValue(Value,Table)
	for i, v in pairs(Table) do
		if Value == v then
			return true
		end
	end
	return false
end

--Initialization Function
local function OnInit()
	global.JamesElectricTrains = { }
	global.JETrainsUpdate = { }
	global.JECounter = 0
end


--Arbiter function for if we should *ever* handle a train, is passed a locomotive
local function ValidLocomotive(Locomotive)
	if Locomotive.name:find("ret", 1, true) then
		return true
	elseif Locomotive.name:find("hybrid", 1, true) then
		return true
	elseif Locomotive.name:find("electric", 1, true) then
		return true
	end
	return false
end

--Arbiter function for if we should handle a train in the moment, is passed a locomotive
local function LocomotiveIsElectricNow(Locomotive)
	if locomotive.burner.currently_burning == "electric-burner-item" then --The train is handled if it's already burning our dummy item
		return true
	elseif locomotive.burner.currently_burning == nil then --The train is handled if it's burning nothing
		return true
	end
	return false
end

local function WagonIsElectric(Wagon)
	if Wagon.name:find("electric-cargo", 1, true) or Wagon.name:find("electric-fluid", 1, true) then --The train is handled if it's already burning our dummy item
		return true
	end
	return false
end

--When powered rails are built/removed

--Takes a rail, makes and connects sub-poles
local function SetupCableConnections(entity)
	
	for i, neighbour in pairs() do
		local NeighbourPole = GetHiddenPole(position)
		local ConnectRed = { defines.wire_type.red, hiddenPole }
		local ConnectGreen = { defines.wire_type.green, hiddenPole }
		neighbour.connect_neighbour(hiddenPole)
		neighbour.connect_neighbour(ConnectRed)
		neighbour.connect_neighbour(ConnectGreen)
	end
end

local function MakeHiddenPole(entity)
	if surface and surface.valid then
		surface.create_entity{name = HiddenPoleName, position = entity.position, raise_built = false}
		local hiddenPole = surface.find_entity(HiddenPoleName, entity.position)
		hiddenPole.disconnect_neighbour()
	end
end


local function MakeHiddenAccum(surface, position)
	if surface and surface.valid then
		create_entity{name = AccumName, position = position, raise_built = false}
	end
end
local function removeHiddenPowerEntities(surface, position)
	if surface and surface.valid then
		for i, accumulator in pairs(surface.find_entities_filtered{name = AccumName, position = position}) do
			accumulator.destroy()
		end
		for i, pole in pairs(surface.find_entities_filtered{name = HiddenPoleName, position = position}) do
			pole.destroy()
		end
	end
end

local function on_new_entity(event)
	local entity = event.created_entity or event.entity --Handle multiple event types
	if not entity then return end
	local surface = entity.surface
	local position = entity.position
	local force = entity.force
	if entity.name == "james-powered-rail" or entity.name == "james-powered-rail-curved" then
		MakeHiddenAccum(surface, position)
		MakeHiddenPole(entity)
		SetupCableConnections(entity)
	elseif ValidLocomotive(entity) and entity.train and CheckTableValue(entity.train,global.JamesElectricTrains) == false then
		table.insert(global.JamesElectricTrains, entity.train)
	elseif WagonIsElectric and entity.train and CheckTableValue(entity.train,global.JamesElectricTrains) == false then
		table.insert(global.JamesElectricTrains, entity.train)
	end
end
local function on_remove_entity(event)
	local entity = event.created_entity or event.entity --Handle multiple event types
	if not entity then return end
	local surface = entity.surface
	local position = entity.position
	local force = entity.force
	if entity.name == "james-powered-rail" or entity.name == "james-powered-rail-curved" then
		removeHiddenPowerEntities(surface, position)
	end
end

--Every so often go through our train list to power them
local function PowerTrain(Train)
	local PowerNeeded = 0 --Single Value of power required by the train
	local Accumulators = { } --Array of all accumulators available to this train
	local AvailablePower = 0
	local LocoPowerNeeded = 0
	local LocomotiveCount = 0
	
	for i, locomotive in pairs(Train.locomotives) do
		if LocomotiveIsElectricNow(locomotive) then
			PowerNeeded = PowerNeeded + (game.entity_prototype[wagon.name].weight)
			LocoPowerNeeded = LocoPowerNeeded + locomotive.burner.currently_burning.fuel_value - locomotive.burner.remaining_burning_fuel
			LocomotiveCount = LocomotiveCount + 1
		end
	end
	--[[for i, wagon in pairs(Train.cargo_wagons) do
		if WagonIsElectric then
			PowerNeeded = PowerNeeded + (game.entity_prototype[wagon.name].weight)
		end
	end
	for i, wagon in pairs(Train.fluid_wagons) do
		if WagonIsElectric then
			PowerNeeded = PowerNeeded + (game.entity_prototype[wagon.name].weight)
		end
	end]]
	for i, rail in pairs(Train.get_rails) do
		local Accumulator = surface.find_entity(AccumName, entity.position)
		AvailablePower = AvailablePower + Accumulator.energy
		table.insert(Accumulators, Accumulator)
	end
	local PowerTransfer = 0
	local LocoPowerTransfer = LocoPowerNeeded
	if PowerNeeded > AvailablePower then
		PowerTransfer = PowerNeeded
		PowerTransfer = PowerTransfer - AvailablePower
		LocoPowerTransfer = LocoPowerTransfer - PowerTransfer
		PowerTransfer = AvailablePower
	else
		PowerTransfer = PowerNeeded
	end
	local AccumulatorDraw = PowerTransfer/#Accumulators
	for i, Accumulator in pairs(Accumulators) do
		Accumulator.energy = Accumulator.enery - AccumulatorDraw
	end
	for i, locomotive in pairs(Train.locomotives) do
		if LocomotiveIsElectricNow(locomotive) then
			locomotive.burner.currently_burning = "electric-burner-item"
			locomotive.burner.remaining_burning_fuel = locomotive.burner.remaining_burning_fuel + LocoPowerTransfer
		end
	end
	
	if LocoPowerTransfer < 1 then --If the train didn't get a lot of power, make it get updated again soon
		table.insert(global.JETrainsUpdate, 1, train)
	end
end

local function RemakeTrainUpdateList()
	for i, train in pairs(global.JamesElectricTrains) do
		table.insert(global.JETrainsUpdate, train)
	end
end

local function UpdateTrains()
	if global.JETrainsUpdate[1] ~= nil and global.JETrainsUpdate[1].valid  then
		PowerTrain(table.remove(global.JETrainsUpdate, 1))
	else
	
	end
end

script.on_event(defines.events.on_tick, function(event)
	--game.print("pre tick")
	global.JECounter = global.JECounter + 1
	if (global.JECounter == 60) then
		UpdateTrains()
		global.JECounter = 0
		--game.print("tick")
	end
end)

script.on_init(OnInit)
script.on_event(defines.events.on_entity_destroyed, on_remove_entity)
script.on_event(defines.events.on_entity_died, on_remove_entity)
script.on_event(defines.events.on_robot_mined_entity, on_remove_entity)
script.on_event(defines.events.on_player_mined_entity, on_remove_entity)
script.on_event(defines.events.on_built_entity, on_new_entity)
script.on_event(defines.events.on_robot_built_entity, on_new_entity)
script.on_event(defines.events.script_raised_built, on_new_entity)
script.on_event(defines.events.script_raised_revive, on_new_entity)