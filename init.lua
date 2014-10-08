--[[
------------------------------------------------------------------------------
Inter-Quake Export Loader is licensed under the MIT Open Source License.
(http://www.opensource.org/licenses/mit-license.html)
------------------------------------------------------------------------------

Copyright (c) 2014 Landon Manning - LManning17@gmail.com - LandonManning.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

--[[ Helper Functions ]]--

local function file_exists(file)
	if love then return love.filesystem.exists(file) end

	local f = io.open(file, "r")
	if f then f:close() end
	return f ~= nil
end

local path = ... .. "."
local IQE = require(path .. "iqe")
local loader = {}

loader.version = "0.1.0"

function loader.load(file)
	assert(file_exists(file), "File not found: " .. file)

	local get_lines

	if love then
		get_lines = love.filesystem.lines
	else
		get_lines = io.lines
	end

	local lines = {}

	for line in get_lines(file) do
		if line == "# Inter-Quake Export" or line[1] ~= "#" then
			line = string.gsub(line, "\t", "")
			table.insert(lines, line)
		end
	end

	assert(lines[1] == "# Inter-Quake Export", "Invalid file format.")

	local iqe = {}
	iqe = setmetatable(iqe, {__index = IQE})
	iqe:init(lines)
	
	return iqe
end

return loader
