local filename = "autorotatemap.txt"
local one_day = 86400*2
local default_map = "gm_functional_flatgrass"
local map_list = {
	"gm_freespace_13",
	"gm_flatgrass",
	"gm_functional_flatgrass",
	"gm_excess_construct_13",
	"gm_construct_flatgrass_v6-2",
	"gm_bigcity",
	"gm_bluehils_test3"
}

local function readInfo(s)
	local f = file.Open(s, "r", "DATA")
	if not f then return end

	local size = f:Size()
	local recv = f:Read(size)
	f:Close()

	return util.JSONToTable(recv)
end

local function writeInfo(s, time, map_name)
	local f = file.Open(s, "w", "DATA")
	if not f then
		return false
	end

	f:Write(util.TableToJSON( {
		time,
		map_name
	}))
	f:Close()

	return true
end

local function log(s)
	print("autorotatemap.lua: " .. s)
end

local function First()
	print("---------------------------")
	log("starting")
	log("current map: " .. cvars.String("host_map"))

	log("loading " .. filename)

	local recv = readInfo(filename)
	local map_name = default_map
	local last_start = os.time()
	local relevant_start = os.time()

	if (recv) then
		log("loaded " .. filename .. " successfully")

		last_start = recv[1]
		relevant_start = last_start
		map_name = recv[2]

		log("last relevant server start at " .. last_start)
		log("last map was " .. map_name)
	else
		log("failed to load " .. filename)
	end

	if (os.time() - last_start >= one_day) then
		log("setting a new map")

		relevant_start = os.time()
		map_name = map_list[math.random(1,#map_list)]

		log("map set to " .. map_name)
		RunConsoleCommand("changelevel", map_name)
	end
	
	log("writing to " .. filename)
	local wrote = writeInfo(filename, relevant_start, map_name)
	if not wrote then
		log("failed to write to " .. filename)
		log("stopping...")
		return
	end
	log("wrote " .. filename .. " succesfully")
end

First()
