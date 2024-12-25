local DataCode = {
	Data = {
		["client"] = true,
		["server"] = true,
		["shared"] = false,
	},
	TagUse = false,
	Tag = "green"
}

local _writeScript = function ( responseData, errno, filepath )
	if errno > 0 then
		return
	end
	
	local file = fileCreate ( filepath )
	if file then
		fileWrite ( file, responseData )
		fileClose ( file )
	end
end

function compileScript ( filepath , compiled)
	local filename = gettok ( filepath, 1, 46 )
	if compiled then 
		filepath = string.sub(filepath, 0, #filepath-1)
	end
	
	local file = fileOpen ( filepath, true )
	if file then
		local content = fileRead ( file, fileGetSize ( file ) )
		fileClose ( file )	
		fetchRemote ( "https://luac.mtasa.com/?compile=1&debug=0&obfuscate=3", _writeScript, content, true, filename .. ".luac" ) -- Protect level 3
	end
end

function compileAllScriptsInResource(resource)
	local xml = xmlLoadFile ( ":"..resource.."/meta.xml"  )
	if xml == false then
		return
	end
	
	local node
	local index = 0
	local _next = function ( )
		node = xmlFindChild ( xml, "script", index )
		index = index + 1
		return node
	end
	
	local num = 0
	while _next ( ) do
		if xmlNodeGetAttribute ( node, "special" ) == false then
			local filepath = xmlNodeGetAttribute ( node, "src" )
			local isType = xmlNodeGetAttribute ( node, "type" )
			if DataCode.Data[isType] and DataCode.Data[isType] == true then
				local compiled = false 
				if string.find(filepath, "luac") then 
					compiled = true 
				end

				iprint("Compile success: "..filepath)
				
				compileScript ( ":"..resource.."/"..filepath, compiled)
				num = num + 1
			end
		end
	end
end

function compileAllScripts()
	for k,v in ipairs(getResources()) do 
		local name = getResourceName(v)
		if DataCode.TagUse == true then
			if string.find(name, DataCode.Tag) then 
				compileAllScriptsInResource(name)
			end
		else
			compileAllScriptsInResource(name)
		end
	end
end
--addEventHandler("onResourceStart", resourceRoot, compileAllScripts) -- when res start then compile all scripts

function compileMSScript(resourceName)
	local res = getResourceFromName(resourceName)
	if res then 
		compileAllScriptsInResource(resourceName)
		return true 
	end
	
	return false 
end 

function compileFromName(player, cmd, arg1)
	--if getElementData(player, "Admin") == 4 then -- Admin Protect from ElementData
		compileMSScript(arg1)
	--end
end 
addCommandHandler("compile", compileFromName)