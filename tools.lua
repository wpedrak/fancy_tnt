local mod_path = minetest.get_modpath("fancy_tnt")
local H = dofile(mod_path..'/helpers.lua')

local fancy_tnt_hammer_formspec_context = {}
local fill_pos = {
	Filled = 1,
	Empty  = 2,
}

local function range_dialog(itemstack, user, pointed_thing)
	if pointed_thing.type == 'nothing' or pointed_thing.type == "object" then
		return itemstack
	end
	local pos = pointed_thing.under
	local node    = minetest.get_node_or_nil(pos)
	
	if node.name == 'fancy_tnt:copy' then
		local user_name = user:get_player_name()
		fancy_tnt_hammer_formspec_context[user_name] = {pos=pos}
		local x, y, z = H.get_meta_xyz(pos)
		local meta = minetest.get_meta(pos)
		local fill_type = meta:get_string('fill_type')
		minetest.show_formspec(user_name, "fancy_tnt:edit",
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
	on_use   = range_dialog,
	on_place = range_dialog,
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "fancy_tnt:edit" then
        return false
	end
	
    local context = fancy_tnt_hammer_formspec_context[player:get_player_name()]
	print('recieve')
	print(dump(fields))

	if not fields.quit then
		return true
	end

	if context then
		local pos = context.pos
		fancy_tnt_hammer_formspec_context[player:get_player_name()] = nil

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
		print('wrong')
        minetest.chat_send_player(player:get_player_name(),
                "Something went wrong, try again.")
    end
end)