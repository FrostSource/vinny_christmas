
local hp = thisEntity:GetHealth()

local function SpawnAshes()
	if hp - thisEntity:GetHealth() < 20 then
		hp = thisEntity:GetHealth()
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
		SpawnEntityFromTableSynchronous('prop_dynamic', {
			origin = Vector(traceTable.pos.x, traceTable.pos.y, (traceTable.pos.z - 0.4)),
			--scales = '0.4 0.4 0.4',
			model = 'models/vinny_house/ashes.vmdl',
			solid = '0',
			--disableshadows = '1',
			--materialoverride = 'materials/ashes.vmat',
			rendercolor = '195 195 195 255',
			targetname = '@dynamic_spawned_ashes_prop'
		})
	else
		print('Trace failed')
	end

	--DoEntFire('!self', 'FireUser1', '', 0, nil, nil)
	DoEntFireByInstanceHandle(thisEntity, 'FireUser1', '', 0, nil, nil)
end
Expose(SpawnAshes)
