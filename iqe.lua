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
	return (type(v) == "string" and v == "true") or (type(v) == "string" and v == "1") or (type(v) == "number" and v ~= 0) or (type(v) == "boolean" and v)
end

local IQE = {}

function IQE:init(lines)
	self.iqe = lines
	self.current_mesh = false
	self.current_joint = false
	self.current_animation = false
	self.current_frame = false
	self.data = {}
	self:parse()
end

function IQE:parse()
	for _, line in ipairs(self.iqe) do
		local l = string_split(line, " ")
		local cmd = l[1]
		table.remove(l, 1)

		if self[cmd] then
			self[cmd](self, l)
		end
	end

	self.iqe = nil
	self.current_mesh = nil
	self.current_joint = nil
	self.current_animation = nil
	self.current_frame = nil
end

--[[ Meshes ]]--

function IQE:mesh(line)
	line = merge_quoted(line)
	self.data.mesh = self.data.mesh or {}
	self.data.mesh[line[1]] = {}
	self.current_mesh = self.data.mesh[line[1]]
end

function IQE:material(line)
	local mesh = self.current_mesh
	line = merge_quoted(line)
	mesh.material = line[1]
end

--[[ Vertex Attributes ]]--

function IQE:vp(line)
	local mesh = self.current_mesh
	mesh.vp = mesh.vp or {}
	local vp = {}
	vp.x = tonumber(line[1]) or 0
	vp.y = tonumber(line[2]) or 0
	vp.z = tonumber(line[3]) or 0
	vp.w = tonumber(line[4]) or 1
	table.insert(mesh.vp, vp)
end

function IQE:vt(line)
	local mesh = self.current_mesh
	mesh.vt = mesh.vt or {}
	local vt = {}
	vt.u = tonumber(line[1]) or 0
	vt.v = tonumber(line[2]) or 0
	table.insert(mesh.vt, vt)
end

function IQE:vn(line)
	local mesh = self.current_mesh
	mesh.vn = mesh.vn or {}
	local vn = {}
	vn.x = tonumber(line[1])
	vn.y = tonumber(line[2])
	vn.z = tonumber(line[3])
	table.insert(mesh.vn, vn)
end

function IQE:vx(line)
	local mesh = self.current_mesh
	mesh.vp = mesh.vp or {}
	local vp = {}
	if not line[5] then
		vp.x = tonumber(line[1])
		vp.y = tonumber(line[2])
		vp.z = tonumber(line[3])
		vp.w = tonumber(line[4])
	else
		vp.x = tonumber(line[1])
		vp.y = tonumber(line[2])
		vp.z = tonumber(line[3])
		vp.a = tonumber(line[4])
		vp.b = tonumber(line[5])
		vp.c = tonumber(line[6])
	end
	table.insert(mesh.vp, vp)
end

function IQE:vb(line)
	local mesh = self.current_mesh
	mesh.vb = mesh.vb or {}
	local vb = {}
	vb.ai = tonumber(line[1])
	vb.aw = tonumber(line[2])
	vb.bi = tonumber(line[3])
	vb.bw = tonumber(line[4])
	vb.ci = tonumber(line[5])
	vb.cw = tonumber(line[6])
	vb.di = tonumber(line[7])
	vb.dw = tonumber(line[8])
	table.insert(mesh.vb, vb)
end

function IQE:vc(line)
	local mesh = self.current_mesh
	mesh.vc = mesh.vc or {}
	local vc = {}
	vc.r = tonumber(line[1]) or 0
	vc.g = tonumber(line[2]) or 0
	vc.b = tonumber(line[3]) or 0
	vc.a = tonumber(line[4]) or 1
	table.insert(mesh.vc, vc)
end

function IQE:v0(line, cmd)
	cmd = cmd or "v0"
	local mesh = self.current_mesh
	mesh[cmd] = mesh[cmd] or {}
	local v = {}
	v.x = tonumber(line[1]) or 0
	v.y = tonumber(line[2]) or 0
	v.z = tonumber(line[3]) or 0
	v.w = tonumber(line[4]) or 0
	table.insert(mesh[cmd], v)
end

function IQE:v1(line)
	IQE:v0(line, "v1")
end

function IQE:v2(line)
	IQE:v0(line, "v2")
end

function IQE:v3(line)
	IQE:v0(line, "v3")
end

function IQE:v4(line)
	IQE:v0(line, "v4")
end

function IQE:v5(line)
	IQE:v0(line, "v5")
end

function IQE:v6(line)
	IQE:v0(line, "v6")
end

function IQE:v7(line)
	IQE:v0(line, "v7")
end

function IQE:v8(line)
	IQE:v0(line, "v8")
end

function IQE:v9(line)
	IQE:v0(line, "v9")
end

--[[ Vertex Arrays ]]--

function IQE:vertexarray(line)
	line = merge_quoted(line)
	local mesh = self.current_mesh
	mesh.vertexarray = mesh.vertexarray or {}
	local va = {}
	va.type = line[1]
	va.component = line[2]
	va.size = tonumber(line[3])
	va.name = line[4] or line[1]
	table.insert(mesh.vertexarray, va)
