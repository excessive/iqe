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

local path = ... .. "."
local loader = {}

loader.version = "0.0.1"

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

	return loader.parse(lines)
end

function loader.parse(lines)
	local iqe = {}
	for _, line in ipairs(lines) do
		local l = string_split(line, " ")

		if loader[l[1]] then
			loader[l[1]](iqe, l)
		end
	end

	return iqe
end

--[[ Meshes ]]--

function loader.mesh(iqe, line)
	line = merge_quoted(line)
	iqe.mesh = iqe.mesh or {}
	local mesh = {}
	mesh.name = line[2]
	table.insert(iqe.mesh, mesh)
end

function loader.material(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	line = merge_quoted(line)
	mesh.material = line[2]
end

--[[ Vertex Attributes ]]--

function loader.vp(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.vp = mesh.vp or {}
	local vp = {}
	vp.x = tonumber(line[2]) or 0
	vp.y = tonumber(line[3]) or 0
	vp.z = tonumber(line[4]) or 0
	vp.w = tonumber(line[5]) or 1
	table.insert(mesh.vp, vp)
end

function loader.vt(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.vt = mesh.vt or {}
	local vt = {}
	vt.u = tonumber(line[2]) or 0
	vt.v = tonumber(line[3]) or 0
	table.insert(mesh.vt, vt)
end

function loader.vn(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.vn = mesh.vn or {}
	local vn = {}
	vn.x = tonumber(line[2])
	vn.y = tonumber(line[3])
	vn.z = tonumber(line[4])
	table.insert(mesh.vn, vn)
end

function loader.vx(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.vp = mesh.vp or {}
	local vp = {}
	if not line[6] then
		vp.x = tonumber(line[2])
		vp.y = tonumber(line[3])
		vp.z = tonumber(line[4])
		vp.w = tonumber(line[5])
	else
		vp.x = tonumber(line[2])
		vp.y = tonumber(line[3])
		vp.z = tonumber(line[4])
		vp.a = tonumber(line[5])
		vp.b = tonumber(line[6])
		vp.c = tonumber(line[7])
	end
	table.insert(mesh.vp, vp)
end

function loader.vb(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.vb = mesh.vb or {}
	local vb = {}
	vb.ai = tonumber(line[2])
	vb.aw = tonumber(line[3])
	vb.bi = tonumber(line[4])
	vb.bw = tonumber(line[5])
	vb.ci = tonumber(line[6])
	vb.cw = tonumber(line[7])
	vb.di = tonumber(line[8])
	vb.dw = tonumber(line[9])
	table.insert(mesh.vb, vb)
end

function loader.vc(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.vc = mesh.vc or {}
	local vc = {}
	vc.r = tonumber(line[2]) or 0
	vc.g = tonumber(line[3]) or 0
	vc.b = tonumber(line[4]) or 0
	vc.a = tonumber(line[5]) or 1
	table.insert(mesh.vc, vc)
end

function loader.v0(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	local v = line[1]
	mesh[v] = mesh[v] or {}
	local vz = {}
	vz.x = tonumber(line[2]) or 0
	vz.y = tonumber(line[3]) or 0
	vz.z = tonumber(line[4]) or 0
	vz.w = tonumber(line[5]) or 0
	table.insert(mesh[v], vz)
end

function loader.v1(iqe, line)
	loader.v0(iqe, line)
end

function loader.v2(iqe, line)
	loader.v0(iqe, line)
end

function loader.v3(iqe, line)
	loader.v0(iqe, line)
end

function loader.v4(iqe, line)
	loader.v0(iqe, line)
end

function loader.v5(iqe, line)
	loader.v0(iqe, line)
end

function loader.v6(iqe, line)
	loader.v0(iqe, line)
end

function loader.v7(iqe, line)
	loader.v0(iqe, line)
end

function loader.v8(iqe, line)
	loader.v0(iqe, line)
end

function loader.v9(iqe, line)
	loader.v0(iqe, line)
end

--[[ Vertex Arrays ]]--

function loader.vertexarray(iqe, line)
	line = merge_quoted(line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.vertexarray = mesh.vertexarray or {}
	local va = {}
	va.type = line[2]
	va.component = line[3]
	va.size = tonumber(line[4])
	va.name = line[5] or line[2]
	table.insert(mesh.vertexarray, va)
end

--[[ Triangle ]]--

function loader.fa(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.fa = mesh.fa or {}
	local fa = {}
	for k, v in ipairs(line) do
		if k > 1 then
			table.insert(fa, tonumber(v))
		end
	end
	table.insert(mesh.fa, fa)
end

function loader.fm(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.fm = mesh.fm or {}
	local fm = {}
	for k, v in ipairs(line) do
		if k > 1 then
			table.insert(fm, tonumber(v))
		end
	end
	table.insert(mesh.fm, fm)
end

--[[ Smoothing ]]--

function loader.smoothuv(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	local n = tonumber(line[2])
	mesh.smoothuv = false

	if n > 0 then
		mesh.smoothuv = true
	end
end

function loader.smoothgroup(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	local n = tonumber(line[2])
	mesh.smoothgroup = -1

	if n then
		mesh.smoothgroup = n
	end
end

function loader.smoothangle(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	local angle = tonumber(line[2])
	mesh.smoothangle = 180

	if angle then
		mesh.smoothangle = angle
	end
end

function loader.fs(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.fs = mesh.fs or {}
	local fs = {}
	for k, v in ipairs(line) do
		if k > 1 then
			table.insert(fs, tonumber(v))
		end
	end
	table.insert(mesh.fs, fs)
end

function loader.vs(iqe, line)
	local mesh = iqe.mesh[#iqe.mesh]
	mesh.vs = mesh.vs or {}
	local vs = tonumber(line[2])
	table.insert(mesh.vs, vs)
end

--[[ Poses ]]--

function loader.pq(iqe, line)
	iqe.pq = iqe.pq or {}
	local pq = {}
	pq.tx = tonumber(line[2])
	pq.ty = tonumber(line[3])
	pq.tz = tonumber(line[4])
	pq.qx = tonumber(line[5])
	pq.qy = tonumber(line[6])
	pq.qz = tonumber(line[7])
	pq.qw = tonumber(line[8]) or -1
	pq.sx = tonumber(line[9]) or 1
	pq.sy = tonumber(line[10]) or 1
	pq.sz = tonumber(line[11]) or 1
	table.insert(iqe.pq, pq)
end

function loader.pm(iqe, line)
	iqe.pm = iqe.pm or {}
	local pm = {}
	pm.tx = tonumber(line[2])
	pm.ty = tonumber(line[3])
	pm.tz = tonumber(line[4])
	pm.ax = tonumber(line[5])
	pm.ay = tonumber(line[6])
	pm.az = tonumber(line[7])
	pm.bx = tonumber(line[8])
	pm.by = tonumber(line[9])
	pm.bz = tonumber(line[10])
	pm.cx = tonumber(line[11])
	pm.cy = tonumber(line[12])
	pm.cz = tonumber(line[13])
	pm.sx = tonumber(line[14]) or 1
	pm.sy = tonumber(line[15]) or 1
	pm.sz = tonumber(line[16]) or 1
	table.insert(iqe.pm, pm)
end

function loader.pa(iqe, line)
	iqe.pa = iqe.pa or {}
	local pa = {}
	pa.tx = tonumber(line[2])
	pa.ty = tonumber(line[3])
	pa.tz = tonumber(line[4])
	pa.rx = tonumber(line[5])
	pa.ry = tonumber(line[6])
	pa.rz = tonumber(line[7])
	pa.sx = tonumber(line[8]) or 1
	pa.sy = tonumber(line[9]) or 1
	pa.sz = tonumber(line[10]) or 1
	table.insert(iqe.pa, pa)
end

--[[ Skeleton ]]--

function loader.joint(iqe, line)
	line = merge_quoted(line)
	iqe.joint = iqe.joint or {}
	local joint = {}
	joint.name = line[2]
	joint.parent = tonumber(line[3])
	table.insert(iqe.joint, joint)
end

--[[ Animations ]]--

function loader.animation(iqe, line)
	line = merge_quoted(line)
	iqe.animation = iqe.animation or {}
	local animation = {}
	animation.name = line[2] or love.math.random(0, 99999)
	table.insert(iqe.animation, animation)
end

function loader.loop(iqe, line)
	local animation = iqe.animation[#iqe.animation]
	animation.loop = true
end

function loader.framerate(iqe, line)
	local animation = iqe.animation[#iqe.animation]
	animation.framerate = tonumber(line[2])
end

function loader.frame(iqe, line)
	local animation = iqe.animation[#iqe.animation]
	animation.frame = animation.frame or {}
	table.insert(animation.frame, {})
end

--[[ Useful Functions ]]--

function file_exists(file)
	if love then return love.filesystem.exists(file) end

	local f = io.open(file, "r")
	if f then f:close() end
	return f ~= nil
end

-- http://wiki.interfaceware.com/534.html
function string_split(s, d)
	local t = {}
	local i = 0
	local f
	local match = '(.-)' .. d .. '()'
	
	if string.find(s, d) == nil then
		return {s}
	end
	
	for sub, j in string.gmatch(s, match) do
		i = i + 1
		t[i] = sub
		f = j
	end
	
	if i ~= 0 then
		t[i+1] = string.sub(s, f)
	end
	
	return t
end

function merge_quoted(t)
	local ret = {}
	local merging = false
	local buf = ""
	for k, v in ipairs(t) do
		local f, l = v:sub(1,1), v:sub(v:len())
		if f == "\"" and l ~= "\"" then
			merging = true
			buf = v
		else
			if merging then
				buf = buf .. " " .. v
				if l == "\"" then
					merging = false
					table.insert(ret, buf:sub(2,-2))
				end
			else
				table.insert(ret, v)
			end
		end
	end
	return ret
end

function toboolean(v)
	return (type(v) == "string" and v == "true") or (type(v) == "number" and v ~= 0) or (type(v) == "boolean" and v)
end

return loader
