-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/EaseTool.lua

function Linear(t, b, c, d)
	return c * t / d + b
end

Quad = {}

function Quad.easeIn(t, b, c, d)
	t = t / d

	return c * t * t + b
end

function Quad.easeOut(t, b, c, d)
	t = t / d

	return -c * t * (t - 2) + b
end

function Quad.easeInOut(t, b, c, d)
	t = t / (d * 0.5)

	if t < 1 then
		return c / 2 * t * t + b
	end

	t = t - 1

	return -c / 2 * (t * (t - 2) - 1) + b
end

Cubic = {}

function Cubic.easeIn(t, b, c, d)
	t = t / d

	return c * t * t * t + b
end

function Cubic.easeOut(t, b, c, d)
	t = t / d - 1

	return c * (t * t * t + 1) + b
end

function Cubic.easeInOut(t, b, c, d)
	t = t / (d * 0.5)

	if t < 1 then
		return c / 2 * t * t * t + b
	end

	t = t - 2

	return c / 2 * (t * t * t + 2) + b
end

Quart = {}

function Quart.easeIn(t, b, c, d)
	t = t / d

	return c * t * t * t * t + b
end

function Quart.easeOut(t, b, c, d)
	t = t / d - 1

	return -c * (t * t * t * t - 1) + b
end

function Quart.easeInOut(t, b, c, d)
	t = t / d * 0.5

	if t < 1 then
		return c / 2 * t * t * t * t + b
	end

	t = t - 2

	return -c / 2 * (t * t * t * t - 2) + b
end

Quint = {}

function Quint.easeIn(t, b, c, d)
	t = t / d

	return c * t * t * t * t * t + b
end

function Quint.easeOut(t, b, c, d)
	t = t / d - 1

	return c * (t * t * t * t * t + 1) + b
end

function Quint.easeInOut(t, b, c, d)
	t = t / d * 0.5

	if t < 1 then
		return c / 2 * t * t * t * t * t + b
	end

	t = t - 2

	return c / 2 * (t * t * t * t * t + 2) + b
end

Sine = {}

function Sine.easeIn(t, b, c, d)
	return -c * math.cos(t / d * (math.pi / 2)) + c + b
end

function Sine.easeOut(t, b, c, d)
	return c * math.sin(t / d * (math.pi / 2)) + b
end

function Sine.easeInOut(t, b, c, d)
	return -c / 2 * (math.cos(math.pi * t / d) - 1) + b
end

Expo = {}

function Expo.easeIn(t, b, c, d)
	if t == 0 then
		return b
	else
		return c * math.pow(2, 10 * (t / d - 1)) + b
	end
end

function Expo.easeOut(t, b, c, d)
	if t == d then
		return b + c
	else
		return c * (-math.pow(2, -10 * t / d) + 1) + b
	end
end

function Expo.easeInOut(t, b, c, d)
	if t == 0 then
		return b
	end

	if t == d then
		return b + c
	end

	t = t / d * 0.5

	if t < 1 then
		return c / 2 * math.pow(2, 10 * (t - 1)) + b
	end

	t = t - 1

	return c / 2 * (-math.pow(2, -10 * t) + 2) + b
end

Circ = {}

function Circ.easeIn(t, b, c, d)
	t = t / d

	return -c * (math.sqrt(1 - t * t) - 1) + b
end

function Circ.easeOut(t, b, c, d)
	t = t / d - 1

	return c * math.sqrt(1 - t * t) + b
end

function Circ.easeInOut(t, b, c, d)
	t = t / d * 0.5

	if t < 1 then
		return -c / 2 * (math.sqrt(1 - t * t) - 1) + b
	end

	t = t - 2

	return c / 2 * (math.sqrt(1 - t * t) + 1) + b
end

Elastic = {}

function Elastic.easeIn(t, b, c, d, a, p)
	if t == 0 then
		return b
	end

	t = t / d

	if t == 1 then
		return b + c
	end

	p = p or d * 0.3

	if not a or a < math.abs(c) then
		a = c

		local s = p / 4
	else
		local s = p / (2 * math.pi) * math.asin(c / a)
	end

	t = t - 1

	return -(a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
end

function Elastic.easeOut(t, b, c, d, a, p)
	if t == 0 then
		return b
	end

	t = t / d

	if t == 1 then
		return b + c
	else
		p = p or d * 0.3
	end

	if not a or a < math.abs(c) then
		a = c

		local s = p / 4
	else
		local s = p / (2 * math.pi) * math.asin(c / a)
	end

	return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
end

function Elastic.easeInOut(t, b, c, d, a, p)
	if t == 0 then
		return b
	end

	t = t / d * 0.5

	if t == 2 then
		return b + c
	end

	p = p or d * 0.44999999999999996

	if not a or a < math.abs(c) then
		a = c

		local s = p / 4
	else
		local s = p / (2 * math.pi) * math.asin(c / a)
	end

	if t < 1 then
		t = t - 1

		return -0.5 * (a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
	end

	t = t - 1

	return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) * 0.5 + c + b
end

Back = {}

function Back.easeIn(t, b, c, d, s)
	if s == nil then
		s = 1.70158
	end

	t = t / d

	return c * t * t * ((s + 1) * t - s) + b
end

function Back.easeOut(t, b, c, d, s)
	if s == nil then
		s = 1.70158
	end

	t = t / d - 1

	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function Back.easeInOut(t, b, c, d, s)
	if s == nil then
		s = 1.70158
	end

	t = t / d * 0.5

	if t < 1 then
		s = s * 1.525

		return c / 2 * (t * t * ((s + 1) * t - s)) + b
	end

	t = t - 2
	s = s * 1.525

	return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end

Bounce = {}

function Bounce.easeIn(t, b, c, d)
	return c - Bounce.easeOut(d - t, 0, c, d) + b
end

function Bounce.easeOut(t, b, c, d)
	t = t / d

	if t < 0.36363636363636365 then
		return c * (7.5625 * t * t) + b
	elseif t < 0.7272727272727273 then
		t = t - 0.5454545454545454

		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 0.9090909090909091 then
		t = t - 0.8181818181818182

		return c * (7.5625 * t * t + 0.9375) + b
	else
		t = t - 0.9545454545454546

		return c * (7.5625 * t * t + 0.984375) + b
	end
end

function Bounce.easeInOut(t, b, c, d)
	if t < d / 2 then
		return Bounce.easeIn(t * 2, 0, c, d) * 0.5 + b
	else
		return Bounce.easeOut(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b
	end
end

function ThatTween:ToValue(obj, duration, vars)
	local tb = {
		time = 0,
		obj = obj,
		duration = duration,
		from = vars.from,
		to = vars.to,
		vars = vars
	}

	if vars.ease == nil then
		vars.ease = Linear
	end

	table.insert(self.tweenlist, tb)

	return tb
end

function ThatTween:Update(timeStep)
	local deltb = {}

	for i, v in ipairs(self.tweenlist) do
		v.time = v.time + timeStep

		local tend = v.time >= v.duration
		local func = v.vars.update

		if func ~= nil then
			local ease = v.vars.ease
			local val = ease(v.time, 0, 1, v.duration)

			if tend then
				val = 1
			end

			local tval = val

			if v.from and v.to then
				tval = val * (v.to - v.from) + v.from
			end

			func(tval)
		end

		if tend then
			table.insert(deltb, i)

			local func = v.vars.complete

			if func ~= nil then
				func(v)
			end
		end
	end

	table.sort(deltb, function(a, b)
		return b < a
	end)

	for i, v in ipairs(deltb) do
		table.remove(self.tweenlist, v)
	end
end
