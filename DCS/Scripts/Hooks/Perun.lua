-- ORIGINAL CREDITS : Perun for DCS World https://github.com/szporwolik/perun -> DCS Hook component
-- Stripped by xvx45 for bot usage, all credits to VladMordock
-- Initial init
local PerunJSON = {}

-- ###################### SETTINGS - DO NOT MODIFY OUTSIDE THIS SECTION #############################

PerunJSON.RefreshStatus = 15 												-- (int) base refresh rate in seconds to send status update (values lower than 60 may affect performance!)
PerunJSON.RefreshMission = 60 												-- (int) refresh rate in seconds to send mission information  (values lower than 60 may affect performance!)
PerunJSON.JsonStatusLocation = "Scripts\\Json\\" 							-- (string) folder relative do user's SaveGames DCS folder -> status file updated each RefreshMission

-- ###################### END OF SETTINGS - DO NOT MODIFY OUTSIDE THIS SECTION ######################


-- Variable init
PerunJSON.Version = "v0.8.2"
PerunJSON.StatusData = {}
PerunJSON.SlotsData = {}
PerunJSON.MissionData = {}
PerunJSON.ServerData = {}
PerunJSON.StatData = {}
PerunJSON.StatDataLastType = {}
PerunJSON.MissionHash=""
PerunJSON.lastSentStatus =0
PerunJSON.lastSentMission =0
PerunJSON.lastSentKeepAlive =0
PerunJSON.lastReconnect = 0
PerunJSON.JsonStatusLocation = lfs.writedir() .. PerunJSON.JsonStatusLocation
PerunJSON.IsServer = true --DCS.isServer( )								-- TBD looks like DCS API error, always returning True

-- ########### Helper function definitions ###########
function stripChars(str)
    -- remove accents characters from string
    -- via https://stackoverflow.com/questions/50459102/replace-accented-characters-in-string-to-standard-with-lua
    tableAccents = {}
    tableAccents["à"] = "a"
    tableAccents["á"] = "a"
    tableAccents["â"] = "a"
    tableAccents["ã"] = "a"
    tableAccents["ä"] = "a"
    tableAccents["ç"] = "c"
    tableAccents["è"] = "e"
    tableAccents["é"] = "e"
    tableAccents["ê"] = "e"
    tableAccents["ë"] = "e"
    tableAccents["ì"] = "i"
    tableAccents["í"] = "i"
    tableAccents["î"] = "i"
    tableAccents["ï"] = "i"
    tableAccents["ñ"] = "n"
    tableAccents["ò"] = "o"
    tableAccents["ó"] = "o"
    tableAccents["ô"] = "o"
    tableAccents["õ"] = "o"
    tableAccents["ö"] = "o"
    tableAccents["ù"] = "u"
    tableAccents["ú"] = "u"
    tableAccents["û"] = "u"
    tableAccents["ü"] = "u"
    tableAccents["ý"] = "y"
    tableAccents["ÿ"] = "y"
    tableAccents["À"] = "A"
    tableAccents["Á"] = "A"
    tableAccents["Â"] = "A"
    tableAccents["Ã"] = "A"
    tableAccents["Ä"] = "A"
    tableAccents["Ç"] = "C"
    tableAccents["È"] = "E"
    tableAccents["É"] = "E"
    tableAccents["Ê"] = "E"
    tableAccents["Ë"] = "E"
    tableAccents["Ì"] = "I"
    tableAccents["Í"] = "I"
    tableAccents["Î"] = "I"
    tableAccents["Ï"] = "I"
    tableAccents["Ñ"] = "N"
    tableAccents["Ò"] = "O"
    tableAccents["Ó"] = "O"
    tableAccents["Ô"] = "O"
    tableAccents["Õ"] = "O"
    tableAccents["Ö"] = "O"
    tableAccents["Ù"] = "U"
    tableAccents["Ú"] = "U"
    tableAccents["Û"] = "U"
    tableAccents["Ü"] = "U"
    tableAccents["Ý"] = "Y"

    -- Polish accents
    tableAccents["e"] = "e"
    tableAccents["E"] = "E"
    tableAccents["ó"] = "o"
    tableAccents["Ó"] = "O"
    tableAccents["a"] = "a"
    tableAccents["A"] = "A"
    tableAccents["s"] = "s"
    tableAccents["S"] = "S"
    tableAccents["c"] = "c"
    tableAccents["C"] = "C"
    tableAccents["z"] = "z"
    tableAccents["Z"] = "Z"
    tableAccents["z"] = "z"
    tableAccents["Z"] = "Z"
    tableAccents["l"] = "l"
    tableAccents["L"] = "L"

    -- TBD additonal characters

    normalizedString = ''

    for strChar in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
        if tableAccents[strChar] ~= nil then
            normalizedString = normalizedString..tableAccents[strChar]
        else
            normalizedString = normalizedString..strChar
        end
    end
    return normalizedString
