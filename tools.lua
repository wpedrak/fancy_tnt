local function range_dialog(itemstack, user, pointed_thing)
	if pointed_thing.type == 'nothing' or pointed_thing.type == "object" then
		return itemstack
	end
	local node    = minetest.get_node_or_nil(pointed_thing.under)
	
	if node.name == 'fancy_tnt:copy' then
		print('Hited copy tnt')
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