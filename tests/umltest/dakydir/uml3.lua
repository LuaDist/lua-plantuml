--[[#
# LuaLiterate

LuaLiterate is a literate programming module for LuaDocer. Is't highly inspired by [Locco](http://rgieseke.github.io/locco/),
but has some interesting improvements.

## Specific features

*   Block comments
*   Block comments folding
*   Function cross-references

### Block comments

Block comments are used to comment wider part of code than just one line or loop.
Comments are described by grammar and have following syntax:

    --^ `name` description
        <code>
    --v `name`

*Name* describes block in max. few words.
*Description* is optional. It can be as long as needed (but only on the same line) to explain more specificaly what the block does.

Code demaked by block comments has no lenght limitations and can contain even nested block comments.

### Block comments folding

Code folding, or in this case block comments folding, brings the option to fold not interesting parts of code.
In case of block comments, the block comment and whole its content is folded into one line, showing name of the block.
When running with cursor over the block name, the block description appears on the right.
Code is folded and unfolded by double-clicking on the desired block.

### Function cross-references

This is great feature. It is inspired by IDEs such as Eclipse. When running cursor over the function call, it show a docstring describing that function.
When clicking on the function call, the documentation of file containg the desired function opens and scrolls to the begining of the function.

## Dependencies

LuaLiterate directly depends on *luapretty* module. It also depends on abstract syntax tree (AST) which in this case needs to have same structure as the one created by the *luametrics*.


--]]

-------------------------------------------------------------------------------
-- Interface for literate module
-- @release 2013/03/18, Michal Juranyi
-------------------------------------------------------------------------------

--- @startuml
--- e1->b1:zactest request
--- e1<-b1:zactest response
--- @enduml
module("comments",package.seeall)
local print  = print

local explua = require"comments.explua"		-- parser = "explua"
local luadoc = require"comments.luadoc"		-- parser = "luadoc"
local literate = require"comments.literate"		-- parser = "literate"
local custom = require"comments.custom"		-- parser = "custom"
local ldoc = require"comments.ldoc"			-- parser = "ldoc"
local leg = require"comments.leg"			-- parser = "leg"

local parsers={
	[1]=literate,
	[2]=leg,
	[3]=custom,
	[4]=explua,
	[5]=luadoc,
	[6]=ldoc,

}


---@startuml{"fileName":"JEDNAmojoooobrazok.svg", "tempfileName":"/home/roboo/LUA/NaHodNy", "fileType":"svg"}
-------------
--- x1-->y1
--- x1<---y1
--- @enduml
---
--% The main parse funcion. Invokes the given parser, or tries all parsers until one succeed.
--@ text (string) multi or simple line comment
--@ parser (string,any) parser type or anything else
--@ extended (any) nil if don't want to use extended explua grammar
--: (table,nil) Return a table with parsed infos
local function Parse111(text,parser,extended)
   local result,errno

   if(parser=="explua")then
      return explua.parse(text,extended)
   elseif(parser=="luadoc")then
      return   luadoc.parse(text)
   elseif(parser=="literate")then
      return literate.parse(text)
   elseif(parser=="custom")then
      return custom.parse(text)
   elseif(parser=="ldoc")then
      return   ldoc.parse(text)
   elseif(parser=="leg")then
      return leg.parse(text)
   else
   
      for k,v in ipairs(parsers) do
         result,errno = v.parse(text,extended)
         if(result)then
            return result
         end
      end
   end
   return result,errno
end



-- daky easy koment
local function add_moduleaaa(tags,module_found,old_style)
      tags:add('name',module_found)
      tags:add('class','module')
      local item = F:new_item(tags,lineno())
      item.old_style = old_style
      module_item = item
end


--- @startuml{"fileType":"utxt"}
--- c1->b1:test request
--- c1<-b1:test response
--- @enduml
local function add_module(tags,module_found,old_style)
      tags:add('name',module_found)
      tags:add('class','module')
      local item = F:new_item(tags,lineno())
      item.old_style = old_style
      module_item = item
end


-- daky easy koment
local function add_bezkomentu(tags,module_found,old_style)
      tags:add('name',module_found)
      tags:add('class','module')
      local item = F:new_item(tags,lineno())
      item.old_style = old_style
      module_item = item
end



---@startuml{"fileName":"mojoooobrazok.svg","fileType":"svg"}
-------------
--- x1-->y1
--- x1<---y1
--- @enduml
---
--% The main parse funcion. Invokes the given parser, or tries all parsers until one succeed.
--@ text (string) multi or simple line comment
--@ parser (string,any) parser type or anything else
--@ extended (any) nil if don't want to use extended explua grammar
--: (table,nil) Return a table with parsed infos
local function Parse(text,parser,extended)
   local result,errno

   if(parser=="explua")then
      return explua.parse(text,extended)
   elseif(parser=="luadoc")then
      return   luadoc.parse(text)
   elseif(parser=="literate")then
      return literate.parse(text)
   elseif(parser=="custom")then
      return custom.parse(text)
   elseif(parser=="ldoc")then
      return   ldoc.parse(text)
   elseif(parser=="leg")then
      return leg.parse(text)
   else
   
      for k,v in ipairs(parsers) do
         result,errno = v.parse(text,extended)
         if(result)then
            return result
         end
      end
   end
   return result,errno
end



local function add_modulebbbbb(tags,module_found,old_style)
      tags:add('name',module_found)
      tags:add('class','module')
      local item = F:new_item(tags,lineno())
      item.old_style = old_style
      module_item = item
end



---@startuml{"fileName":"AAmojoooobrazok.png","fileType":"png"}
-------------
--- x1-->y1
--- x1<---y1
--- @enduml
---
--% The main parse funcion. Invokes the given parser, or tries all parsers until one succeed.
--@ text (string) multi or simple line comment
--@ parser (string,any) parser type or anything else
--@ extended (any) nil if don't want to use extended explua grammar
--: (table,nil) Return a table with parsed infos
local function Parse2(text,parser,extended)
   local result,errno

   if(parser=="explua")then
      return explua.parse(text,extended)
   elseif(parser=="luadoc")then
      return   luadoc.parse(text)
   elseif(parser=="literate")then
      return literate.parse(text)
   elseif(parser=="custom")then
      return custom.parse(text)
   elseif(parser=="ldoc")then
      return   ldoc.parse(text)
   elseif(parser=="leg")then
      return leg.parse(text)
   else
   
      for k,v in ipairs(parsers) do
         result,errno = v.parse(text,extended)
         if(result)then
            return result
         end
      end
   end
   return result,errno
end



---@startuml{"fileName":"poslednep.svg","fileType":"svg"}
-------------
--- x1-->y1
--- x1<---y1
--- @enduml
---
--% The main parse funcion. Invokes the given parser, or tries all parsers until one succeed.
--@ text (string) multi or simple line comment
--@ parser (string,any) parser type or anything else
--@ extended (any) nil if don't want to use extended explua grammar
--: (table,nil) Return a table with parsed infos
local function Parse66666(text,parser,extended)
   local result,errno

   if(parser=="explua")then
      return explua.parse(text,extended)
   elseif(parser=="luadoc")then
      return   luadoc.parse(text)
   elseif(parser=="literate")then
      return literate.parse(text)
   elseif(parser=="custom")then
      return custom.parse(text)
   elseif(parser=="ldoc")then
      return   ldoc.parse(text)
   elseif(parser=="leg")then
      return leg.parse(text)
   else
   
      for k,v in ipairs(parsers) do
         result,errno = v.parse(text,extended)
         if(result)then
            return result
         end
      end
   end
   return result,errno
end
