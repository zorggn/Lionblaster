--[[
	Z-Framework
	by zorg
	@2014
--]]

--[[Game Directory Structure]]--

BIN		-- This is where main.lua and conf.lua resides, also the root of a .love file
	DAT	-- Assets go in this directory tree
		AMB -- Ambience Tracks (this can be merged with bgm though...)
		BGM -- Background Music
		FON -- Fonts
		GFX -- Graphics, that is, Images
		MID -- MIDI score
		SFX -- Sound Effects
		VID -- Videos
		VOX	-- Voice Recordings
	SRC	-- Code goes in this directory tree
		ANI -- Animation scripts
		GST -- Gamestates, for cleaner, non-global code
			GAME
			MENU
			....
		LIB	-- External libraries used by the game
		...

USR		-- The user's game folder, where the game can read and write files; the directory structure is created on first startup
	HSC -- High Scores
	INI	-- Saved Settings
	LOG	-- Recorded Logs
	LNG -- Languages (The default is copied on the first startup)
	MOD	-- Mods; if the game supports them
		LOADED.LUA -- Defines the load order of the mods
		*.ZIP	-- Zip-archived mods
	MOV	-- Recorded Sequences
		YYYYMMDDHHMMSSMM	-- Folders with the recording's beginning timestamp as the name
			DELTAS.LUA	-- Which frame had how much dt
			########	-- Image files named after the frame id, to be converted to a video format later.
	RPL	-- Replay files
	SAV	-- Save files
	SCR	-- Screenshots

--[[Call Order]]--

	-- love c code
	-- conf.lua configurations table
	--------------
	-- main.lua chunk
	-- love.run function
	-- love.load function (called by love.run, before the game loop part of it)
	--------------
	-- love callbacks (update, draw, etc...) (called by love.run, inside the game loop part of it)

--[[Framework Modules]]

	-------------- 

	-- GameStates	- using hump.gamestates, for code grouping.
	-- Windows		- for view instancing, and whatever else that might need it
		-- viewport + camera + lightworld

	-------------- Singletons

	-- Audio		- aural stuff handler; multiple dynamic loop point support, sound instancing support (, with 0.9.1+, realtime soundgen support)
	-- Window		- 
	-- Textbox		- Text library handling many features required in games, limiting text, scrolling text, auto-scrolling, per-character style, etc.
	-- ControlMap	- Handles mapping between internal representation control events and input from external controllers (incl. mouse and keyboard)
	-- InputMap		- Handles mapping of controllers across systems, and fixing anomalous shit with them caused by stupid drivers
	-- Events		- Sends, Receives, Stores, Imports, Exports events and event lists, highly customizable (read: bare implementation)
	-- Net Code		- "As long as it works..."

--]]


