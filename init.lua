local function place_if_air(pos, name)
    local node = minetest.get_node_or_nil(pos)
    if node and node.name == "air" then
        minetest.swap_node(pos, {name=name})
    end
end

local function copy2(pos)
    local pos1b = vector.subtract(pos, {x=0, y=1, z=0})
    local nodeb = minetest.get_node_or_nil(pos1b)
    if nodeb then
        local pos1t = vector.add(pos, {x=0, y=1, z=0})
        place_if_air(pos1t, nodeb.name)
        local pos2t = vector.add(pos, {x=0, y=2, z=0})
        place_if_air(pos2t, nodeb.name)
        minetest.remove_node(pos)
    end
end

minetest.register_node("fancy_tnt:copy", {
    description = "Copying TNT",
    tiles = {"tnt_up.png", "tnt_bot.png", "tnt8.png"},
    groups = {dig_immediate = 2, mesecon = 2, tnt = 1, flammable = 5},
    sounds = default.node_sound_wood_defaults(),
    on_punch = function(pos, node, puncher, pointed_thing)
        if puncher:get_wielded_item():get_name() == "default:torch" then
            minetest.swap_node(pos, {name="fancy_tnt:copy_burning"})
            minetest.registered_nodes["fancy_tnt:copy_burning"].on_construct(pos)
        end
    end
})

minetest.register_node("fancy_tnt:copy_burning", {
    tiles = {"tnt_up_burning.png", "tnt_bot_burning.png", "tnt8_burning.png"},
    groups = {falling_node=1},
    sounds = default.node_sound_wood_defaults(),
    light_source = 5,
    on_timer = function(pos, elapsed)
        minetest.sound_play("tnt_explode", {pos = pos, gain = 1.5,
        max_hear_distance = 128})
        copy2(pos)
    end,
    -- unaffected by explosions
    on_blast = function() end,
    on_construct = function(pos)
        minetest.sound_play("tnt_ignite", {pos = pos})
        minetest.get_node_timer(pos):start(3)
        -- minetest.check_for_falling(pos)
    end,
})

minetest.register_craft({
    output = 'fancy_tnt:copy 1',
    recipe = {
        {'', 'group:stone', ''},
        {'', 'tnt:tnt',   ''},
        {'', 'group:stone', ''},
    }
})
