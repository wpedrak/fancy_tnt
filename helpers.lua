local M = {}

function M.set_meta_xyz(pos, tab)
    local meta = minetest.get_meta(pos)
    meta:set_int('x', tab.x or tab[1])
    meta:set_int('y', tab.y or tab[2])
    meta:set_int('z', tab.z or tab[3])
end

function M.get_meta_xyz(pos)
    local meta = minetest.get_meta(pos)
    return meta:get_int('x'),
           meta:get_int('y'),
           meta:get_int('z')
end

function M.set_xyz_description(pos)
    local meta = minetest.get_meta(pos)
    local x, y, z = M.get_meta_xyz(pos)
    local fill_type = meta:get_string('fill_type')
    meta:set_string("infotext", '('..x..', '..
                                     y..', '..
                                     z..')\n'..
                                fill_type)
end

function M.stoi(str, bounds)
    if str == '' then
        return bounds.min
    end

    local int = 0+str
    int = math.max(int, bounds.min)
    int = math.min(int, bounds.max)
    return math.floor(int)
end

function M.validate(form, numeric)
    local item_count = 0
    for _,_ in pairs(form) do
        item_count = item_count + 1
    end
    if item_count == 1 and form.quit then
        return false
    end
    local numeric_pattern = '^-?%d*$'
    for _,v in ipairs(numeric) do
        if not string.find(form[v], numeric_pattern) then
            return false
        end
    end
    return true
end

function M.make_cuboid(pos, dims, fill_type)
	local pos_top     = vector.add(pos, {x=0, y=1, z=0})
	local node_top    = minetest.get_node_or_nil(pos_top)
    
    if not node_top then
        minetest.remove_node(pos)
        return
    end
    
    minetest.remove_node(pos_top)
    
    local is_filled   = fill_type == 'Filled'
    local diff        = vector.subtract(dims, {x=1, y=1, z=1})
	local pos2 		  = vector.add(pos, diff)
	local vm          = minetest.get_voxel_manip()
	local emin, emax  = vm:read_from_map(pos, pos2)
    local data        = vm:get_data()
    local c_node_top  = minetest.get_content_id(node_top.name)
    local c_air       = minetest.get_content_id('air')
    local va          = VoxelArea:new{
                                        MinEdge = emin,
                                        MaxEdge = emax,
                                    }
    for z = pos.z, pos2.z do
        for y = pos.y, pos2.y do
            for x = pos.x, pos2.x do
                local vi = va:index(x, y, z)
                if (not is_filled and
                    z ~= pos.z and z ~= pos2.z and
                    y ~= pos.y and y ~= pos2.y and
                    x ~= pos.x and x ~= pos2.x) then
                    
                    data[vi] = c_air
                else
                    data[vi] = c_node_top
                end
            end
        end
    end
    if fill_type == 'Empty' then
        for z = pos.z+1, pos2.z-1 do
            for y = pos.y+1, pos2.y-1 do
                for x = pos.x+1, pos2.x-1 do
                    local vi = va:index(x, y, z)
                    data[vi] = c_air
                end
            end
        end
    end
    
    vm:set_data(data)
    vm:write_to_map(data)
    vm:update_map()
    
	-- minetest.chat_send_all(dump(node_top))
	
end

return M