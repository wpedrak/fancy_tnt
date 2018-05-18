minetest.register_node("fancy_tnt:tnt8", {
    tiles = {"tnt_up.png", "tnt_bot.png", "tnt8.png"},
    groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
    on_punch = function(pos, node, puncher, pointed_thing)
        minetest.chat_send_all("tnt hitted!")
        for k, v in pairs(node) do
            minetest.chat_send_all("->" .. tostring(k))
            minetest.chat_send_all("<" .. tostring(v))
        end
        
    end
})

minetest.register_craft({
    output = 'fancy_tnt:tnt8 1',
    recipe = {
        {'default:wood', ''            , ''            },
        {''            , 'default:wood', ''            },
        {''            , ''            , 'default:wood'},
    }
})


minetest.register_abm({
    nodenames = {"default:dirt_with_grass"},
    interval = 2,
    chance = 100,
    action = function(pos)
        pos.y = pos.y + 1
        minetest.add_node(pos, {name="default:junglegrass"})
    end,
})