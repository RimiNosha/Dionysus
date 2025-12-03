/turf/closed/constructed_wall/proc/get_connections()
	var/connections = NONE
	for(var/cardinal in GLOB.cardinals)
		var/turf/neighbor = get_step(src, cardinal)
		if(isnull(neighbor))
			connections |= cardinal
			continue
		if(allow_connection(neighbor))
			connections |= cardinal
			continue
	var/valid_diags = NONE
	if((connections & (NORTH|EAST)) == (NORTH|EAST))
		valid_diags |= NORTHEAST_JUNCTION
	if((connections & (SOUTH|EAST)) == (SOUTH|EAST))
		valid_diags |= SOUTHEAST_JUNCTION
	if((connections & (SOUTH|WEST)) == (SOUTH|WEST))
		valid_diags |= SOUTHWEST_JUNCTION
	if((connections & (NORTH|WEST)) == (NORTH|WEST))
		valid_diags |= NORTHWEST_JUNCTION
	for(var/diag in bitfield_to_list(valid_diags))
		var/turf/neighbor = get_step(src, reverse_ndir(diag))
		if(isnull(neighbor))
			connections |= diag
			continue
		if(allow_connection(neighbor))
			connections |= diag
			continue
	return connections

/turf/closed/constructed_wall/proc/allow_connection(turf/connection)
	if(istype(loc, /area/shuttle) != istype(connection.loc, /area/shuttle))
		return FALSE
	if(istype(connection, /turf/closed/constructed_wall))
		var/turf/closed/constructed_wall/wall = connection
		return wall.material_plating == material_plating
	var/obj/structure/window/window = locate() in connection
	return window?.anchored || FALSE

/turf/closed/constructed_wall/proc/update_connections(from_changeturf = FALSE)
	var/old_connections = wall_connections
	wall_connections = from_changeturf ? NONE : get_connections()
	// this if statement is very important; without this if statement walls will just keep updating themselves until the server cries in world.loop_check
	if(wall_connections == old_connections)
		return
	if(!from_changeturf)
		update_appearance(UPDATE_ICON_STATE)
	// notably we do not iterate over all connections here, because we only care about the ones that changed
	// iterate over our new connections to tell them to update their connections too
	// consider using a cached static for GLOB.all_junction_directions in the future, needs profiling
	var/list/gain_connection_junctions = old_connections == -1 ? bitfield_to_list(wall_connections) : (GLOB.all_junction_directions & bitfield_to_list(wall_connections & ~old_connections))
	for(var/nndir in gain_connection_junctions)
		var/ndir = reverse_ndir(nndir)
		var/turf/neighbor = get_step(src, ndir)
		if(istype(neighbor, /turf/closed/constructed_wall))
			var/turf/closed/constructed_wall/wall = neighbor
			wall.update_connections()
		else
			neighbor.update_appearance()
	if(old_connections == -1)
		return
	// iterate over our lost connections to tell them to update their connections too
	var/list/lose_connection_junctions = GLOB.all_junction_directions & bitfield_to_list(old_connections & ~wall_connections)
	for(var/nndir in lose_connection_junctions)
		var/ndir = reverse_ndir(nndir)
		var/turf/neighbor = get_step(src, ndir)
		if(istype(neighbor, /turf/closed/constructed_wall))
			var/turf/closed/constructed_wall/wall = neighbor
			wall.update_connections()
		else
			neighbor.update_appearance()
