module ("luaplantuml", package.seeall)

-- @startuml
-- title LuaPlantUML module hierarchy

-- start
-- partition luaplantuml_script {
-- if (found plantuml.jar?) then (yes)
-- 	:check all arguments;
-- 	:search for all .lua files;
-- else (no)
-- 	stop
-- endif
-- }	

-- partition init {
-- :start process;
-- note left
-- 	require luametrics
-- end note
-- while (parse global or function comments)
-- if () then (global)
-- 	:create paths_to_diagram keys with name "global";
-- else (function)
-- 	:create paths_to_diagram keys with function name;
-- endif
-- endwhile

-- if (argument -w?) then (yes)
-- 	:create wsd file;
-- 	note left
-- 		"name of file".wsd - contains all parsed
-- 		comments with PlantUML syntax
-- 	end note
-- else (no)
-- endif
-- }

-- partition generate_uml {
-- :generate folders for diagrams;
-- while (search in parsed PlantUML comments)
-- :parse comment by comment to get one full PlantUML string;
-- :check arguments;
-- note left
-- 	if format was typed,
-- 	then set this format for all diagrams
-- end note

-- :check inner comment {};
-- note left
-- 	these comments has higher priority
-- 	than arguments, for example it will
-- 	replace format in argument
-- end note

-- :add arguments for file types to plantuml.jar path;
-- :create temporary file with parsed or generated name;
-- :store these informations in table paths_to_diagram;
-- :generate final diagram image;
-- endwhile
-- }
-- stop

-- legend
-- paths_to_diagram is table where we store all relevant informations
-- paths_to_diagram[position].name 		name of function or "global"
-- paths_to_diagram[position].path 		path to generated image of diagram
-- paths_to_diagram[position].uml_string 	PlantUML syntax string
-- this module requires lfs, metrics, getopt, socket.http, mime
-- endlegend
-- @enduml

local luaplantuml=require("luaplantuml.generate_uml");
local metrics = require "metrics"

local comment = "" 			--_ temporary variable for continuous saving parsed syntax 
local comment_ends = nil 	--_ "switch" after full parse of PlantUML syntax (from PlantUML start and end annotations) we could create keys in table "paths_to_diagram"
local final_syntax = "" 		--_ final parsed PlantUML syntax

--_ store function names, path to function diagram (or global diagram (name = global)) and its syntax.
--_ [position].name / [position].path / [position].uml_string
local paths_to_diagram = {}


---
--% The main parse funcion. Parse PlantUML syntax from LUA comments and concat it together for each file on input.
--% It is possible to parse one global PlantUML syntax and syntax from functions comments
--@ ast (table) AST of source file
--@ check (number) just like "switch" between parsing syntax or continue in search. Parse from PlantUML start and end annotations
--: (string,nil) Return a string with parsed PlantUML syntax from whole file
local function parse_util(ast, check)
	
	--_ set keys in table with name of the function, path to diagram and uml string syntax
	for _,v in ipairs(ast.data) do
		parse_util(v, check) 	--_ recursive call

		if (v.text == "require" or v.text == "module") and comment_ends == 1 then
			
			--_ create keys for global PlantUML comment
			paths_to_diagram[#paths_to_diagram+1] = {}
			paths_to_diagram[#paths_to_diagram].name = "global"
			paths_to_diagram[#paths_to_diagram].path = nil
			paths_to_diagram[#paths_to_diagram].uml_string = nil

			comment="" 		--_ clear comment for next parsing
			comment_ends = 0

		elseif v.name ~= nil and comment_ends == 1 then
			
			--_ create keys for function PlantUML comment
			paths_to_diagram[#paths_to_diagram+1] = {}
			paths_to_diagram[#paths_to_diagram].name = v.name
			paths_to_diagram[#paths_to_diagram].path = nil
			paths_to_diagram[#paths_to_diagram].uml_string = nil

			comment = ""
			comment_ends = 0
		end
		
		if(v.tag == "COMMENT") then 					--_ search for PlantUML syntax in comments

			if(string.match(v.text, "@startuml")) then 	--_ where PlantUML tag starts 
				check = 1 									--_ start parsing lines
			end

			if(check == 1) then
				comment = comment .. string.gsub(v.text, '^%-%-+(%s*)', '%1') .. '\n' 	--_ parse one line of PlantUML comment ('\n' needed for plantuml.jar)
			end
			
			if(string.match(v.text, "@enduml")) then		--_ if we found last line of PlantUML syntax
				check = 0 									--_ stop parsing lines
				comment_ends = 1 						--_ we readed whole PlantUML syntax from comment, now we store keys in table "paths_to_diagram"
				comment = string.gsub(comment, '%[(=*)%[(.-)%]%1%]%-*', '%2') --_ if block comment remove "blocks"
				
				final_syntax =  final_syntax .. comment 	--_ and join to final syntax
			end
		end
	end

	return final_syntax
end


-- @startuml
-- participant process_text #99FF99 
-- ->process_text:file, settings
-- metrics.processText <- process_text:file
-- metrics.processText -> metrics.processText:create AST
-- metrics.processText -> process_text:ast_of_file

-- process_text -> parse_util:ast_of_file,0
-- parse_util -> parse_util:parse and concat\nPlantUML syntax strings
-- parse_util -> process_text:final_syntax
-- process_text -> process_text:parsed=final_syntax

-- process_text -> luaplantuml.generate_prepare:parsed, paths_to_diagram, settings
-- @enduml
---
--% Function create .wsd file with PlantUML syntaxes to specific source file.
--% The name of file is same as source and creates it in the same directory.
--@ file (string) read source file.
--@ settings (table) arguments for PlantUML and generate process.
--: (table, nil) Return full table with function name(.name), path to that function diagram(.path), and its PlantUML syntax string(.uml_string).
local function process_text(file, settings)
	local parsed = parse_util(metrics.processText(file), 0)		--_ parse PlantUML syntax from files
	final_syntax = ""  				--_ clear if reading more files else we will be generating same diagrams over and over again

	if parsed ~= nil and settings.wsd ~= nil then
		local wsd_file=io.open(string.gsub(settings.current_file, '.%w*$', '.wsd'), "w+") 	--_ create file with parsed PlantUML syntax, "w+" clear if exists

		wsd_file:write(parsed)	--_ write that syntax to file
		wsd_file:close()
	end

	--_ go to do main functions to generate images and full main table 'paths_to_diagram'
	luaplantuml.generate_prepare(parsed, paths_to_diagram, settings)
	
	return paths_to_diagram
end


return {
	process_text = process_text,
	parse_util = parse_util
}



