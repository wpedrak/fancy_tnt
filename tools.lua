local mod_path = minetest.get_modpath("fancy_tnt")
local H = dofile(mod_path..'/helpers.lua')

local copy_tnt_hammer_formspec_context = {}
local maze_tnt_hammer_formspec_context = {}
local fill_pos = {
	Filled = 1,
	Empty  = 2,
}

local function create_copy_tnt_formspec(pos, user_name)
	copy_tnt_hammer_formspec_context[user_name] = {pos=pos}
	local x, y, z = H.get_meta_xyz(pos)
	local meta = minetest.get_meta(pos)
	local fill_type = meta:get_string('fill_type')
	minetest.show_formspec(user_name, "fancy_tnt:copy_edit",
		"size[4,6]" ..
		'bgcolor[#000000da]' ..
		"label[0,0;Specify size of cuboid]" ..
		'field[1,1.5;3,1;x;x (0-64);' .. x .. ']' ..
		'field[1,2.5;3,1;y;y (0-64);' .. y .. ']' ..
		'field[1,3.5;3,1;z;z (0-64);' .. z .. ']' ..
		'label[0.7,3.9;Fill type]'..
		'dropdown[0.7,4.4;3,1;fill_type;Filled,Empty;'..fill_pos[fill_type]..']' ..
		"button_exit[1,5.3;2,1;exit;Save]"
	)
end

local function create_maze_tnt_formspec(pos, user_name)
	maze_tnt_hammer_formspec_context[user_name] = {pos=pos}
	local meta = minetest.get_meta(pos)
	minetest.show_formspec(user_name, "fancy_tnt:maze_edit",
		"size[16,10]" ..
		'bgcolor[#000000da]' .. 
		'list[context;fields;0,0;8,4;]' ..
		'list[current_player;main;0,5;8,4;]'
	)
end

local function hammer_use(itemstack, user, pointed_thing)
	if pointed_thing.type == 'nothing' or pointed_thing.type == "object" then
		return itemstack
	end
	local pos  = pointed_thing.under
	local user_name = user:get_player_name()
	local node = minetest.get_node_or_nil(pos)
	

	if node.name == 'fancy_tnt:copy' then
		create_copy_tnt_formspec(pos, user_name)
	elseif node.name == 'fancy_tnt:maze' then
		create_maze_tnt_formspec(pos, user_name)
	end 

	local meta = minetest.get_meta(pos)
	local tab = meta:to_table()
	print(dump(tab))
	if tab.inventory.main then
		local fst = tab.inventory.main[1]
		print(dump(fst:to_table()))
	end

	return itemstack
end

minetest.register_tool("fancy_tnt:hammer", {
	description = "Hammer",
	inventory_image = "hammer.png",
	tool_capabilities = {
		full_punch_interval = 0.7,
		max_drop_level=1,
		groupcaps={
			snappy={times={[1]=1.90, [2]=0.90, [3]=0.30}, uses=40, maxlevel=3},
		},
		damage_groups = {fleshy=8},
	},
	sound = {breaks = "default_tool_breaks"},
	on_use   = hammer_use,
	on_place = hammer_use,
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "fancy_tnt:copy_edit" then
        return false
	end
	
    local context = copy_tnt_hammer_formspec_context[player:get_player_name()]
	print('recieve_copy')
	-- print(dump(fields))

	if not fields.quit then
		return true
	end

	if context then
		local pos = context.pos
		copy_tnt_hammer_formspec_context[player:get_player_name()] = nil

        if not H.validate(fields, {'x', 'y', 'z'}) then
            return true
        end

        local bounds = {min=0, max=64}
        local x = H.stoi(fields.x, bounds)
        local y = H.stoi(fields.y, bounds)
        local z = H.stoi(fields.z, bounds)
		H.set_meta_xyz(pos, {x, y, z})
		local meta = minetest.get_meta(pos)
		meta:set_string('fill_type', fields.fill_type)
        H.set_xyz_description(pos)
		
        return true
	else
		print('No context!')
		minetest.chat_send_player(player:get_player_name(), "Something went wrong, try again.")
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "fancy_tnt:maze_edit" then
        return false
	end
	
    local context = maze_tnt_hammer_formspec_context[player:get_player_name()]
	print('recieve_maze')
	-- print(dump(fields))

	if not fields.quit then
		return true
	end

	if context then
		local pos = context.pos
		maze_tnt_hammer_formspec_context[player:get_player_name()] = nil
		
        return true
	else
		print('No context!')
        minetest.chat_send_player(player:get_player_name(), "Something went wrong, try again.")
    end
end)