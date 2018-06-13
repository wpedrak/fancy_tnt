local mod_path = minetest.get_modpath("fancy_tnt")
local H = dofile(mod_path..'/helpers.lua')

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
        meta:set_string('fill_type', 'Filled')
        H.set_meta_xyz(pos, {3,3,3})
        H.set_xyz_description(pos)
    end,

    on_punch = function(pos, node, puncher, pointed_thing)
        local punch_item_name = puncher:get_wielded_item():get_name()
        if punch_item_name == "default:torch" then
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
        local x, y, z = H.get_meta_xyz(pos)
        local meta = minetest.get_meta(pos)
        local fill_type = meta:get_string('fill_type')
        meta:set_string("infotext", "")
        local cuboid_size = {x=x, y=y, z=z}
		H.make_cuboid(pos, cuboid_size, fill_type)
    end,
    -- unaffected by explosions
    on_blast = function() end,
    on_construct = function(pos)
        minetest.sound_play("tnt_ignite", {pos = pos})
        minetest.get_node_timer(pos):start(3)
        -- minetest.check_for_falling(pos)
    end,
})

minetest.register_node("fancy_tnt:maze", {
    description = "Maze TNT",
    tiles = {"tnt_up.png", 
             "tnt_bot.png", 
             "tnt_maze_right.png",
             "tnt_maze_side.png",
             "tnt_maze_back.png",
             "tnt_maze_side.png",
            },
    groups = {dig_immediate = 2, mesecon = 2, tnt = 1, flammable = 5},
    sounds = default.node_sound_wood_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)

        meta:from_table({
            inventory = {
                fields = { -- 6 x 10
                    "", "", "", "", "", "", "", "", "", "",
                    "", "", "", "", "", "", "", "", "", "",
                    "", "", "", "", "", "", "", "", "", "",
                    "", "", "", "", "", "", "", "", "", "",
                    "", "", "", "", "", "", "", "", "", "",
                    "", "", "", "", "", "", "", "", "", "",
                }
            },
            fields = {}
        })
    end,

    on_punch = function(pos, node, puncher, pointed_thing)
        local punch_item_name = puncher:get_wielded_item():get_name()
        if punch_item_name == "default:torch" then
            minetest.swap_node(pos, {name="fancy_tnt:maze_burning"})
            minetest.registered_nodes["fancy_tnt:maze_burning"].on_construct(pos)
            return
        end
    end,
})

minetest.register_node("fancy_tnt:maze_burning", {
    tiles = {"tnt_up_burning.png",
             "tnt_bot_burning.png",
             "tnt_maze_right_burning.png",
             "tnt_maze_side_burning.png",
             "tnt_maze_back_burning.png",
             "tnt_maze_side_burning.png",
            },
    groups = {falling_node=1},
    sounds = default.node_sound_wood_defaults(),
    light_source = 5,
    on_timer = function(pos, elapsed)
        minetest.sound_play("tnt_explode", {pos = pos, gain = 1.5, max_hear_distance = 128})
        local meta = minetest.get_meta(pos)
        local maze2d = H.reshape(meta:to_table().inventory.fields, {6, 10})
        minetest.remove_node(pos)
        H.make_maze(pos, maze2d)
    end,
    -- unaffected by explosions
    on_blast = function() end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        minetest.sound_play("tnt_ignite", {pos = pos})
        minetest.get_node_timer(pos):start(3)
    end,
})