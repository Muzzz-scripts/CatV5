repeat task.wait() until game:IsLoaded()

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) or not shared.VapeDeveloper then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/Muzzz-scripts/catV5/'..readfile('kaydenrewrite/profiles/commit.txt')..'/'..select(1, path:gsub('kaydenrewrite/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				loadstring(game:HttpGet('https://raw.githubusercontent.com/Muzzz-scripts/catV5/main/init.lua'), 'init.lua')()
			]]
			if getgenv().kaydenvapedev then
				teleportScript = 'getgenv().kaydenvapedev = true\n'.. [[
					shared.vapereload = true
					loadstring(readfile('kaydenrewrite/init.lua'), 'init.lua')()
				]]
			end
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if getgenv().username then
				teleportScript = `getgenv().username = {getgenv().username}\n`.. teleportScript
			end
			if getgenv().password then
				teleportScript = `getgenv().password = {getgenv().password}\n`.. teleportScript
			end
			if getgenv().closet then
				teleportScript = 'getgenv().closet = true\n'.. teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		makestage(5, 'Finished!')
		task.spawn(pcall, function()
			if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
				vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 3)
				task.wait(3.5)
				vape:CreateNotification('Kayden', `Initialized as {(kaydenuser or 'Guest')} with role {kaydenrole or 'Basic'}`, 2.5, 'info')
				task.wait(1)
				if not isfile('newuserkayden2') then
					vape:CreateNotification('Kayden', 'You have been redirected to Kayden\'s discord server', 3, 'warning')
					writefile('newuserkayden2', 'True')
					request({
						Url = 'http://127.0.0.1:6463/rpc?v=1',
						Method = 'POST',
						Headers = {
							['Content-Type'] = 'application/json',
							Origin = 'https://discord.com'
						},
						Body = cloneref(game:GetService('HttpService')):JSONEncode({
							invlink = 'kaydenvape',
							cmd = 'INVITE_BROWSER',
							args = {
								code = 'kaydenvape'
							},
							nonce = cloneref(game:GetService('HttpService')):GenerateGUID(true)
						})
					})
				end
			end
		end)
	end
end

if not isfile('kaydenrewrite/profiles/gui.txt') then
	writefile('kaydenrewrite/profiles/gui.txt', 'new')
end
local gui = readfile('kaydenrewrite/profiles/gui.txt')

if gui == nil or gui == '' or not table.find({'rise', 'new', 'old'}, gui) then
	gui = 'new'
end

if not isfolder('kaydenrewrite/assets/'..gui) then
	makefolder('kaydenrewrite/assets/'..gui)
end

if shared.vape then
	shared.vape:Uninject()
end

vape = loadstring(downloadFile('kaydenrewrite/guis/'..gui..'.lua'), 'gui')()
shared.vape = vape

if not shared.VapeIndependent then
	makestage(3, 'Downloading game packages')
	loadstring(downloadFile('kaydenrewrite/games/universal.lua'), 'universal')()
	shared.vape.Libraries.Kayden = true
	makestage(4, 'Loading all packages')
	loadstring(downloadFile('kaydenrewrite/libraries/whitelist.lua'), 'whitelist.lua')()
	if isfile('kaydenrewrite/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('kaydenrewrite/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/Muzzz-scripts/catV5/'..readfile('kaydenrewrite/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('kaydenrewrite/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	loadstring(downloadFile('kaydenrewrite/games/bedwars/modules.luau'), 'modules.luau')()
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
