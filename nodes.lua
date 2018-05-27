local function make_floor(pos, floor_size)
	local pos_top     = vector.add(pos, {x=0, y=1, z=0})
	local node_top    = minetest.get_node_or_nil(pos_top)
    
    if not node_top then
        minetest.remove_node(pos)
        return
    end
    
    minetest.remove_node(pos_top)
    
	local pos1   	  = vector.subtract(pos, {x=floor_size, y=0, z=floor_size})
	local pos2 		  = vector.add     (pos, {x=floor_size, y=0, z=floor_size})
	local vm          = minetest.get_voxel_manip()
	local emin, emax  = vm:read_from_map(pos1, pos2)
    local data        = vm:get_data()
    local c_node_top  = minetest.get_content_id(node_top.name)
    local va          = VoxelArea:new{
                                        MinEdge = emin,
                                        MaxEdge = emax,
                                    }
    for z = pos1.z, pos2.z do
        for y = pos1.y, pos2.y do
            for x = pos1.x, pos2.x do
                local vi = va:index(x, y, z)
                data[vi] = c_node_top
            end
        end
    end
    
    vm:set_data(data)
    vm:write_to_map(data)
    vm:update_map()
    
	-- minetest.chat_send_all(dump(node_top))
	
end

local function update_description(pos)
	local meta = minetest.get_meta(pos)
	local counter = meta:get_int('punch_counter')
	meta:set_string("infotext", counter)
end


minetest.register_node("fancy_tnt:copy", {
    description = "Copying TNT",
    tiles = {"tnt_up.png", "tnt_bot.png", "tnt8.png"},
    groups = {dig_immediate = 2, mesecon = 2, tnt = 1, flammable = 5},
    sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int('punch_counter', 0)
		update_description(pos)
	end,
    on_punch = function(pos, node, puncher, pointed_thing)
        local punch_item_name = puncher:get_wielded_item():get_name()
        if punch_item_name == "fancy_tnt:hammer" then
            local meta = minetest.get_meta(pos)
            local counter = meta:get_int('punch_counter')
            meta:set_int('punch_counter', counter+1)
            update_description(pos)
            return
        end
        if punch_item_name == "default:torch" then
            minetest.swap_node(pos, {name="fancy_tnt:copy_burning"})
            minetest.registered_nodes["fancy_tnt:copy_burning"].on_construct(pos)
        end
    end,
})

minetest.register_node("fancy_tnt:copy_burning", {
    tiles = {"tnt_up_burning.png", "tnt_bot_burning.png", "tnt8_burning.png"},
    groups = {falling_node=1},
    sounds = default.node_sound_wood_defaults(),
    light_source = 5,
    on_timer = function(pos, elapsed)
        minetest.sound_play("tnt_explode", {pos = pos, gain = 1.5,
        max_hear_distance = 128})
        local meta        = minetest.get_meta(pos)
        local floor_size  = meta:get_int('punch_counter')
        meta:set_string("infotext", "")
		make_floor(pos, floor_size)
    end,
    -- unaffected by explosions
    on_blast = function() end,
    on_construct = function(pos)
        minetest.sound_play("tnt_ignite", {pos = pos})
        minetest.get_node_timer(pos):start(3)
        -- minetest.check_for_falling(pos)
    end,
})
