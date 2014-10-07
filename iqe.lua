--[[ Helper Functions ]]--

-- http://wiki.interfaceware.com/534.html
local function string_split(s, d)
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

local function merge_quoted(t)
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
				if f == "\"" and l == f then
					table.insert(ret, v:sub(2, -2))
				else
					table.insert(ret, v)
				end
			end
		end
	end
	return ret
end

local function toboolean(v)
	return (type(v) == "string" and v == "true") or (type(v) == "number" and v ~= 0) or (type(v) == "boolean" and v)
end

local IQE = {}

function IQE:init(lines)
	self.iqe = lines
	self.data = {}
	self:parse()
end

function IQE:parse()
	local animation = false
	for _, line in ipairs(self.iqe) do
		local l = string_split(line, " ")

		if self[l[1]] then
			if not animation then
				animation = self[l[1]](self, l) or false
			else
				self[l[1]](self, l, animation)
			end
		end
	end
end

--[[ Meshes ]]--

function IQE:mesh(line)
	line = merge_quoted(line)
	self.data.mesh = self.data.mesh or {}
	local mesh = {}
	mesh.name = line[2]
	table.insert(self.data.mesh, mesh)
end

function IQE:material(line)
	local mesh = self.data.mesh[#self.data.mesh]
	line = merge_quoted(line)
	mesh.material = line[2]
end

--[[ Vertex Attributes ]]--

function IQE:vp(line)
	local mesh = self.data.mesh[#self.data.mesh]
	mesh.vp = mesh.vp or {}
	local vp = {}
	vp.x = tonumber(line[2]) or 0
	vp.y = tonumber(line[3]) or 0
	vp.z = tonumber(line[4]) or 0
	vp.w = tonumber(line[5]) or 1
	table.insert(mesh.vp, vp)
end

function IQE:vt(line)
	local mesh = self.data.mesh[#self.data.mesh]
	mesh.vt = mesh.vt or {}
	local vt = {}
	vt.u = tonumber(line[2]) or 0
	vt.v = tonumber(line[3]) or 0
	table.insert(mesh.vt, vt)
end

function IQE:vn(line)
	local mesh = self.data.mesh[#self.data.mesh]
	mesh.vn = mesh.vn or {}
	local vn = {}
	vn.x = tonumber(line[2])
	vn.y = tonumber(line[3])
	vn.z = tonumber(line[4])
	table.insert(mesh.vn, vn)
end

function IQE:vx(line)
	local mesh = self.data.mesh[#self.data.mesh]
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

function IQE:vb(line)
	local mesh = self.data.mesh[#self.data.mesh]
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

function IQE:vc(line)
	local mesh = self.data.mesh[#self.data.mesh]
	mesh.vc = mesh.vc or {}
	local vc = {}
	vc.r = tonumber(line[2]) or 0
	vc.g = tonumber(line[3]) or 0
	vc.b = tonumber(line[4]) or 0
	vc.a = tonumber(line[5]) or 1
	table.insert(mesh.vc, vc)
end

function IQE:v0(line)
	local mesh = self.data.mesh[#self.data.mesh]
	local v = line[1]
	mesh[v] = mesh[v] or {}
	local vz = {}
	vz.x = tonumber(line[2]) or 0
	vz.y = tonumber(line[3]) or 0
	vz.z = tonumber(line[4]) or 0
	vz.w = tonumber(line[5]) or 0
	table.insert(mesh[v], vz)
end

function IQE:v1(line)
	IQE:v0(line)
end

function IQE:v2(line)
	IQE:v0(line)
end

function IQE:v3(line)
	IQE:v0(line)
end

function IQE:v4(line)
	IQE:v0(line)
end

function IQE:v5(line)
	IQE:v0(line)
end

function IQE:v6(line)
	IQE:v0(line)
end

function IQE:v7(line)
	IQE:v0(line)
end

function IQE:v8(line)
	IQE:v0(line)
end

function IQE:v9(line)
	IQE:v0(line)
end

--[[ Vertex Arrays ]]--

function IQE:vertexarray(line)
	line = merge_quoted(line)
	local mesh = self.data.mesh[#self.data.mesh]
	mesh.vertexarray = mesh.vertexarray or {}
	local va = {}
	va.type = line[2]
	va.component = line[3]
	va.size = tonumber(line[4])
	va.name = line[5] or line[2]
	table.insert(mesh.vertexarray, va)
end

--[[ Triangle ]]--

function IQE:fa(line)
	local mesh = self.data.mesh[#self.data.mesh]
	mesh.fa = mesh.fa or {}
	local fa = {}
	for k, v in ipairs(line) do
		if k > 1 then
			table.insert(fa, tonumber(v))
		end
	end
	table.insert(mesh.fa, fa)
end

function IQE:fm(line)
	local mesh = self.data.mesh[#self.data.mesh]
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

function IQE:smoothuv(line)
	local mesh = self.data.mesh[#self.data.mesh]
	local n = tonumber(line[2])
	mesh.smoothuv = false

	if n > 0 then
		mesh.smoothuv = true
	end
end

function IQE:smoothgroup(line)
	local mesh = self.data.mesh[#self.data.mesh]
	local n = tonumber(line[2])
	mesh.smoothgroup = -1

	if n then
		mesh.smoothgroup = n
	end
end

function IQE:smoothangle(line)
	local mesh = self.data.mesh[#self.data.mesh]
	local angle = tonumber(line[2])
	mesh.smoothangle = 180

	if angle then
		mesh.smoothangle = angle
	end
end

function IQE:fs(line)
	local mesh = self.data.mesh[#self.data.mesh]
	mesh.fs = mesh.fs or {}
	local fs = {}
	for k, v in ipairs(line) do
		if k > 1 then
			table.insert(fs, tonumber(v))
		end
	end
	table.insert(mesh.fs, fs)
end

function IQE:vs(line)
	local mesh = self.data.mesh[#self.data.mesh]
	mesh.vs = mesh.vs or {}
	local vs = tonumber(line[2])
	table.insert(mesh.vs, vs)
end

--[[ Poses ]]--

function IQE:pq(line, animation)
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

	local joint
	if not animation then
		joint = self.data.joint[#self.data.joint]
		joint.pq = pq
	else
		joint = self.data.animation[#self.data.animation]
		joint = joint.frame[#joint.frame]
		joint.pq = joint.pq or {}
		table.insert(joint.pq, pq)
	end
end

function IQE:pm(line, animation)
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

	local joint
	if not animation then
		joint = self.data.joint[#self.data.joint]
		joint.pm = pm
	else
		joint = self.data.animation[#self.data.animation]
		joint = joint.frame[#joint.frame]
		joint.pm = joint.pm or {}
		table.insert(joint.pm, pm)
	end
end

function IQE:pa(line, animation)
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

	local joint
	if not animation then
		joint = self.data.joint[#self.data.joint]
		joint.pa = pa
	else
		joint = self.data.animation[#self.data.animation]
		joint = joint.frame[#joint.frame]
		joint.pa = joint.pa or {}
		table.insert(joint.pa, pa)
	end
end

--[[ Skeleton ]]--

function IQE:joint(line)
	line = merge_quoted(line)
	self.data.joint = self.data.joint or {}
	local joint = {}
	joint.name = line[2]
	joint.parent = tonumber(line[3])
	table.insert(self.data.joint, joint)
end

--[[ Animations ]]--

function IQE:animation(line)
	line = merge_quoted(line)
	self.data.animation = self.data.animation or {}
	local animation = {}
	animation.name = line[2] or love.math.random(0, 99999)
	table.insert(self.data.animation, animation)

	return true
end

function IQE:loop(line)
	local animation = self.data.animation[#self.data.animation]
	animation.loop = true
end

function IQE:framerate(line)
	local animation = self.data.animation[#self.data.animation]
	animation.framerate = tonumber(line[2])
end

function IQE:frame(line)
	local animation = self.data.animation[#self.data.animation]
	animation.frame = animation.frame or {}
	table.insert(animation.frame, {})
end

return IQE