end

--[[ Triangle ]]--

function IQE:fa(line)
	local mesh = self.current_mesh
	mesh.fa = mesh.fa or {}
	local fa = {}
	for k, v in ipairs(line) do
		table.insert(fa, tonumber(v))
	end
	table.insert(mesh.fa, fa)
end

function IQE:fm(line)
	local mesh = self.current_mesh
	mesh.fm = mesh.fm or {}
	local fm = {}
	for k, v in ipairs(line) do
		table.insert(fm, tonumber(v))
	end
	table.insert(mesh.fm, fm)
end

--[[ Smoothing ]]--

function IQE:smoothuv(line)
	local mesh = self.current_mesh
	local n = tonumber(line[1])
	mesh.smoothuv = false

	if n > 0 then
		mesh.smoothuv = true
	end
end

function IQE:smoothgroup(line)
	local mesh = self.current_mesh
	local n = tonumber(line[1])
	mesh.smoothgroup = -1

	if n then
		mesh.smoothgroup = n
	end
end

function IQE:smoothangle(line)
	local mesh = self.current_mesh
	local angle = tonumber(line[1])
	mesh.smoothangle = 180

	if angle then
		mesh.smoothangle = angle
	end
end

function IQE:fs(line)
	local mesh = self.current_mesh
	mesh.fs = mesh.fs or {}
	local fs = {}
	for k, v in ipairs(line) do
		table.insert(fs, tonumber(v))
	end
	table.insert(mesh.fs, fs)
end

function IQE:vs(line)
	local mesh = self.current_mesh
	mesh.vs = mesh.vs or {}
	local vs = tonumber(line[1])
	table.insert(mesh.vs, vs)
end

--[[ Poses ]]--

function IQE:pq(line)
	local pq = {}
	pq.tx = tonumber(line[1])
	pq.ty = tonumber(line[2])
	pq.tz = tonumber(line[3])
	pq.qx = tonumber(line[4])
	pq.qy = tonumber(line[5])
	pq.qz = tonumber(line[6])
	pq.qw = tonumber(line[7]) or -1
	pq.sx = tonumber(line[8]) or 1
	pq.sy = tonumber(line[9]) or 1
	pq.sz = tonumber(line[10]) or 1

	local joint
	if not self.current_animation then
		joint = self.current_joint
		joint.pq = pq
	else
		joint = self.current_frame
		joint.pq = joint.pq or {}
		table.insert(joint.pq, pq)
	end
end

function IQE:pm(line)
	local pm = {}
	pm.tx = tonumber(line[1])
	pm.ty = tonumber(line[2])
	pm.tz = tonumber(line[3])
	pm.ax = tonumber(line[4])
	pm.ay = tonumber(line[5])
	pm.az = tonumber(line[6])
	pm.bx = tonumber(line[7])
	pm.by = tonumber(line[8])
	pm.bz = tonumber(line[9])
	pm.cx = tonumber(line[10])
	pm.cy = tonumber(line[11])
	pm.cz = tonumber(line[12])
	pm.sx = tonumber(line[13]) or 1
	pm.sy = tonumber(line[14]) or 1
	pm.sz = tonumber(line[15]) or 1

	local joint
	if not self.current_animation then
		joint = self.current_joint
		joint.pq = pq
	else
		joint = self.current_frame
		joint.pq = joint.pq or {}
		table.insert(joint.pq, pq)
	end
end

function IQE:pa(line)
	local pa = {}
	pa.tx = tonumber(line[1])
	pa.ty = tonumber(line[2])
	pa.tz = tonumber(line[3])
	pa.rx = tonumber(line[4])
	pa.ry = tonumber(line[5])
	pa.rz = tonumber(line[6])
	pa.sx = tonumber(line[7]) or 1
	pa.sy = tonumber(line[8]) or 1
	pa.sz = tonumber(line[9]) or 1

	local joint
	if not self.current_animation then
		joint = self.current_joint
		joint.pq = pq
	else
		joint = self.current_frame
		joint.pq = joint.pq or {}
		table.insert(joint.pq, pq)
	end
end

--[[ Skeleton ]]--

function IQE:joint(line)
	line = merge_quoted(line)
	self.data.joint = self.data.joint or {}
	self.data.joint[line[1]] = {}

	self.current_joint = self.data.joint[line[1]]
	self.current_joint.parent = tonumber(line[2])
end

--[[ Animations ]]--

function IQE:animation(line)
	line = merge_quoted(line)
	self.data.animation = self.data.animation or {}
	local name = line[1] or tostring(love.math.random(0, 99999))
	self.data.animation[name] = {}
	self.current_animation = self.data.animation[name]
	self.current_frame = false
end

function IQE:loop(line)
	local animation = self.current_animation
	animation.loop = true
end

function IQE:framerate(line)
	local animation = self.current_animation
	animation.framerate = tonumber(line[2])
end

function IQE:frame(line)
	local animation = self.current_animation
	animation.frame = animation.frame or {}
	table.insert(animation.frame, {})
	self.current_frame = animation.frame[#animation.frame]
end

return IQE
