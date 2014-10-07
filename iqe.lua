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
	return	(type(v) == "string" and v == "true") or
			(type(v) == "string" and v == "1") or
			(type(v) == "number" and v ~= 0) or
			(type(v) == "boolean" and v)
end

local IQE = {}

function IQE:init(lines)
	self.iqe = lines
	self.current_mesh = false
	self.current_material = false
	self.current_joint = false
	self.current_animation = false
	self.current_frame = false
	self.current_vertexarray = false
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
	self.current_material = nil
	self.current_joint = nil
	self.current_animation = nil
	self.current_frame = nil
	self.current_vertexarray = nil
end

--[[ Meshes ]]--

function IQE:mesh(line)
	line = merge_quoted(line)
	self.data.mesh = self.data.mesh or {}
	self.data.mesh[line[1]] = {}
	self.current_mesh = self.data.mesh[line[1]]
end

function IQE:material(line)
	line = merge_quoted(line)
	local mesh = self.current_mesh
	mesh.material = mesh.material or {}
	mesh.material[line[1]] = {}
	self.current_material = mesh.material[line[1]]
end

--[[ Vertex Attributes ]]--

function IQE:vp(line)
	local material = self.current_material
	material.vp = material.vp or {}
	local vp = {}
	for _, v in ipairs(line) do
		table.insert(vp, tonumber(v))
	end
	if #vp == 3 then
		table.insert(vp, 1)
	end
	table.insert(material.vp, vp)
end

function IQE:vt(line)
	local material = self.current_material
	material.vt = material.vt or {}
	local vt = {}
	for _, v in ipairs(line) do
		table.insert(vt, tonumber(v))
	end
	table.insert(material.vt, vt)
end

function IQE:vn(line)
	local material = self.current_material
	material.vn = material.vn or {}
	local vn = {}
	for _, v in ipairs(line) do
		table.insert(vn, tonumber(v))
	end
	table.insert(material.vn, vn)
end

function IQE:vx(line)
	local material = self.current_material
	material.vx = material.vx or {}
	local vx = {}
	for _, v in ipairs(line) do
		table.insert(vx, tonumber(v))
	end
	table.insert(material.vx, vx)
end

function IQE:vb(line)
	local material = self.current_material
	material.vb = material.vb or {}
	local vb = {}
	for _, v in ipairs(line) do
		table.insert(vb, tonumber(v))
	end
	table.insert(material.vb, vb)
end

function IQE:vc(line)
	local material = self.current_material
	material.vc = material.vc or {}
	local vc = {}
	for _, v in ipairs(line) do
		table.insert(vc, tonumber(v))
	end
	if #vc == 3 then
		table.insert(vc, 1)
	end
	table.insert(material.vc, vc)
end

function IQE:v0(line, cmd)
	cmd = cmd or "v0"
	local material = self.current_material
	material[cmd] = material[cmd] or {}
	local v0 = {}
	for _, v in ipairs(line) do
		table.insert(v0, tonumber(v))
	end
	table.insert(material[cmd], v0)
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
	self.data.vertexarray = self.data.vertexarray or {}
	local va = {}
	va.type = line[1]
	va.component = line[2]
	va.size = tonumber(line[3])
	va.name = line[4] or line[1]
	table.insert(self.data.vertexarray, va)
	self.current_vertexarray = self.data.vertexarray[#self.data.vertexarray]
end

--[[ Triangle ]]--

function IQE:fa(line)
	local material = self.current_material
	material.fa = material.fa or {}
	local fa = {}
	for k, v in ipairs(line) do
		table.insert(fa, tonumber(v))
	end
	table.insert(material.fa, fa)
end

function IQE:fm(line)
	local material = self.current_material
	material.fm = material.fm or {}
	local fm = {}
	for k, v in ipairs(line) do
		table.insert(fm, tonumber(v))
	end
	table.insert(material.fm, fm)
end

--[[ Smoothing ]]--

function IQE:smoothuv(line)
	local material = self.current_material
	local n = tonumber(line[1])
	material.smoothuv = false

	if n > 0 then
		material.smoothuv = true
	end
end

function IQE:smoothgroup(line)
	local material = self.current_material
	local n = tonumber(line[1])
	material.smoothgroup = -1

	if n then
		material.smoothgroup = n
	end
end

function IQE:smoothangle(line)
	local material = self.current_material
	local angle = tonumber(line[1])
	material.smoothangle = 180

	if angle then
		material.smoothangle = angle
	end
end

function IQE:fs(line)
	local material = self.current_material
	material.fs = material.fs or {}
	local fs = {}
	for k, v in ipairs(line) do
		table.insert(fs, tonumber(v))
	end
	table.insert(material.fs, fs)
end

function IQE:vs(line)
	local material = self.current_material
	material.vs = material.vs or {}
	local vs = tonumber(line[1])
	table.insert(material.vs, vs)
end

--[[ Poses ]]--

function IQE:pq(line)
	local pq = {}
	for _, v in ipairs(line) do
		table.insert(pq, tonumber(v))
	end
	if #pq == 6 then
		table.insert(pq, -1)
		table.insert(pq, 1)
		table.insert(pq, 1)
		table.insert(pq, 1)
	end

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
	for _, v in ipairs(line) do
		table.insert(pm, tonumber(v))
	end
	if #pm == 12 then
		table.insert(pm, 1)
		table.insert(pm, 1)
		table.insert(pm, 1)
	end

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
	for _, v in ipairs(line) do
		table.insert(pa, tonumber(v))
	end
	if #pm == 6 then
		table.insert(pa, 1)
		table.insert(pa, 1)
		table.insert(pa, 1)
	end

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
