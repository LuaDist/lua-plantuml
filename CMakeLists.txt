# Copyright (C) 2012 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

project ( luaplantuml NONE )
cmake_minimum_required ( VERSION 2.8 )
include ( cmake/dist.cmake )
include ( lua )

# Install all files and documentation
install_lua_executable ( lua-plantuml src/bin/lua-plantuml.lua )
install ( DIRECTORY src/luaplantuml DESTINATION ${INSTALL_LMOD} COMPONENT Runtime )
#install_lua_module( luaplantuml src/luaplantuml )

install_doc ( doc/ )
install_test ( tests/ )
install_data ( README.md COPYRIGHT )