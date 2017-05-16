module ("luaplantuml.generate_uml", package.seeall)

local lfs = require "lfs"

--_ needed for temp files
local bOk, http   = pcall( require, "socket.http")
local mime        = nil
if bOk == false then
	http = nil
else
	bOk, mime   = pcall( require, "mime")
	if bOk == false then
		mime = nil
	end
end

local final_path_temp

---
--% Function for better PlantUML syntax strings find.
--@ comment (string) string of PlantUML syntax
--@ start_position (number) start position of PlantUML syntax
--@ end_position (number) end position of PlantUML syntax
--: (string,nil) Return one full PlantUML syntax string.
local function get_uml_string(comment, start_position, end_position)
	local uml_string = string.sub(comment, start_position, end_position) -- UML definition text
	return uml_string
end

---
--% The main generate function. Generate UML diagrams from PlantUML syntax ('uml_string'). Check plantuml path, file format and temporary filename.
--% It is possible to parse one global PlantUML syntax and syntax from functions comments
--@ uml_string (string) string of PlantUML syntax
--@ paths_to_diagram (table) main table store function names, path to function diagram and its PlantUML syntax.
--@ settings (table) arguments for PlantUML and generate process.
local function generate_uml(uml_string, paths_to_diagram, settings)
	local final_path = final_path_temp
	local file_name = nil
	local uml_filename_temp = nil
	
	local plantuml_path = settings.plantuml_path 	--_ set up path for PlantUML generator
	local fileType = settings.file_format				--_ set up file format
	
	local save_temp = settings.del_temp			--_ '-t' for store temporary files, nil for delete temporary files
														--TODO maybe make some names for temporary files
		
	--_ set path for temporary files
	local temp_file_path = os.tmpname()	--_ generate temporary file where we write one uml syntax string (e.g. "/tmp/lua_rDKO80")
	local temp_file = string.sub(temp_file_path, 6)
	temp_file_path = settings.dir_path .. "uml_files/" .. temp_file


	--_ optional attributes in a "json" format comment
	if string.sub(uml_string, 10,10) == "{" then
		local optional_comment = string.match( uml_string, ".*{(.*)}" )

		--_ remove the {...} from UML string
		uml_string = string.gsub( uml_string, ".*}", "@startuml" )
			
		--_ this defines a different file type svg(default) / png / atxt / utxt
		fileType = string.match(optional_comment, '.-"fileType"%s-:%s-"(.-)".-') or fileType

		--_ check if file name is given "fileName":"path"
		file_name = string.match(optional_comment, '.-"fileName"%s-:%s-"(.-)".-')

		--_ check if the temporary file path is given
		--temp_file_path = string.match(optional_comment, '.-"tempfileName"%s-:%s-"(.-)".-') or temp_file_path
	end

	--_ update PlantUML path for miscellaneous file formats	
	if(fileType == "svg") then
		plantuml_path = plantuml_path .. " -tsvg"
	end
			
	if(fileType == "atxt") then
		plantuml_path = plantuml_path .. " -txt"
	end

	if(fileType == "utxt") then
		plantuml_path = plantuml_path .. " -utxt"
	end

	if(fileType == "latex") then
		plantuml_path = plantuml_path .. " -tlatex"
	end

	--_ open temporary file to write PlantUML syntax
	local write_temp_file = io.open(temp_file_path, "w")
	
	--_ make path for images with name or with generated temporary names
	if file_name then
		final_path = final_path .. file_name	--_ name found in "json" comment, concat it to path
	else
		final_path = final_path .. string.format("%s.%s", temp_file, fileType)
	end

	--_ set paths and uml syntax to diagrams for function names in table 'paths_to_diagram'
	for _, v in ipairs(paths_to_diagram) do
		if v.path == nil then
			v.path = final_path
			v.uml_string = uml_string
			break
		end
	end

	--_ generate UML diagram image from temporary file
	if write_temp_file then
		
		local temp_path_save	 				--_ path to temporary file
		write_temp_file:write( uml_string ) 	--_ write the pure PlantUML syntax to a file
		write_temp_file:close()



		--_ this will generate image
		os.execute( string.format("java -jar %s %s", plantuml_path, temp_file_path ) )

		temp_path_save = string.format("%s.%s", temp_file_path, fileType)

		--_ move image from tmp folder to our destination
		os.rename( temp_path_save, final_path)
		
		if save_temp == nil then				--_ remove temp file if '-t' options was NOT typed
			os.remove(temp_file_path)
		end
	else
		local errStr = "Error creating UML temp file"
		print(errStr)
	end
end


-- @startuml
-- Participant process #99FF99 
-- ->process:comment, paths_to_diagram, settings
-- process -> process:set to position of PlantUML\nsyntax block 
-- process -> get_uml_string:comment, start/end_position
-- get_uml_string -> process:uml_string
-- process -> generate_uml:uml_string, paths_to_diagram, settings
-- generate_uml -> generate_uml:parse nested comment in {}
-- generate_uml -> generate_uml:check formats
-- generate_uml -> generate_uml:create temporary files
-- generate_uml -> generate_uml:fill paths_to_diagram
-- generate_uml -> generate_uml:GENERATE diagram
-- @enduml
---
--% Function set position to one full PlantUML syntax block and start generating diagram with generate_uml.
--@ comment (string) string of PlantUML syntax.
--@ paths_to_diagram (table) main table store function names, path to function diagram and its PlantUML syntax.
--@ settings (table) arguments for PlantUML and generate process.
local function process(comment, paths_to_diagram, settings)
	local end_position

	--_ move to start of PlantUML comment
	local start_position = string.find(comment, "@startuml")
	if start_position then
		_, end_position = string.find(comment, "@enduml", start_position+1)
	end

	while start_position and end_position do
		--_ set to first PlantUML syntax
		local preStr = string.sub(comment, 1, start_position-1)
		local postStr = string.sub(comment, end_position+1)

		local uml_string = get_uml_string(comment, start_position, end_position)
		generate_uml(uml_string, paths_to_diagram, settings)

		--_ move to next PlantUML commet
		comment = preStr .. postStr
			
		start_position = string.find(comment, "@startuml", #preStr+1)
		if start_position then
			_, end_position = string.find(comment, "@enduml",start_position+1)
		end
	end
end

---
--% Main function, creates directory for diagrams, and start process with generating UML diagrams.
--@ comment (string) string of PlantUML syntax.
--@ paths_to_diagram (table) main table store function names, path to function diagram and its PlantUML syntax.
--@ settings (table) arguments for PlantUML and generate process.
local function generate_prepare(comment, paths_to_diagram, settings)

	--_ set up where generated UML diagrams will be stored
	if (settings.dir_path ~= nil) then

		lfs.mkdir(settings.dir_path .. "uml_files/")
		final_path_temp = settings.dir_path .. "uml_files/"

		local temp = lfs.currentdir()
		lfs.chdir( final_path_temp )

		--_ create directories in output dir
		for text in settings.extended_path:gmatch( "[^/]+" ) do
			lfs.mkdir( text ) 
			lfs.chdir( text )
		end

		final_path_temp = final_path_temp .. settings.extended_path
		lfs.chdir(temp)
	end

	process(comment, paths_to_diagram, settings)
-- for _, v in ipairs(paths_to_diagram) do
-- 			print(' CESTA: ' .. v.path .. '  STRING: ' .. v.uml_string)
-- 		end
return paths_to_diagram
end


return {
	generate_prepare = generate_prepare, 
	get_uml_string = get_uml_string
}
