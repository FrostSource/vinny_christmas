
Health = Health or 0

function Activate()
	--print('ASHES SPAWNED')
	--PrecacheEntityFromTable(classname, spawnKeys)
	--PrecacheModel("models/rural/barn_hay_pile_01.vmdl",thisEntity)
	Health = thisEntity:GetHealth()
end

function SpawnAshes()
	--print('Starting ashes spawn')

	--print('urn damage taken', Health - thisEntity:GetHealth())
	if Health - thisEntity:GetHealth() < 24 then
		Health = thisEntity:GetHealth()
		return nil
	end

	local startVector = thisEntity:GetCenter()

	local traceTable = {
		startpos = startVector,
		endpos = startVector - Vector(0, 0, 1024),
		ignore = thisEntity,
		mask = 0
	}
	
	TraceLine(traceTable)

	if traceTable.hit then
		--debugoverlay:Sphere(traceTable.pos,8,255,255,255,255,true,10000)
		--print('Trace success, spawning ashes ', tostring(traceTable.pos), traceTable.enthit:GetClassname(), traceTable.enthit:GetName())
		
		local classname = 'prop_dynamic'
		local spawnKeys = {
			origin = traceTable.pos.x..' '..traceTable.pos.y..' '..(traceTable.pos.z - 0.4),
			--scales = '0.4 0.4 0.4',
			model = 'models/vinny_house/ashes.vmdl',
			solid = '0',
			--disableshadows = '1',
			--materialoverride = 'materials/ashes.vmat',
			rendercolor = '195 195 195 255',
			targetname = '@dynamic_spawned_ashes_prop'
		}
		
		SpawnEntityFromTableSynchronous(classname, spawnKeys)
	else
		print('Trace failed')
	end

	--DoEntFire('!self', 'FireUser1', '', 0, nil, nil)
	DoEntFireByInstanceHandle(thisEntity, 'FireUser1', '', 0, nil, nil)
end
