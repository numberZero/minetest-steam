-- This file is part of the steam/rotary Minetest mod

local xp = {x=1, y=0, z=0}
local xn = {x=-1, y=0, z=0}
local yp = {x=0, y=1, z=0}
local yn = {x=0, y=-1, z=0}
local zp = {x=0, y=0, z=1}
local zn = {x=0, y=0, z=-1}

xp.p = xp; xp.n = xn; xn.p = xn; xn.n = xp
yp.p = yp; yp.n = yn; yn.p = yn; yn.n = yp
zp.p = zp; zp.n = zn; zn.p = zn; zn.n = zp

local map1 = { [0] =
	xp, zn, xn, zp,
	xp, yp, xn, yn,
	xp, yn, xn, yp,
	yn, zn, yp, zp,
	yp, zn, yn, zp,
	xn, zn, xp, zp,
}

local map2 = { [0] =
	yp, yp, yp, yp,
	zp, zp, zp, zp,
	zn, zn, zn, zn,
	xp, xp, xp, xp,
	xn, xn, xn, xn,
	yn, yn, yn, yn,
}

local map3 = { [0] =
	zp, xp, zn, xn,
	yn, xp, yp, xn,
	yp, xp, yn, xn,
	zp, yn, zn, yp,
	zp, yp, zn, yn,
	zp, xn, zn, xp,
}

-- Axis tripod:
-- table with 3 members, u, v, w, representing the basis vectors
-- Each vector has additional members p and n that contains positive- and negative-direction vector
--
-- All tripods share the same vectors, so that you can compare them by == instead of vector.equals, although that’s not recommended

-- Returns {u, v, w} axis tripod corresponding to the given facedir
-- Returns standard (u=x, v=y, w=z) tripod if facedir=0
function rotary.facedir_to_tripod(facedir)
	return {
		u = map1[facedir],
		v = map2[facedir],
		w = map3[facedir],
	}
end

-- Returns {u, v, w} axis tripod corresponding to the given facedir
-- u = right, v = up, w = forward
-- Returns rotary-specific gearbox-friendly (u=z, v=x, w=y) tripod if facedir=0
function rotary.facedir_to_tripod_gbox(facedir)
	return {
		u = map3[facedir],
		v = map1[facedir],
		w = map2[facedir],
	}
end
