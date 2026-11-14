-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Util/MTRandom.lua

local floor = math.floor

local function SAFEMUL32(a, b)
	local alo = floor(a % 65536)
	local ahi = floor(a / 65536) % 65536
	local blo = floor(b % 65536)
	local bhi = floor(b / 65536) % 65536
	local lolo = alo * blo
	local lohi = alo * bhi
	local hilo = ahi * blo
	local llhh = lohi + hilo

	return floor((llhh * 65536 + lolo) % 4294967296)
end

local AND, OR, XOR
local is53 = false

if is53 then
	-- block empty
else
	function AND(a, b)
		local r, p = 0, 1

		for i = 0, 31 do
			local a1 = a % 2
			local b1 = b % 2

			if a1 > 0 and b1 > 0 then
				r = r + p
			end

			if a1 > 0 then
				a = a - 1
			end

			if b1 > 0 then
				b = b - 1
			end

			a = a / 2
			b = b / 2
			p = p * 2
		end

		return r
	end

	function OR(a, b)
		local r, p = 0, 1

		for i = 0, 31 do
			local a1 = a % 2
			local b1 = b % 2

			if a1 > 0 or b1 > 0 then
				r = r + p
			end

			if a1 > 0 then
				a = a - 1
			end

			if b1 > 0 then
				b = b - 1
			end

			a = a / 2
			b = b / 2
			p = p * 2
		end

		return r
	end

	function XOR(a, b)
		local r, p = 0, 1

		for i = 0, 31 do
			local a1 = a % 2
			local b1 = b % 2

			if a1 ~= b1 then
				r = r + p
			end

			if a1 > 0 then
				a = a - 1
			end

			if b1 > 0 then
				b = b - 1
			end

			a = a / 2
			b = b / 2
			p = p * 2
		end

		return r
	end
end

local function SHR1(y)
	return floor(y / 2)
end

local function SHR30(y)
	return floor(y / 1073741824)
end

local function SHR11(y)
	return floor(y / 2048)
end

local function SHL7(y)
	return y * 128
end

local function SHL15(y)
	return y * 32768
end

local function SHR18(y)
	return floor(y / 262144)
end

local function BIT0(y)
	return y % 2
end

local N = 624
local M = 397
local MATRIX_A = 2567483615
local UPPER_MASK = 2147483648
local LOWER_MASK = 2147483647
local mt19937ar = {}

function mt19937ar.new()
	local instance = {}
	local mt = {}
	local mti = N + 1

	function instance:init_genrand(s)
		mt[0] = AND(s, 4294967295)

		for i = 1, N - 1 do
			mt[i] = SAFEMUL32(1812433253, XOR(mt[i - 1], SHR30(mt[i - 1]))) + i
			mt[i] = AND(mt[i], 4294967295)
		end

		mti = N
	end

	function instance:init_by_array(init_key, key_length)
		self:init_genrand(19650218)

		key_length = key_length or #init_key

		local i, j, k = 1, 0, key_length < N and N or key_length

		while k > 0 do
			mt[i] = XOR(mt[i], SAFEMUL32(XOR(mt[i - 1], SHR30(mt[i - 1])), 1664525)) + init_key[j + 1] + j
			mt[i] = AND(mt[i], 4294967295)
			i, j = i + 1, j + 1

			if i >= N then
				mt[0] = mt[N - 1]
				i = 1
			end

			if key_length <= j then
				j = 0
			end

			k = k - 1
		end

		for k = N - 1, 1, -1 do
			mt[i] = XOR(mt[i], SAFEMUL32(XOR(mt[i - 1], SHR30(mt[i - 1])), 1566083941)) - i
			mt[i] = AND(mt[i], 4294967295)
			i = i + 1

			if i >= N then
				mt[0] = mt[N - 1]
				i = 1
			end
		end

		mt[0] = 2147483648
	end

	function instance:genrand_int32()
		local y

		if mti >= N then
			if mti == N + 1 then
				self:init_genrand(5489)
			end

			for kk = 0, N - M - 1 do
				y = OR(AND(mt[kk], UPPER_MASK), AND(mt[kk + 1], LOWER_MASK))
				mt[kk] = XOR(mt[kk + M], XOR(SHR1(y), BIT0(y) * MATRIX_A))
				kk = kk + 1
			end

			for kk = N - M, N - 2 do
				y = OR(AND(mt[kk], UPPER_MASK), AND(mt[kk + 1], LOWER_MASK))
				mt[kk] = XOR(mt[kk + (M - N)], XOR(SHR1(y), BIT0(y) * MATRIX_A))
				kk = kk + 1
			end

			y = OR(AND(mt[N - 1], UPPER_MASK), AND(mt[0], LOWER_MASK))
			mt[N - 1] = XOR(mt[M - 1], XOR(SHR1(y), BIT0(y) * MATRIX_A))
			mti = 0
		end

		y = mt[mti]
		mti = mti + 1
		y = XOR(y, SHR11(y))
		y = XOR(y, AND(SHL7(y), 2636928640))
		y = XOR(y, AND(SHL15(y), 4022730752))
		y = XOR(y, SHR18(y))

		return y
	end

	function instance:genrand_int31()
		return floor(self:genrand_int32() / 2)
	end

	function instance:genrand_real1()
		return self:genrand_int32() * 2.3283064370807974e-10
	end

	function instance:genrand_real2()
		return self:genrand_int32() * 2.3283064365386963e-10
	end

	function instance:genrand_real3()
		return (self:genrand_int32() + 0.5) * 2.3283064365386963e-10
	end

	function instance:genrand_res53()
		local a = floor(self:genrand_int32() / 32)
		local b = floor(self:genrand_int32() / 64)

		return (a * 67108864 + b) * 1.1102230246251565e-16
	end

	instance.randomseed = instance.init_genrand

	function instance:random(m, n)
		if not m then
			return self:genrand_real2()
		elseif not n then
			return self:genrand_int32() % m + 1
		else
			return m + self:genrand_int32() % (n - m + 1)
		end
	end

	function instance:getState()
		local r = {}

		r.mti = mti
		r.mt = {}

		for i = 0, N - 1 do
			r.mt[i] = mt[i]
		end

		return r
	end

	function instance:setState(s)
		if s == nil then
			return
		end

		if type(s.mti) == "number" then
			mti = floor(s.mti)
		end

		if type(s.mt) == "table" then
			for i = 0, N - 1 do
				if type(s.mt[i]) == "number" then
					mt[i] = floor(s.mt[i])
				end
			end
		end
	end

	function instance:createValidationOutput()
		local filename = "mt19937ar.lua.out"
		local f = io.open(filename, "wb")

		self:init_by_array({
			291,
			564,
			837,
			1110
		})
		f:write("1000 outputs of genrand_int32()\n")

		for i = 0, 999 do
			f:write(string.format("%10.0f ", self:genrand_int32()))

			if i % 5 == 4 then
				f:write("\n")
			end
		end

		f:write("\n1000 outputs of genrand_real2()\n")

		for i = 0, 999 do
			f:write(string.format("%10.8f ", self:genrand_real2()))

			if i % 5 == 4 then
				f:write("\n")
			end
		end

		f:close()
	end

	return instance
end

return mt19937ar
