//DEFINITIONS FOR ASSET DATUMS START HERE.
#define TEMPLATE_FILE_NAME "nanoui_templates.json"

/datum/asset/nanoui
	var/list/common = list()
	var/list/uncommon = list()

	var/list/common_dirs = list(
		"nano/css/",
		"nano/images/",
		"nano/images/status_icons/",
		"nano/images/modular_computers/",
		"nano/js/"
	)
	var/list/uncommon_dirs = list(
		"news_articles/images/"
	)
	var/template_dir = "nano/templates/"
	var/template_temp_dir = "data/"

/datum/asset/nanoui/register()
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

	var/list/assets = list(TEMPLATE_FILE_NAME = merge_and_register_templates()) + uncommon + common

	for(var/asset_name in assets)
		var/datum/asset_cache_item/ACI = SSassets.transport.register_asset(asset_name, assets[asset_name])
		if (!ACI)
			log_asset("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		ACI.keep_local_name = TRUE

/datum/asset/nanoui/send(client, uncommon)
	. = SSassets.transport.send_assets(client, TEMPLATE_FILE_NAME)
	. = . && SSassets.transport.send_assets(client, common)
	. = . && SSassets.transport.send_assets(client, uncommon)

/datum/asset/nanoui/proc/merge_and_register_templates()
	SSassets.cache -= TEMPLATE_FILE_NAME
	var/list/templates = flist(template_dir)
	for(var/filename in templates)
		if(copytext(filename, length(filename)) != "/")
			templates[filename] = replacetext(replacetext(file2text(template_dir + filename), "\n", ""), "\t", "")
		else
			templates -= filename
	var/full_file_name = template_temp_dir + TEMPLATE_FILE_NAME
	if(fexists(full_file_name))
		fdel(file(full_file_name))
	var/template_file = file(full_file_name)
	WRITE_FILE(template_file, json_encode(templates))

	return template_file

// Note: this is intended for dev work, and is unsafe. Do not use outside of that.
/datum/asset/nanoui/proc/recompute_and_resend_templates()
	merge_and_register_templates()
	for(var/client/C in GLOB.clients)
		if(C) // there are sleeps here, potentially
			SSassets.transport.send_assets(C, TEMPLATE_FILE_NAME)
			to_chat(C, span_warning("Nanoui templates have been updated. Please close and reopen any browser windows."))

/client/verb/resend_nanoui_templates()
	set category = "Debug"
	set name = "Resend Nanoui Templates"
	if(!check_rights(R_DEBUG))
		return
	var/datum/asset/nanoui/nano_asset = get_asset_datum(/datum/asset/nanoui)
	if(nano_asset)
		nano_asset.recompute_and_resend_templates()

// Note: this is intended for dev work, and is unsafe. Do not use outside of that.
/datum/asset/nanoui/proc/recompute_and_resend_assets()
	register()
	for(var/client/C in GLOB.clients)
		if(C) // there are sleeps here, potentially
			send(C)
			to_chat(C, span_warning("Nanoui assets have been updated. Please close and reopen any browser windows."))

/client/verb/resend_nanoui_assets()
	set category = "Debug"
	set name = "Resend Nanoui Assets"
	if(!check_rights(R_DEBUG))
		return
	var/static/localhost_addresses = list("127.0.0.1", "::1")
	if((!isnull(usr.client.address) && !(usr.client.address in localhost_addresses)) && alert(usr, "Are you sure you want to reload all NanoUI assets? This may cause a surge in network traffic!", "This server is live", "Reload and Send", "Cancel") != "Reload and Send")
		return
	var/datum/asset/nanoui/nano_asset = get_asset_datum(/datum/asset/nanoui)
	if(nano_asset)
		nano_asset.register()
		for(var/client/C in GLOB.clients)
			nano_asset.send(C)

