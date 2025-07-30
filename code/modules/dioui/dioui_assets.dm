//DEFINITIONS FOR ASSET DATUMS START HERE.
/datum/asset/dioui
	// early = TRUE

	var/list/common = list()
	var/list/uncommon = list()
	var/list/templates = list()

	var/list/common_dirs = list(
		"dioui/css/",
		"dioui/images/",
		"dioui/images/status_icons/",
		"dioui/images/modular_computers/",
		"dioui/js/"
	)
	var/list/uncommon_dirs = list(
		"news_articles/images/"
	)
	var/template_dir = "dioui/templates/"
	var/template_temp_dir = "data/"

/datum/asset/dioui/register()
	uncommon = list()
	common = list()
	// Crawl the directories to find files.
	for (var/path in common_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				var/full_path = path + filename
				if(fexists(full_path))
					if(SSassets.cache[filename]) // ARTEA TODO: Remove duplicate assets, or remove TGUI. Whichever comes first.
						continue
					common[filename] = file(full_path)

	for (var/path in uncommon_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				var/full_path = path + filename
				if(fexists(full_path))
					if(SSassets.cache[filename])
						continue
					uncommon[filename] = file(full_path)

	// var/list/mapnames = list()
	// for(var/z in SSmapping.map_levels)
	// 	mapnames += map_image_file_name(z)

	// var/list/filenames = flist(MAP_IMAGE_PATH)
	// for(var/filename in filenames)
	// 	if(copytext(filename, length(filename)) != "/") // Ignore directories.
	// 		var/file_path = MAP_IMAGE_PATH + filename
	// 		if((filename in mapnames) && fexists(file_path))
	// 			common[filename] = fcopy_rsc(file_path)
	// 			register_asset(filename, common[filename])

	for(var/filename in flist(template_dir))
		if(copytext(filename, length(filename)) != "/") // Ignore directories.
			var/full_path = template_dir + filename
			if(fexists(full_path))
				if(SSassets.cache[filename])
					continue
				templates[filename] = file(full_path)

	var/list/assets = /*list(DIOUI_TEMPLATE_FILE_NAME = merge_and_register_templates())*/ templates + uncommon + common

	for(var/asset_name in assets)
		var/datum/asset_cache_item/ACI = SSassets.transport.register_asset(asset_name, assets[asset_name])
		if (!ACI)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue

/datum/asset/dioui/send(client, uncommon)
	// . = SSassets.transport.send_assets(client, DIOUI_TEMPLATE_FILE_NAME)
	. = . && SSassets.transport.send_assets(client, templates)
	. = . && SSassets.transport.send_assets(client, common)
	. = . && SSassets.transport.send_assets(client, uncommon)

/datum/asset/dioui/proc/merge_and_register_templates()
	SSassets.cache -= DIOUI_TEMPLATE_FILE_NAME
	var/list/templates = flist(template_dir)
	for(var/filename in templates)
		if(copytext(filename, length(filename)) != "/")
			templates[filename] = replacetext(replacetext(file2text(template_dir + filename), "\n", ""), "\t", "")
		else
			templates -= filename
	var/full_file_name = template_temp_dir + DIOUI_TEMPLATE_FILE_NAME
	if(fexists(full_file_name))
		fdel(file(full_file_name))
	var/template_file = file(full_file_name)
	WRITE_FILE(template_file, json_encode(templates))
	return template_file

/datum/asset/dioui/proc/get_templates()
	if (templates.len > 0)
		return templates
	var/list/found_templates = flist(template_dir)
	for(var/filename in found_templates)
		if(copytext(filename, length(filename)) == "/")
			found_templates.Remove(filename)
			continue

		found_templates[filename] = file(template_dir + filename)

	return found_templates

// Note: this is intended for dev work, and is unsafe. Do not use outside of that.
/datum/asset/dioui/proc/recompute_and_resend_templates()
	// merge_and_register_templates()
	templates = list()
	var/asset_list = get_templates()
	for(var/client/C in GLOB.clients)
		if(C) // there are sleeps here, potentially
			SSassets.transport.send_assets(C, /*DIOUI_TEMPLATE_FILE_NAME*/ asset_list)
			to_chat(C, span_warning("Nanoui templates have been updated. Please close and reopen any browser windows."))

/client/proc/resend_dioui_templates()
	set category = "Debug"
	set name = "Resend Nanoui Templates"
	if(!check_rights(R_DEBUG))
		return
	var/datum/asset/dioui/dio_asset = get_asset_datum(/datum/asset/dioui)
	if(dio_asset)
		dio_asset.recompute_and_resend_templates()

// Note: this is intended for dev work, and is unsafe. Do not use outside of that.
/datum/asset/dioui/proc/recompute_and_resend_assets()
	register()
	for(var/client/C in GLOB.clients)
		if(C) // there are sleeps here, potentially
			send(C)
			to_chat(C, span_warning("Nanoui assets have been updated. Please close and reopen any browser windows."))

/client/proc/resend_dioui_assets()
	set category = "Debug"
	set name = "Resend Nanoui Assets"
	if(!check_rights(R_DEBUG))
		return
	var/static/localhost_addresses = list("127.0.0.1", "::1")
	if((!isnull(usr.client.address) && !(usr.client.address in localhost_addresses)) && alert(usr, "Are you sure you want to reload all NanoUI assets? This may cause a surge in network traffic!", "This server is live", "Reload and Send", "Cancel") != "Reload and Send")
		return
	var/datum/asset/dioui/dio_asset = get_asset_datum(/datum/asset/dioui)
	if(dio_asset)
		dio_asset.register()
		for(var/client/C in GLOB.clients)
			dio_asset.send(C)

