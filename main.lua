-- Lionblaster
-- by zorg
-- @2014

-- Functions in this lua file:
-- - recursiveEnumerate(folder,fileTree)
-- - drawDebug()
-- - love.graphics.setAlpha(alpha,blend)

function love.load(args)

	-- If the debug log already exist, add a newline to it if it's not there
	if love.filesystem.isFile('log.txt') then
		local t = {}
		for line in love.filesystem.lines('log.txt') do
			t[#t] = line
		end
		if t[#t] ~= "" then
			love.filesystem.append('log.txt', "\n")
		end
	end

	-- Debugging timestamp
	appendLog("LOG STARTED	: " .. os.date("%c", os.time()),false)

	--[[
	-- Enumerate directories as sanity check:

	local filesString = recursiveEnumerate("", "")
	print(filesString)
	--]]

	---------------------------------------------------------------------------

	-- Temporary Debug Console Addition
	lovebird = require('code.libs.rxi.lovebird')
	lovebird.updateinterval = 1.0

	-- Temporary Debug Hotswap Addition
	lume = require('code.libs.rxi.lume')
	lurker = require('code.libs.rxi.lurker')

	---------------------------------------------------------------------------

	appendLog("notice	: Initializing... (love.load / main.lua)")

	-- The internal game version; serialized files will be compared with this.
	version = 0.100

	-- The Main Table, holding everything.
	Lionblaster = {}

	-- Creating instance data structure...
	Lionblaster.InstanceData = {}

	appendLog("notice	: creating instance data structure")

	-- dnkroz, iddqd, etc.
	Lionblaster.InstanceData.devMindset = false

	-- Create an elapsed time counter that only counts how much time has passed in this game instance;
	-- additionally, it will only be counted from the title screen.
	Lionblaster.InstanceData.elapsedTime = 0

	Lionblaster.InstanceData.Assets = {}

	-- Create tables for assets: background music, sound effects, graphics, cinema scripts and level data.
	Lionblaster.InstanceData.Assets.bgm = {}
	Lionblaster.InstanceData.Assets.gfx = {}
	Lionblaster.InstanceData.Assets.sfx = {}
	Lionblaster.InstanceData.Assets.cine = {}
	Lionblaster.InstanceData.Assets.lvl = {}

	-- Create tables for classes...
	Lionblaster.InstanceData.Classes = {}

	appendLog("notice	: importing classes")

	-- Load in classes that need to be in a global callback
	Lionblaster.InstanceData.Classes.AudioEngine = require('code.classes.audioengine')

	-- Load in the helper utility classes
	Lionblaster.InstanceData.Classes.Utils = {}
	Lionblaster.InstanceData.Classes.Utils.Color = require('code.classes.color')
	Lionblaster.InstanceData.Classes.Utils.Serialize = require('code.libs.robin.ser')
	Lionblaster.InstanceData.Classes.Utils.BubbleBabble = require('code.classes.bb')
	Lionblaster.InstanceData.Classes.Utils.RadarChart = require('code.libs.josefnpat.radarchart')
	--Lionblaster.InstanceData.Classes.Utils.APNG = require('code.???.apng')

	-- Load in classes related to ingame stuff (and to the beastiary)
	Lionblaster.InstanceData.Classes.Entity = require('code.classes.entity')
	Lionblaster.InstanceData.Classes.Camera = require('code.classes.camera')
	Lionblaster.InstanceData.Classes.MapGen = require('code.classes.mapgen')
	--Lionblaster.InstanceData.Classes.Replay = require('code.classes.replay')

	appendLog("notice	: class importing done")

	---[[
	-- Create screen recorder related stuff.
	Lionblaster.InstanceData.isRecording = false
	Lionblaster.InstanceData.recordedFrames = 0
	Lionblaster.InstanceData.recordingBuffer = {} -- numerically indexed array holding screenshots as imagedata objects, and delta values for timing.
	--]]

	-- Create a table that will hold the current level data, along with all enitites and whatnot...
	-- (less problems than passing things through the gamestates)
	-- Also holds prebaked player spritesheets
	Lionblaster.InstanceData.GameData = {}


	appendLog("notice	: importing gamestates...")

	-- Import the HUMP gamestate system, require gamestates
	Lionblaster.InstanceData.GameStates = {}

	local LGS = Lionblaster.InstanceData.GameStates -- Less typing.

	LGS.GS = require 'code.libs.vrld.hump.gamestate'

	LGS.Preloader				= require 'code.states.preloader'

	LGS.Title					= require 'code.states.title'
	LGS.Password				= require 'code.states.password'
	--LGS.Lobby					= require 'code.states.lobby'
	--	LGS.Room				= require 'code.states.room'
	--LGS.Beastiary				= require 'code.states.beastiary'
	--LGS.ReplayManager			= require 'code.states.replaymanager'
	LGS.Settings				= require 'code.states.settings'
		LGS.ControlSettings		= require 'code.states.controlsettings'

	LGS.Cinema					= require 'code.states.cinema'
	LGS.Stage					= require 'code.states.stage'
	LGS.Round					= require 'code.states.round'
	--LGS.Results				= require 'code.states.results' -- multiplayer state after match is over
	LGS.Game					= require 'code.states.game'
	--LGS.Pause					= require 'code.states.pause'
	--LGS.MusicRoom				= require 'code.states.musicbox'

	appendLog("notice	: instance data structure generated successfully")

	-- Create the table holding persistent data. We need to import 4 files, or if they don't exist, create them here.
	Lionblaster.PersistentData = {}

	-- Create a table holding shader tables (loaded by the preloader, only user put ones will be listed for this reason)
	Lionblaster.PersistentData.Shaders = {}
	Lionblaster.PersistentData.Shaders[0] = {}
	Lionblaster.PersistentData.Shaders[0].name = 'none'
	Lionblaster.PersistentData.Shaders[0].shader = false -- shader function...

	-- user.lua		->	User
	if love.filesystem.isFile('user.lua') then
		local str = love.filesystem.read('user.lua')
		Lionblaster.PersistentData.User = loadstring(str)()
	end
	if Lionblaster.PersistentData.User then
		appendLog("notice	: persistent user data loading succeeded")
	else
		appendLog("error	: persistent user data loading failed; no file found, setting defaults")

		Lionblaster.PersistentData.User = {}
		Lionblaster.PersistentData.User.name = 'Shiro'

		Lionblaster.PersistentData.User.scale = 2
		Lionblaster.PersistentData.User.shader = 0 -- the key from: Lionblaster.PersistentData.Shaders

		Lionblaster.PersistentData.User.bgmVolume = 0.8 -- [0.0,1.0], 1/10 increments
		Lionblaster.PersistentData.User.sfxVolume = 0.8 -- [0.0,1.0], 1/10 increments

		appendLog("notice	: persistent user data creation succeeded")
	end

	-- controls.lua	->	ControlList
	if love.filesystem.isFile('controls.lua') then
		local str = love.filesystem.read('controls.lua')
		Lionblaster.PersistentData.ControlList = loadstring(str)()
	end
	if Lionblaster.PersistentData.ControlList then
		appendLog("notice	: persistent controller data loading succeeded")
	else
		appendLog("error	: persistent controller data loading failed; no file found, setting defaults")

		Lionblaster.PersistentData.ControlList = {}

		Lionblaster.PersistentData.ControlList[1] = {}
		Lionblaster.PersistentData.ControlList[1].controllerID = 'keyboard'
		Lionblaster.PersistentData.ControlList[1].up = 'up'
		Lionblaster.PersistentData.ControlList[1].down = 'down'
		Lionblaster.PersistentData.ControlList[1].left = 'left'
		Lionblaster.PersistentData.ControlList[1].right = 'right'
		Lionblaster.PersistentData.ControlList[1].a = ' '
		Lionblaster.PersistentData.ControlList[1].b = 'lctrl'
		Lionblaster.PersistentData.ControlList[1].start = 'return'
		Lionblaster.PersistentData.ControlList[1].select = 'lshift'

		Lionblaster.PersistentData.ControlList[2] = {}
		Lionblaster.PersistentData.ControlList[2].ControllerID = 'keyboard'
		Lionblaster.PersistentData.ControlList[2].up = 	'w'
		Lionblaster.PersistentData.ControlList[2].down = 's'
		Lionblaster.PersistentData.ControlList[2].left = 'a'
		Lionblaster.PersistentData.ControlList[2].right = 'd'
		Lionblaster.PersistentData.ControlList[2].a = 'k'
		Lionblaster.PersistentData.ControlList[2].b = 'l'
		Lionblaster.PersistentData.ControlList[2].start = 'h'
		Lionblaster.PersistentData.ControlList[2].select = 'j'

		appendLog("notice	: persistent controller data creation succeeded")
	end

	-- skin.lua		->	Skin
	if love.filesystem.isFile('skin.lua') then
		local str = love.filesystem.read('skin.lua')
		Lionblaster.PersistentData.Skin = loadstring(str)()
	end
	if Lionblaster.PersistentData.Skin then
		appendLog("notice	: persistent skin data loading succeeded")
	else
		appendLog("error	: persistent skin data loading failed; no file found, setting defaults")

		Lionblaster.PersistentData.Skin = {}
		Lionblaster.PersistentData.Skin.eyeStyle = 		1
		Lionblaster.PersistentData.Skin.outline =		{255,255,255,255} -- default values approximate white bomberman
		Lionblaster.PersistentData.Skin.pomPom =		{255,  0,255,255} -- perfect	
		Lionblaster.PersistentData.Skin.hood =			{255,255,255,255} -- perfect
		Lionblaster.PersistentData.Skin.skinTone =		{233,155,102,255} -- good
		Lionblaster.PersistentData.Skin.arms =			{255,255,255,255} -- perfect
		Lionblaster.PersistentData.Skin.robe =			{  0,141,255,255} -- decent
		Lionblaster.PersistentData.Skin.belt =			{  0,  0,  0,255} -- perfect 
		Lionblaster.PersistentData.Skin.beltBuckle =	{255,255,  0,255} -- good
		Lionblaster.PersistentData.Skin.gloves =		{255,  0,255,255} -- perfect
		Lionblaster.PersistentData.Skin.legs =			{255,255,255,255} -- perfect
		Lionblaster.PersistentData.Skin.shoes =			{255,  0,255,255} -- perfect

		appendLog("notice	: persistent skin data creation succeeded")
	end

	-- settings		->	Settings
	do
		appendLog("notice	: setting persistent settings defaults")

		Lionblaster.PersistentData.Settings = {}
		--Lionblaster.PersistentData.Settings.version = version -- risks false positive if a version param is not defined in the file
		Lionblaster.PersistentData.Settings.elapsedTime = 0
		Lionblaster.PersistentData.Settings.width = 256
		Lionblaster.PersistentData.Settings.height = 224						-- the extra 8 pixels that made it 232 was wrong.
		Lionblaster.PersistentData.Settings.gameMode = '91'
		Lionblaster.PersistentData.Settings.unlockedAltPauseScreen = false
		Lionblaster.PersistentData.Settings.unlockedMusicBox = false
		Lionblaster.PersistentData.Settings.completedMode91 = false
		Lionblaster.PersistentData.Settings.completedMode93 = false
		Lionblaster.PersistentData.Settings.completedMode91EX = false
		Lionblaster.PersistentData.Settings.completedMode93EX = false
		Lionblaster.PersistentData.Settings.isHardmode = false
		Lionblaster.PersistentData.Settings.singleHighScore91 = 0
		Lionblaster.PersistentData.Settings.singleHighScore93 = 0

		-- beastiary helper stuff
		Lionblaster.PersistentData.Settings.Beastiary = {}
		-- We populate this in the preloader... too much shit to write

		appendLog("notice	: persistent settings creation succeeded")
	end
	if love.filesystem.isFile('settings') then
		local str = love.filesystem.read('settings')
		Lionblaster.PersistentData.Settings = loadstring(Lionblaster.InstanceData.Classes.Utils.BubbleBabble:decode(str))()
	end
	if Lionblaster.PersistentData.Settings.version ~= nil then
		if Lionblaster.PersistentData.Settings.version == version then
			appendLog("notice	: persistent settings loading succeeded")
		else
			appendLog("warning	: incorrect version in persistent data, there may be issues")
		end
	else
		Lionblaster.PersistentData.Settings.version = version
		appendLog("notice	: no settings file found, using plain defaults, added version info")
	end

	-- multi.lua	->	MultiSettings
	do
		appendLog("notice	: setting persistent multiplayer setting defaults")

		Lionblaster.PersistentData.MultiSettings = {}
		--Lionblaster.PersistentData.MultiSettings.version = version -- risks false positive if a version param is not defined in the file
		Lionblaster.PersistentData.MultiSettings.general = {}
		Lionblaster.PersistentData.MultiSettings.general.playerSlots = 4
		Lionblaster.PersistentData.MultiSettings.general.timeLimit = 2400
		Lionblaster.PersistentData.MultiSettings.general.rounds = 2
		Lionblaster.PersistentData.MultiSettings.general.newLayoutPerRound = true

		Lionblaster.PersistentData.MultiSettings.general.startingLives = 3
		Lionblaster.PersistentData.MultiSettings.general.startingHealth = 1
		Lionblaster.PersistentData.MultiSettings.general.startingBombs = 1
		Lionblaster.PersistentData.MultiSettings.general.startingRange = 1
		Lionblaster.PersistentData.MultiSettings.general.startingSpeed = 1

		Lionblaster.PersistentData.MultiSettings.map = {}
		Lionblaster.PersistentData.MultiSettings.map.type = 'rectangular'
		Lionblaster.PersistentData.MultiSettings.map.width = 13
		Lionblaster.PersistentData.MultiSettings.map.height = 11
		Lionblaster.PersistentData.MultiSettings.map.data = {}
		Lionblaster.PersistentData.MultiSettings.map.data.seedLow = 0
		Lionblaster.PersistentData.MultiSettings.map.data.seedHigh = 0

		Lionblaster.PersistentData.MultiSettings.overtimePenalty = {}
		Lionblaster.PersistentData.MultiSettings.overtimePenalty.instandEnd = false
		Lionblaster.PersistentData.MultiSettings.overtimePenalty.fallingBlocks = 0.75
		Lionblaster.PersistentData.MultiSettings.overtimePenalty.pontanCount = 20

		Lionblaster.PersistentData.MultiSettings.bombs = {}
		Lionblaster.PersistentData.MultiSettings.bombs.bombMode = 'old'
		Lionblaster.PersistentData.MultiSettings.bombs.normalBombToggle = true
		Lionblaster.PersistentData.MultiSettings.bombs.areaBombToggle = false

		Lionblaster.PersistentData.MultiSettings.items = {}
		Lionblaster.PersistentData.MultiSettings.items.randomItemSpawns = false
		Lionblaster.PersistentData.MultiSettings.items.scoreOnlyPercentage = 0.175

		Lionblaster.PersistentData.MultiSettings.items.timeStopAffectPlayers = false
		Lionblaster.PersistentData.MultiSettings.items.timeStopPercentage = 0.175

		Lionblaster.PersistentData.MultiSettings.items.skullPercentage = 0.5
		Lionblaster.PersistentData.MultiSettings.items.allowedSkullEffects = {
			minSpeed = 0.75,
			maxSpeed = 0.67,
			minBombRange = 0.5,
			hasDiarrhea = 0.33,
			hasConstipation = 0.25,
			invertControls = 0.175,
			donFogOfWar = 0.05,
			turnIntoMob = 0.01
		}

		Lionblaster.PersistentData.MultiSettings.items.remotePercentage = 0.5
		Lionblaster.PersistentData.MultiSettings.items.bombKickPercentage = 0.33
		Lionblaster.PersistentData.MultiSettings.items.bombPushPercentage = 0.33
		Lionblaster.PersistentData.MultiSettings.items.invulPercentage = 0.01
		Lionblaster.PersistentData.MultiSettings.items.bombPassPercentage = 0.175
		Lionblaster.PersistentData.MultiSettings.items.sWallPassPercentage = 0.175
		Lionblaster.PersistentData.MultiSettings.items.rangeDownPercentage = 0.05
		Lionblaster.PersistentData.MultiSettings.items.rangeUpPercentage = 0.75
		Lionblaster.PersistentData.MultiSettings.items.rangeMaxPercentage = 0.25
		Lionblaster.PersistentData.MultiSettings.items.bombUpPercentage = 0.75
		Lionblaster.PersistentData.MultiSettings.items.bombMaxPercentage = 0.25
		Lionblaster.PersistentData.MultiSettings.items.speedUpPercentage = 0.5
		Lionblaster.PersistentData.MultiSettings.items.speedDownPercentage = 0.33
		Lionblaster.PersistentData.MultiSettings.items.lifeUpPercentage = 0.175
		Lionblaster.PersistentData.MultiSettings.items.healthUpPercentage = 0.25

		Lionblaster.PersistentData.MultiSettings.items.ptBombPercentage = 0.5
		Lionblaster.PersistentData.MultiSettings.items.hbBombPercentage = 0.5

		Lionblaster.PersistentData.MultiSettings.items.fireBombPercentage = 0.2
		Lionblaster.PersistentData.MultiSettings.items.iceBombPercentage = 0.2
		Lionblaster.PersistentData.MultiSettings.items.acidBombPercentage = 0.2
		Lionblaster.PersistentData.MultiSettings.items.elecBombPercentage = 0.2
		Lionblaster.PersistentData.MultiSettings.items.vortexBombPercentage = 0.2

		Lionblaster.PersistentData.MultiSettings.mobs = {}

		-- starting from the '91 game

		Lionblaster.PersistentData.MultiSettings.mobs.ballomCount = 2
		Lionblaster.PersistentData.MultiSettings.mobs.ekutopuCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.boyonCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.passCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.pomoriCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.terupyoCount = 0

		Lionblaster.PersistentData.MultiSettings.mobs.onilCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.gachaCount = 0

		Lionblaster.PersistentData.MultiSettings.mobs.uotanCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.bomaCount = 0

		Lionblaster.PersistentData.MultiSettings.mobs.minvoCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.bafaCount = 0

		Lionblaster.PersistentData.MultiSettings.mobs.flapperCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.pegiiCount = 0 -- shashakin?

		Lionblaster.PersistentData.MultiSettings.mobs.nagachamCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.korisukeCount = 0

		Lionblaster.PersistentData.MultiSettings.mobs.maronCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.ojinCount = 0

		Lionblaster.PersistentData.MultiSettings.mobs.pontanCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.kondoriaCount = 0

		-- '91 bosses

		Lionblaster.PersistentData.MultiSettings.mobs.aronCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.bubblesCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.warpmanCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.setsutoreCount = 0

		Lionblaster.PersistentData.MultiSettings.mobs.blackBomberCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.redBomberCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.blueBomberCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.greenBomberCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.yellowBomberCount = 0

		-- '93 game mobs not present in '91 one (unless they have a different color scheme here...) many names missing...

		--[[

		Lionblaster.PersistentData.MultiSettings.mobs.funyaCount = 0 -- one-eyed blob
		Lionblaster.PersistentData.MultiSettings.mobs.burolCount = 0 -- maron recolor
		Lionblaster.PersistentData.MultiSettings.mobs.rokkunCount = 0 -- rock-like mob, invulnerable when sleeping
		Lionblaster.PersistentData.MultiSettings.mobs.aomoriCount = 0 -- blue reptile-like pomori type

		Lionblaster.PersistentData.MultiSettings.mobs.banboCount = 0 -- big enemy, bounces around
		Lionblaster.PersistentData.MultiSettings.mobs.bomberwanCount = 0 -- doglike walking bomb; death explosion range = 3

		--

		Lionblaster.PersistentData.MultiSettings.mobs.mogudaCount = 0 -- clawed red thing, burrows in sand (restrict movement to special blocks? also for water creatures? :3)

		--

		Lionblaster.PersistentData.MultiSettings.mobs.asshiiCount = 0 -- seal
		Lionblaster.PersistentData.MultiSettings.mobs.asshiiEXCount = 0 -- slightly bluer, swpasser, faster

		Lionblaster.PersistentData.MultiSettings.mobs.roboBallomCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.roboTerupyoCount = 0



		-- '93 bosses

		Lionblaster.PersistentData.MultiSettings.mobs.diggerCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.petuniaCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.blastBatCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.elBaalCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.cockleTwinsCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.grumpusCount = 0

		Lionblaster.PersistentData.MultiSettings.mobs.MachineBlackBomberCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.redBomberBikerCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.blueBomberBikerCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.greenBomberBikerCount = 0
		Lionblaster.PersistentData.MultiSettings.mobs.yellowBomberBikerCount = 0

		--]]

		-- extra mobs i decided to add

		--Lionblaster.PersistentData.MultiSettings.mobs.trentCount = 0 -- dryad

		appendLog("notice	: persistent multiplayer setting creation succeeded")
	end
	if love.filesystem.isFile('multi.lua') then
		local str = love.filesystem.read('multi.lua')
		Lionblaster.PersistentData.MultiSettings = loadstring(str)()
	end
	if Lionblaster.PersistentData.MultiSettings.version ~= nil then
		if Lionblaster.PersistentData.MultiSettings.version == version then
			appendLog("notice	: persistent multiplayer settings loading succeeded")
		elseif Lionblaster.PersistentData.MultiSettings.version and Lionblaster.PersistentData.MultiSettings.version < version then
			appendLog("warning	: incorrect version in persistent data, there may be issues")
		else
			appendLog("warning	: persistent data version newer than game version, temporal paradoxes inbound")
		end
	else
		Lionblaster.PersistentData.MultiSettings.version = version
		appendLog("notice	: no multi settings file found, using plain defaults, added version info")
	end

	appendLog("notice	: setting gameMode")

	-- decide which game we'll open with after the preloader state
	if not Lionblaster.PersistentData.Settings.completedMode91
		or Lionblaster.PersistentData.Settings.completedMode93
	or not Lionblaster.PersistentData.Settings.is93Hardmode then
		Lionblaster.PersistentData.Settings.gameMode = '91'
	else
		Lionblaster.PersistentData.Settings.gameMode = '93'
	end

	appendLog("notice	: initializing the pre-scaled window...")

	local w = Lionblaster.PersistentData.Settings.width
	local h = Lionblaster.PersistentData.Settings.height

	-- Adjust window size; cascading tries.
	if Lionblaster.PersistentData.User.scale == 4 then
		if not love.window.setMode(w*4,h*4,{borderless = false, vsync = true, minwidth = w, minheight = (h-8)}) then Lionblaster.PersistentData.User.scale = 3 end
	end
	if Lionblaster.PersistentData.User.scale == 3 then
		if not love.window.setMode(w*3,h*3,{borderless = false, vsync = true}) then Lionblaster.PersistentData.User.scale = 2 end
	end
	if Lionblaster.PersistentData.User.scale == 2 then
		if not love.window.setMode(w*2,h*2,{borderless = false, vsync = true}) then Lionblaster.PersistentData.User.scale = 1 end
	end
	if Lionblaster.PersistentData.User.scale == 1 then
		if not love.window.setMode(w,h,{borderless = false, vsync = true}) then assert(1==0,"Error creating window!") end
	end

	appendLog("notice	: doing some final preliminary settings...")

	-- Disable textinput
	love.keyboard.setTextInput(false)

	-- Set some defaults that we need to do here because t.window was not a table in conf.lua
	love.window.setTitle('Lionblaster - A TG16/DOS Dyna + Clone')
	-- Icon will be hacked into the exe with resourcehacker when the game will be release-worty

	-- Set background color
	love.graphics.setBackgroundColor(0,0,0)

	-- Set default filter to nearest neighbour, since we don't want blurryness if we upscale
	love.graphics.setDefaultFilter('nearest', 'nearest', 8)

	-- Set default font to our custom font
	Lionblaster.InstanceData.Assets.gfx.defaultFont = love.graphics.newImageFont("gfx/font_tg16.png","abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ _<>.)(!?:0123456789&-@;#")
	love.graphics.setFont(Lionblaster.InstanceData.Assets.gfx.defaultFont)
	-- Set ingame score font; - is minus sign, & is infinity, @ is reserved
	Lionblaster.InstanceData.Assets.gfx.scoreFont = love.graphics.newImageFont("gfx/font_score.png","0123456789-&@")

	-- HACKTESTING
	Lionblaster.InstanceData.WindowCanvas = love.graphics.newCanvas()

	appendLog("notice	: registering events and switching to preloader...")

	-- Register events and call the preloader state; dev: call any other in the preloader's switch statement.
	-- Note: We call update, draw and quit from the main ones by hand; this way we can have both pre and post behaviours.
	local callbacks = {
	'errhand', 'focus', 'keypressed', 'keyreleased', 'textinput',
	'threaderror', 'visible', 'gamepadaxis', 'gamepadpressed',
	'joystickadded', 'joystickaxis', 'joystickhat', 'joystickpressed',
	'joystickreleased', 'joystickremoved'
	}

	LGS.GS.registerEvents(callbacks)
	LGS.GS.switch(LGS.Preloader)

end

-------------------------------------------------------------------------------

function love.update(dt)

	-- Temporary debug console addition
	if lovebird then lovebird.update() end

	-- This will be decreased by how much time the preloader took.
	Lionblaster.InstanceData.elapsedTime = Lionblaster.InstanceData.elapsedTime + dt 

	-- This updates regardless of gamestate.
	Lionblaster.InstanceData.Classes.AudioEngine:update(dt)

	-- Call gamestate update
	Lionblaster.InstanceData.GameStates.GS.current():update(dt)

end

function love.draw()

	love.graphics.clear()

	-- HACKTESTING
	Lionblaster.InstanceData.WindowCanvas:clear()
	love.graphics.setCanvas(Lionblaster.InstanceData.WindowCanvas)

	-- Scale the window before anything else
	--love.graphics.scale(Lionblaster.PersistentData.User.scale, Lionblaster.PersistentData.User.scale)

	-- Call gamestate draw
	Lionblaster.InstanceData.GameStates.GS.current():draw()

	-- HACKTESTING
	love.graphics.setCanvas()
	if Lionblaster.PersistentData.User.shader > 0 and Lionblaster.PersistentData.Shaders[Lionblaster.PersistentData.User.shader] then
		love.graphics.setShader(Lionblaster.PersistentData.Shaders[Lionblaster.PersistentData.User.shader].shader)
		--Lionblaster.PersistentData.Shaders[Lionblaster.PersistentData.User.shader].shader:send("textureSize", {Lionblaster.PersistentData.Settings.width*Lionblaster.PersistentData.User.scale,Lionblaster.PersistentData.Settings.height*Lionblaster.PersistentData.User.scale})
	end
	love.graphics.scale(Lionblaster.PersistentData.User.scale, Lionblaster.PersistentData.User.scale)
	love.graphics.draw(Lionblaster.InstanceData.WindowCanvas)
	love.graphics.setShader()

	-- if we're recording, save frames into the buffer
	-- note: will record the "last" frame, but whatever
	if Lionblaster.InstanceData.isRecording then
		Lionblaster.InstanceData.recordedFrames = Lionblaster.InstanceData.recordedFrames + 1
		Lionblaster.InstanceData.recordingBuffer[Lionblaster.InstanceData.recordedFrames] = {}
		Lionblaster.InstanceData.recordingBuffer[Lionblaster.InstanceData.recordedFrames].delta = love.timer.getDelta()
		Lionblaster.InstanceData.recordingBuffer[Lionblaster.InstanceData.recordedFrames].screenshot = love.graphics.newScreenshot()
		print("REC		: frame #",Lionblaster.InstanceData.recordedFrames,"dt: " .. Lionblaster.InstanceData.recordingBuffer[Lionblaster.InstanceData.recordedFrames].delta)
	end

end

do
local videoRecStartTime = 0
function love.keypressed(key, isrepeat)

	-- The current state's quit callback is hooked to this, handling the event per-state.
	-- TODO: check whether the state-specific or the global quit callback runs first, my guess is the former.
	if key == 'escape' then love.event.quit() end

	-- Scan for modified modules, and hotswap them
	if key == 'f3' then
		lurker.scan()
	end

	-- Take a screenshot and save it in the screenshot folder
	if key == 'f12' then
		if not love.filesystem.exists('screenshots') then
			love.filesystem.createDirectory('screenshots')
		end
		if love.filesystem.isDirectory('screenshots') then
			local t = love.filesystem.getDirectoryItems('screenshots')
			local scr = love.graphics.newScreenshot()
			local s = ''
			local c = #t + 1
			if c < 10 then
				s = '0000' .. c
			elseif c < 100 then
				s = '000' .. c
			elseif c < 1000 then
				s = '00' .. c
			elseif c < 10000 then
				s = '0' .. c
			else
				s = '' .. c
			end
			scr:encode('screenshots/lb_'.. s ..'.png')
			appendLog("events	: at ".. Lionblaster.InstanceData.elapsedTime ..", took screenshot number " .. s)
		end
	end

	-- Record a video ingame, F11 - toggles recording on and off, in the global update,
	-- it makes screenshots into a buffer, one per frame, then builds an animated png and saves it on stopping
	if key == 'f11' then
		if not Lionblaster.InstanceData.isRecording then
			Lionblaster.InstanceData.isRecording = true
			videoRecStartTime = Lionblaster.PersistentData.Settings.elapsedTime
			appendLog("events	: started recording at " .. videoRecStartTime)
		else
			Lionblaster.InstanceData.isRecording = false
			appendLog("events	: stopped recording at " .. Lionblaster.InstanceData.elapsedTime ..
				", recorded " .. #Lionblaster.InstanceData.recordingBuffer .. " frames, total recording time: " .. Lionblaster.InstanceData.elapsedTime - videoRecStartTime .. " seconds.")
			
			-- create apng (should be in another thread, shit's slow)
			-- export individual pngs for now
			if not love.filesystem.exists('movies') then
				love.filesystem.createDirectory('movies')
			end
			if love.filesystem.isDirectory('movies') then
				local t = videoRecStartTime + Lionblaster.InstanceData.elapsedTime -- unique.
				love.filesystem.createDirectory('movies/' .. t)
				for i=1,Lionblaster.InstanceData.recordedFrames do
					local path = 'movies/' .. t .. '/' .. i .. '.png'
					print(path)
					Lionblaster.InstanceData.recordingBuffer[i].screenshot:encode(path)
				end
			end

			-- reset buffers and counter
			Lionblaster.InstanceData.recordingBuffer = {}
			Lionblaster.InstanceData.recordedFrames = 0
		end
	end
end
end

function love.quit()

	-- Call gamestate quit; additionally, if true is returned, pass that along here.
	if Lionblaster.InstanceData.GameStates.GS.current():quit() then return true end

	-- Don't quit while the preloader is active
	if Lionblaster.InstanceData.GameStates.GS.current() ~= Lionblaster.InstanceData.GameStates.Preloader then

		appendLog("notice	: Finalizing... (love.quit / main.lua)")

		-- Add the elapsed time to the persistent value
		Lionblaster.PersistentData.Settings.elapsedTime = Lionblaster.PersistentData.Settings.elapsedTime + Lionblaster.InstanceData.elapsedTime

		-- Dump the persistent table into the relevant files.
		local success = love.filesystem.write('user.lua', Lionblaster.InstanceData.Classes.Utils.Serialize(Lionblaster.PersistentData.User))
		if success then appendLog("notice	: persistent user data serialization succeeded")
				   else appendLog("error	: persistent user data serialization failed...") end
		local success = love.filesystem.write('controls.lua', Lionblaster.InstanceData.Classes.Utils.Serialize(Lionblaster.PersistentData.ControlList))
		if success then appendLog("notice	: persistent controller data serialization succeeded")
				   else appendLog("error	: persistent controller data serialization failed...") end
		local success = love.filesystem.write('skin.lua', Lionblaster.InstanceData.Classes.Utils.Serialize(Lionblaster.PersistentData.Skin))
		if success then appendLog("notice	: persistent skin data serialization succeeded")
				   else appendLog("error	: persistent skin data serialization failed...") end
		local success = love.filesystem.write('multi.lua', Lionblaster.InstanceData.Classes.Utils.Serialize(Lionblaster.PersistentData.MultiSettings))
		if success then appendLog("notice	: persistent multiplayer settings serialization succeeded")
				   else appendLog("error	: persistent multiplayer settings serialization failed...") end
		local success = love.filesystem.write('settings', Lionblaster.InstanceData.Classes.Utils.BubbleBabble:encode(Lionblaster.InstanceData.Classes.Utils.Serialize(Lionblaster.PersistentData.Settings)))
		if success then appendLog("notice	: persistent settings serialization succeeded")
				   else appendLog("error	: persistent settings serialization failed...") end

		-- if user started recording but hasn't stopped it, stop it and export, done via directly calling love.keypressed with the recording key
		if Lionblaster.InstanceData.isRecording then
			love.keypressed('F11', false)
		end

		appendLog("Shutting down...")

		-- no memleaks...

		appendLog("LOG ENDED	: " .. os.date("%c", os.time()), false)
	end
end

-------------------------------------------------------------------------------

function love.graphics.setAlpha(alpha,blend)
	-- Just for better comprehendability in the game states
	local r,g,b,a = love.graphics.getColor()
	if blend then
		love.graphics.setColor(r,g,b,(blend*alpha)+((1.0-blend)*a))
	else
		love.graphics.setColor(r,g,b,alpha)
	end
end

do
	local last = love.timer.getTime() -- microseconds
	function appendLog(str,cli)
		-- Append time from last appendLog call to the log
		local curr = love.timer.getTime() -- microseconds
		local dt = curr - last
		dt = (math.floor(dt*1000000)/1000000)
		-- modify the spacings for timings
		-- AAxx.yyBB -> A*x* 9 chars, . 1 char, y*B* 6 chars
		local pre, delim, post = string.match((""..dt), "(%d+)(%.+)(%d*)")
		if string.len(pre) < 9 then
			for i=1, 9-pre:len() do
				pre = ' ' .. pre
			end
		end
		if string.len(post) < 6 then
			for i=1, 6-post:len() do
				post = post .. '0'
			end
		end
		local sdt = pre .. delim .. post
		-- Create/Open the log file, and append str to it as a line
		love.filesystem.append('log.txt', sdt .. "	: " .. str .. "\n")
		-- also print it out if cli is not false (can be nil though, default behaviour is to print it)
		if cli == nil or cli == true then 
			print(str)
		end
	end
end

function drawDebug()
	Lionblaster.InstanceData.Classes.Utils.Color.push()
	love.graphics.setColor(255,255,255,255)

	local delta = love.timer.getAverageDelta()
	love.graphics.print(string.format("Average frame time: %.3f ms", 1000 * delta), 0, 0)

	love.graphics.print("Delta: " .. love.timer.getDelta(), 0, 8)

	love.graphics.print("F P S: " .. love.timer.getFPS(), 0, 16)

	local ms = math.floor((Lionblaster.InstanceData.elapsedTime *     100) % 100)
	if ms < 10 then ms = '0' .. ms end
	local s =  math.floor( Lionblaster.InstanceData.elapsedTime %      60)
	if s < 10 then s = '0' .. s end
	local m =  math.floor((Lionblaster.InstanceData.elapsedTime /      60) %  60)
	if m < 10 then m = '0' .. m end
	local h =  math.floor((Lionblaster.InstanceData.elapsedTime /    3600) %  60) % 24
	if h < 10 then h = '0' .. h end
	local d =  math.floor( Lionblaster.InstanceData.elapsedTime /   86400)
	love.graphics.print("Elapsed Time: " .. d .. '-' .. h .. ':' .. m .. ':' .. s .. '.' .. ms , 0, 24)

	love.graphics.print("Current Time: " .. os.date('X-%H:%M:%S'), 0, 32)

	love.graphics.print("R: " .. Lionblaster.InstanceData.GameStates.GS.current().transitions.currentRGBA[1],   0, 40)
	love.graphics.print("G: " .. Lionblaster.InstanceData.GameStates.GS.current().transitions.currentRGBA[2],  50, 40)
	love.graphics.print("B: " .. Lionblaster.InstanceData.GameStates.GS.current().transitions.currentRGBA[3], 100, 40)
	love.graphics.print("A: " .. Lionblaster.InstanceData.GameStates.GS.current().transitions.currentRGBA[4], 150, 40)

	Lionblaster.InstanceData.Classes.Utils.Color.pop()
end

function recursiveEnumerate(folder, fileTree)
    local lfs = love.filesystem
    local filesTable = lfs.getDirectoryItems(folder)
    for i,v in ipairs(filesTable) do
        local file = folder.."/"..v
        if lfs.isFile(file) then
            fileTree = fileTree.."\n"..file
        elseif lfs.isDirectory(file) then
            fileTree = fileTree.."\n"..file.." (DIR)"
            fileTree = recursiveEnumerate(file, fileTree)
        end
    end
    return fileTree
end

function bake(s,d,simpleCopy) -- imageData, Canvas, [boolean]

	-- replace later with shader code to make it realtime (and make invulnerability and skull effect easier to do)

	simpleCopy = simpleCopy or false

	-- save out stuff we need to restore later
	love.graphics.push()
	love.graphics.origin()
	local canvas = love.graphics.getCanvas()
	local blendMode = love.graphics.getBlendMode()
	local r,g,b,a = love.graphics.getColor()

	-- create an image from the source
	local S = love.graphics.newImage(s) --Lionblaster.InstanceData.Assets.gfx.spriteMaps.players.playerComponents

	-- if simpleCopy, then just draw the image onto the canvas,
	-- else colorize every layer (onto a temp canvas), then draw them out to the dest canvas
	if simpleCopy then
		love.graphics.setCanvas(d)
		love.graphics.setBlendMode('alpha')
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(S,0,0)
	else
		-- some helpful datas
		local T = {}
		T[ 1] = {} T[ 1].y = 16 T[ 1].c = Lionblaster.PersistentData.Skin.outline
		T[ 2] = {} T[ 2].y =  9 T[ 2].c = Lionblaster.PersistentData.Skin.pomPom
		T[ 3] = {} T[ 3].y = 12 T[ 3].c = Lionblaster.PersistentData.Skin.hood
		T[ 4] = {} T[ 4].y =  6 T[ 4].c = Lionblaster.PersistentData.Skin.skinTone
		T[ 5] = {} T[ 5].y = 13 T[ 5].c = Lionblaster.PersistentData.Skin.arms
		T[ 6] = {} T[ 6].y =  8 T[ 6].c = Lionblaster.PersistentData.Skin.robe
		T[ 7] = {} T[ 7].y = 15 T[ 7].c = Lionblaster.PersistentData.Skin.belt
		T[ 8] = {} T[ 8].y =  7 T[ 8].c = Lionblaster.PersistentData.Skin.beltBuckle
		T[ 9] = {} T[ 9].y = 10 T[ 9].c = Lionblaster.PersistentData.Skin.gloves
		T[10] = {} T[10].y = 14 T[10].c = Lionblaster.PersistentData.Skin.legs
		T[11] = {} T[11].y = 11 T[11].c = Lionblaster.PersistentData.Skin.shoes
		T[12] = {} T[12].y = Lionblaster.PersistentData.Skin.eyeStyle T[12].c = {255,255,255,255}

		-- temp colorizer canvas
		local D = love.graphics.newCanvas(d:getWidth(), d:getHeight())

		-- temp quad
		local Q = love.graphics.newQuad(0, 0, S:getWidth(), 32, S:getWidth(), S:getHeight())

		-- temp :3
		-- local N = 'dokyun!'

		for i=1,12 do
			love.graphics.setCanvas(D)
			Q:setViewport(0, T[i].y*32, s:getWidth(), 32)
			love.graphics.setBlendMode('additive')
			love.graphics.setColor(T[i].c)
			love.graphics.draw(S,Q,0,0)
			love.graphics.setCanvas(d)
			love.graphics.setBlendMode('alpha')
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw(D,0,0)
			D:clear()
		end
	end

	-- restore stuff we saved
	love.graphics.setColor(r,g,b,a)
	love.graphics.setBlendMode(blendMode)
	love.graphics.setCanvas(canvas)
	love.graphics.pop()

	return --[[ the ]] d

end