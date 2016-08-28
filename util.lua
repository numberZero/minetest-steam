-------------------------------------------------------------------------------

local zp = {x=0, y=0, z=1}
local xp = {x=1, y=0, z=0}
local zn = {x=0, y=0, z=-1}
local xn = {x=-1, y=0, z=0}
local yn = {x=0, y=-1, z=0}
local yp = {x=0, y=1, z=0}

local map_u = { [0] =
	xp, zn, xn, zp,
	xp, yp, xn, yn,
	xp, yn, xn, yp,
	yn, zn, yp, zp,
	yp, zn, yn, zp,
	xn, zn, xp, zp,
}

local map_v = { [0] =
	yp, yp, yp, yp,
	zp, zp, zp, zp,
	zn, zn, zn, zn,
	xp, xp, xp, xp,
	xn, xn, xn, xn,
	yn, yn, yn, yn,
}

local map_w = { [0] =
	zp, xp, zn, xn,
	yn, xp, yp, xn,
	yp, xp, yn, xn,
	zp, yn, zn, yp,
	zp, yp, zn, yn,
	zp, xn, zn, xp,
}

-------------------------------------------------------------------------------
-- @type tripod
-- @field core#vector u 1st axis (x with default rotation)
-- @field core#vector v 2nd axis (y with default rotation)
-- @field core#vector w 3rd axis (z with default rotation)

-------------------------------------------------------------------------------
-- @function [parent=steam#steam] facedir_to_tripod
-- @param #number facedir Node facedir
-- @return #tripod Axis tripod
function steam.facedir_to_tripod(facedir)
	return {
		u = map_u[facedir],
		v = map_v[facedir],
		w = map_w[facedir],
	}
end
