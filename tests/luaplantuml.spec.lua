local plantuml = require "luaplantuml.generate_uml"
local lfs = require "lfs"

describe("Initialization", function ()
	it("Check modules", function ()
		assert.is_not_nil(plantuml)
		assert.is_not_nil(lfs)
	end)
end)


local comment = [[
@startuml
 e1->b1:zactest request
 e1<-b1:zactest response
 @enduml

@startuml{"fileName":"FIRSTmyimage.svg", "tempfileName":"./uml_files/NaHodNy", "fileType":"svg"}
 x1-->y1
 x1<---y1
 @enduml

 @startuml{"fileType":"utxt"}
 c1->b1:test request
 c1<-b1:test response
 @enduml

@startuml{"fileName":"myyypicture.svg","fileType":"svg"}
 x1-->y1
 x1<---y1
 @enduml

@startuml{"fileName":"AAimage2.png","fileType":"png"}
 x1-->y1
 x1<---y1
 @enduml

 @startuml{"fileType":"atxt"}
 c1->b1:test request
 c1<-b1:test response
 @enduml

@startuml{"fileName":"trylatex.tex","fileType":"latex"}
 x1-->y1
 x1<---y1
 @enduml
]]


local settings = {}

settings.plantuml_path = "/home/roboo/plantuml2.jar %s"
settings.dir_path = "./"
settings.file_format = "svg"
settings.extended_path = ""

-- lfs.mkdir("./uml_files/")

-- local file=io.open("/home/roboo/LUA/umltest/dakydir/uml3.lua", "w+") 	--_ create file with parsed PlantUML syntax, "w+" clear if exists
-- file:close()
local paths_to_diagram = {}

local diagram_results = {}

describe("Compare tables", function()
	for i=1, 7 do
		paths_to_diagram[#paths_to_diagram+1] = {}
		paths_to_diagram[#paths_to_diagram].path = nil
		paths_to_diagram[#paths_to_diagram].uml_string = nil
		diagram_results[#diagram_results+1] = {}
		diagram_results[#diagram_results].path = nil
		diagram_results[#diagram_results].uml_string = nil
	end
	it("has tests2", function()
		assert.same(paths_to_diagram, diagram_results)  	
	end)
end)


describe("Generate", function()
	it("generates diagrams", function()
		finally( function() diagram_results = plantuml.generate_prepare(comment, paths_to_diagram, settings) end)
	end)
end)


describe("Check generated file paths with paths from table", function()
  it("compares same paths and names", function()
	

	local end_position

	local start_position = string.find(comment, "@startuml")
	if start_position then
		_, end_position = string.find(comment, "@enduml", start_position+1)
	end

	for i=1, 7 do
		--_ set to first PlantUML syntax
		local preStr = string.sub(comment, 1, start_position-1)
		local postStr = string.sub(comment, end_position+1)

		local uml_string = plantuml.get_uml_string(comment, start_position, end_position)
		assert.same(uml_string.gsub(uml_string, "{.*}", ""), diagram_results[i].uml_string)
		--_ move to next PlantUML commet
		comment = preStr .. postStr
			
		start_position = string.find(comment, "@startuml", #preStr+1)
		if start_position then
			_, end_position = string.find(comment, "@enduml",start_position+1)
		end
	end


	-- for _,v in ipairs(diagram_results) do 
	-- 	print(v.uml_string , )
	-- end

	for file in lfs.dir("./uml_files") do
	if file ~= "." and file ~= ".." then
		local f = "./uml_files"..'/'..file

		for _,v in ipairs(diagram_results) do
			if v.path == f then
				print("FOUND " .. v.path .. " -> " .. f )
				assert.same(v.path, f)
				break
			end
		end
	end
	end
end)
end)


describe("Remove", function()
	it("remove  generated files directory (uml_files)", function()
		os.execute("rm ./uml_files/ -R")
	end)
end)

