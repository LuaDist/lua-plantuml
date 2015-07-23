#!/usr/bin/env lua
-------------------------------------------------------------------------------
-- LuaPlantUML
-- @release 2015/0X/0X 11:49:00, Robert Karasek
-------------------------------------------------------------------------------
local plant=require "luaplantuml";
local getopt=require("alt_getopt");
local lfs = require"lfs"

---
--% Function search directory and directories inside.
--% Process all functions for each Lua file.
--@ path (string) path to directory or file.
--@ settings (table) arguments for PlantUML and generate process.
--: (table, nil) Return full table with function name(.name), path to that function diagram(.path), and its PlantUML syntax string(.uml_string).
function search_dir(path, settings)

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local selected_file = path .. '/' .. file
			local check_file = lfs.attributes(selected_file)

			if check_file.mode == "directory" then
				extended_path = selected_file .. '/'
				extended_path = string.gsub(extended_path, settings.dir_path, '')
			end 

			settings.extended_path = extended_path

			if check_file.mode == "file" and string.match(selected_file, '.lua$') then 			-- if .lua file
				settings.current_file = selected_file
				local read_file,ie=io.open(selected_file)

				plant.process_text(read_file:read("*all"), settings) -- do all process for file
				read_file:close()
			end
	
			local attr = lfs.attributes(selected_file)
			if attr.mode == "directory" then
				search_dir(selected_file, settings) 	-- recursive search again
			end
		end
	end
end


local function usage_info(args)
	print("\nUsage: "..arg[0]..
	[[ [-p <path to plantUML>] [-d <output dir path>] [-f] [-t]  <input file>

	LuaPlantUML is module for creating UML diagrams from Lua source codes. It works
	with PlantUML (http://plantuml.sourceforge.net/) and needs formatted comments
	or file with PlantUML syntax. For parsing 'luametrics' module is needed.
	Create '.wsd' file with PlantUML syntax for every parsed source code.
	Save generated UML diagrams to "uml_files" folder. On input could be
	single file or directory with source files.

Arguments:
	<input file> 
	-p,	path to plantUML (default search home directory for "plantuml.jar")
	-d,	<path> where to save UML diagrams (default is directory with input files)
	-f,	<format> format of files (default is svg) could be png, atxt(ascii art), utxt (ascii with UTF-8), latex
	-t,	enable store temporary files (delete by default)
	-w,	enable create wsd file with parsed PlantUML syntax for each source file
	]]);
end

local settings = {} 	--main table for all input arguments

if(#arg<1) then
	usage_info(arg);
	return nil
end

optarg,optind = alt_getopt.get_opts(arg,"p:d:f:htw",settings);


if optarg['p'] ~= nil then				
	settings.plantuml_path  = optarg['p'] .. " %s" 						-- plantuml.jar path
else
	settings.plantuml_path = os.getenv("HOME") .. "/plantuml.jar %s" 	-- if empty look for /home/user/ dir
end

-- specified format
if optarg['f'] ~= nil then
	settings.file_format = optarg['f']							-- format of not specified files
else
	settings.file_format = "svg"								-- 'svg' is default
end

settings.dir_path = optarg['d'] 			-- where to generate diagrams / if empty save to current dir
settings.del_temp = optarg['t'] 			-- if on input then temporary files will be NOT deleted 
settings.current_file = arg[optind] 		-- name of current file in process(parsing, generating...) 
settings.extended_path = "" 				-- save path to source file/s, needed when creating folder tree structure to diagrams
settings.wsd = optarg['w'] 				-- generate .wsd file (with parsed PlantUML syntax) for source file

if(optind<#arg+1 and not optarg['h']) then
	
	local file,ie=io.open(arg[optind]);
	local output = {}
	local attr = lfs.attributes(arg[optind])

	if(not file) then
		print("ERROR: cannot open file " .. arg[optind] .. ": " .. ie);
		return nil,ie
	end

	if attr.mode == "directory" then 			-- if directory
		if settings.dir_path == nil then 		-- if no '-d' and path then parse path from file
			settings.dir_path = lfs.currentdir() .. '/'
		end	
		search_dir(arg[optind], settings) 		-- search directory for files and generate diagrams for each file
	else										-- if just one source file
		if settings.dir_path == nil then 		-- if no '-d' and path then parse path from file
			settings.extended_path = string.gsub(arg[optind], '.%w*$', '') .. '/' 		-- dir was typed

			settings.dir_path = lfs.currentdir() .. '/'
			output = plant.process_text(file:read("*all"), settings); 					-- start process for file
		else
			settings.extended_path = string.gsub(arg[optind], '.%w*$', '') .. '/'		-- for save path to file
			output = plant.process_text(file:read("*all"), settings); 					-- start process for file
		end 
	end

	file:close()
else
      usage_info(arg);
end