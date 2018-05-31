local function make_cuboid(pos, dims)
	local pos_top     = vector.add(pos, {x=0, y=1, z=0})
	local node_top    = minetest.get_node_or_nil(pos_top)
    
    if not node_top then
        minetest.remove_node(pos)
        return
    end
    
    minetest.remove_node(pos_top)
    
    local diff        = vector.subtract(dims, {x=1, y=1, z=1})
	local pos2 		  = vector.add(pos, diff)
	local vm          = minetest.get_voxel_manip()
	local emin, emax  = vm:read_from_map(pos, pos2)
    local data        = vm:get_data()
    local c_node_top  = minetest.get_content_id(node_top.name)
    local va          = VoxelArea:new{
                                        MinEdge = emin,
                                        MaxEdge = emax,
                                    }
    for z = pos.z, pos2.z do
        for y = pos.y, pos2.y do
            for x = pos.x, pos2.x do
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

local function validate(form, numeric)
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

local function stoi(str, bounds)
    if str == '' then
        return bounds.min
    end

    local int = 0+str
    int = math.max(int, bounds.min)
    int = math.min(int, bounds.max)
    return math.floor(int)
end

local function update_description(pos)
	local meta = minetest.get_meta(pos)
    local x = meta:get_int('x')
    local y = meta:get_int('y')
    local z = meta:get_int('z')
	meta:set_string("infotext", '('..x..', '..y..', '..z..')')
end

local function update_formspec(pos)
    local meta = minetest.get_meta(pos)
    local x = meta:get_int('x')
    local y = meta:get_int('y')
    local z = meta:get_int('z')
    meta:set_string("formspec",
    "size[4,5]" ..
    "label[0,0;Specify size of cuboid]" ..
    'field[1,1.5;3,1;x;x (0-64);' .. x .. ']' ..
    'field[1,2.5;3,1;y;y (0-64);' .. y .. ']' ..
    'field[1,3.5;3,1;z;z (0-64);' .. z .. ']' ..
    "button_exit[1,4;2,1;exit;Save]")
end

local function set_meta_xyz(pos, tab)
    local meta = minetest.get_meta(pos)
    meta:set_int('x', tab[1])
    meta:set_int('y', tab[2])
    meta:set_int('z', tab[3])
end

local function get_meta_xyz(pos)
    local meta = minetest.get_meta(pos)
    return meta:get_int('x'),
           meta:get_int('y'),
           meta:get_int('z')
end

-- local tnt_formspec_context = {}

--         land_formspec_context[name] = {id = param}

--         minetest.show_formspec(name, "fancy_tnt:edit",
--                 "size[4,4]" ..
--                 "field[1,1;3,1;plot;Plot Name;]" ..
--                 "field[1,2;3,1;owner;Owner;]" ..
--                 "button_exit[1,3;2,1;exit;Save]")



-- --
-- -- Step 2) retrieve context when player submits the form
-- --
-- minetest.register_on_player_receive_fields(function(player, formname, fields)
--     if formname ~= "mylandowner:edit" then
--         return false
--     end

--     -- Load information
--     local context = land_formspec_context[player:get_player_name()]

--     if context then
--         minetest.chat_send_player(player:get_player_name(), "Id " ..
--                 context.id .. " is now called " .. fields.plot ..
--                 " and owned by " .. fields.owner)

--         -- Delete context if it is no longer going to be used
--         land_formspec_context[player:get_player_name()] = nil

--         return true
--     else
--         -- Fail gracefully if the context does not exist.
--         minetest.chat_send_player(player:get_player_name(),
--                 "Something went wrong, try again.")
--     end
-- end)

minetest.register_node("fancy_tnt:copy", {
    description = "Copying TNT",
    tiles = {"tnt_up.png", 
             "tnt_bot.png", 
             "tnt_copy_right.png",
             "tnt_copy_side.png",
             "tnt_copy_back.png",
             "tnt_copy_side.png",
            },
    groups = {dig_immediate = 2, mesecon = 2, tnt = 1, flammable = 5},
    sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
        meta:set_int('x', 3)
        meta:set_int('y', 3)
        meta:set_int('z', 3)
        update_description(pos)
        update_formspec(pos)
    end,
    on_receive_fields = function(pos, formname, fields, player)
        -- minetest.chat_send_all(dump(fields))
        local meta = minetest.get_meta(pos)
        if not validate(fields, {'x', 'y', 'z'}) then
            return
        end

        local bounds = {min=0, max=64}
        local x = stoi(fields.x, bounds)
        local y = stoi(fields.y, bounds)
        local z = stoi(fields.z, bounds)
        set_meta_xyz(pos, {x, y, z})
        update_description(pos)
        update_formspec(pos)
    end,

    on_punch = function(pos, node, puncher, pointed_thing)
        local punch_item_name = puncher:get_wielded_item():get_name()
        if punch_item_name == "fancy_tnt:hammer" then
            minetest.swap_node(pos, {name="fancy_tnt:copy_burning"})
            minetest.registered_nodes["fancy_tnt:copy_burning"].on_construct(pos)
            return
        end
    end,
})

minetest.register_node("fancy_tnt:copy_burning", {
    tiles = {"tnt_up_burning.png",
             "tnt_bot_burning.png",
             "tnt_copy_right_burning.png",
             "tnt_copy_side_burning.png",
             "tnt_copy_back_burning.png",
             "tnt_copy_side_burning.png",
            },
    groups = {falling_node=1},
    sounds = default.node_sound_wood_defaults(),
    light_source = 5,
    on_timer = function(pos, elapsed)
        minetest.sound_play("tnt_explode", {pos = pos, gain = 1.5,
        max_hear_distance = 128})
        x, y, z = get_meta_xyz(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "")
        cuboid_size = {x=x, y=y, z=z}
		make_cuboid(pos, cuboid_size)
    end,
    -- unaffected by explosions
    on_blast = function() end,
    on_construct = function(pos)
        minetest.sound_play("tnt_ignite", {pos = pos})
        minetest.get_node_timer(pos):start(3)
        -- minetest.check_for_falling(pos)
    end,
})