end

PerunJSON.UpdateStatusPart = function(part_id, data_package)
    -- Helper for status update container
    PerunJSON.StatusData[part_id] = data_package
end

-- ########### Main code ###########

PerunJSON.AddLog = function(text)
    -- Adds logs to DCS.log file
    net.log("PerunJSON : ".. text)
end

PerunJSON.UpdateJsonStatus = function()
    -- Updates status json file
    TempData={}
    TempData["2"]=PerunJSON.StatusData

    _temp=net.lua2json(TempData)

    PerunJSON_export = io.open(PerunJSON.JsonStatusLocation .. "perun_status_data.json", "w")
    PerunJSON_export:write(_temp .. "\n")
    PerunJSON_export:close()
	PerunJSON.AddLog("Updated JSON")
end

PerunJSON.SendToPerunJSON = function(data_id, data_package)
    -- Prepares and sends data package
	-- Prepare data
    TempData={}
    TempData["type"]=data_id
    TempData["payload"]=data_package
    TempData["timestamp"]=os.date('%Y-%m-%d %H:%M:%S')
	TempData["instance"]=PerunJSON.Instance
	
    temp=net.lua2json(TempData)
    temp=stripChars(temp)
end

PerunJSON.UpdateStatus = function()
    -- Main function for status updates

    -- Status data - update all subsections
		-- 1 - Mission
		temp={}
		temp['name']=DCS.getMissionName()
		temp['modeltime']=DCS.getModelTime()
		temp['realtime']=DCS.getRealTime()
		temp['pause']=DCS.getPause()
		temp['multiplayer']=DCS.isMultiplayer()
		temp['theatre'] = PerunJSON.MissionData['mission']['theatre']
		temp['weather'] = PerunJSON.MissionData['mission']['weather']
		PerunJSON.UpdateStatusPart("mission",temp)

		-- Send
		PerunJSON.SendToPerunJSON(2,PerunJSON.StatusData)
end


PerunJSON.UpdateMission = function()
    -- Main function for mission information updates
    PerunJSON.MissionData=DCS.getCurrentMission()
end

--- ########### Event callbacks ###########

PerunJSON.onSimulationStart = function()
    PerunJSON.MissionHash=DCS.getMissionName( ).."@".. PerunJSON.Instance .. "@"..os.date('%Y%m%d_%H%M%S');
    PerunJSON.LogEvent("SimStart","Mission " .. PerunJSON.MissionHash .. " started",nil,nil);
	PerunJSON.StatData = {}
	PerunJSON.StatDataLastType = {}
end

PerunJSON.onSimulationFrame = function()
    local _now = DCS.getRealTime()

    -- First run
    if PerunJSON.lastSentMission ==0 and PerunJSON.lastSentStatus ==0 then
        PerunJSON.UpdateMission()
    end

    -- Send mission update and update JSON
    if _now > PerunJSON.lastSentMission + PerunJSON.RefreshMission then
        PerunJSON.lastSentMission = _now

        PerunJSON.UpdateMission()
        PerunJSON.UpdateJsonStatus()
    end

    -- Send status update
    if _now > PerunJSON.lastSentStatus + PerunJSON.RefreshStatus then
        PerunJSON.lastSentStatus = _now

        PerunJSON.UpdateStatus()
    end
	
	-- Send keepalive
	if _now > PerunJSON.lastSentKeepAlive + 5 then
		PerunJSON.lastSentKeepAlive = _now
		PerunJSON.SendToPerunJSON(0,nil)
	end
end

-- ########### Finalize and set callbacks ###########
if PerunJSON.IsServer then
	DCS.setUserCallbacks(PerunJSON)
	net.log("Perun by VladMordock & stripped down by xvx45 was loaded")
end
