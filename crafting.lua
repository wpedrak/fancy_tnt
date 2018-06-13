minetest.register_craft({
    output = 'fancy_tnt:copy 1',
    recipe = {
        {'group:stone', 'group:stone', 'group:stone'},
        {'group:stone', 'group:stone', 'group:stone'},
        {'tnt:tnt',     'group:stone', 'group:stone'},
    }
})

minetest.register_craft({
    output = 'fancy_tnt:maze 1',
    recipe = {
        {'',        'group:stone', 'group:stone'},
        {'',        'group:stone', ''           },
        {'tnt:tnt', 'group:stone', ''           },
    }
})

minetest.register_craft({
    output = 'fancy_tnt:hammer 1',
    recipe = {
        {'group:stone', 'group:stone', ''           },
        {'group:stone', 'group:stone', 'group:stone'},
        {'',            'group:stick', ''           },
    }
})