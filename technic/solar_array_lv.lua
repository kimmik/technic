-- The solar array is an assembly of panels into a powerful array
-- The assembly can deliver more energy than the individual panel because
-- of the transformer unit which converts the panel output variations into
-- a stable supply.
-- Solar arrays are not able to store large amounts of energy.
-- The LV arrays are used to make medium voltage arrays.
minetest.register_node("technic:solar_array_lv", {
	tiles = {"technic_lv_solar_array_top.png", "technic_lv_solar_array_bottom.png", "technic_lv_solar_array_side.png",
		"technic_lv_solar_array_side.png", "technic_lv_solar_array_side.png", "technic_lv_solar_array_side.png"},
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
	sounds = default.node_sound_wood_defaults(),
    	description="LV Solar Array",
	active = false,
	technic_power_machine=1,
	internal_EU_buffer=0;
	internal_EU_buffer_size=1000;
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = true,	
	node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_float("technic_power_machine", 1)
		meta:set_float("internal_EU_buffer", 0)
		meta:set_float("internal_EU_buffer_size", 1000)

		meta:set_string("infotext", "LV Solar Array")
		meta:set_float("active", false)
	end,
})

minetest.register_craft({
	output = 'technic:solar_array_lv 1',
	recipe = {
		{'technic:solar_panel', 'technic:solar_panel',    'technic:solar_panel'},
		{'technic:solar_panel', 'technic:lv_transformer', 'technic:solar_panel'},
		{'default:steel_ingot', 'technic:lv_cable',       'default:steel_ingot'},

	}
})

minetest.register_abm(
	{nodenames = {"technic:solar_array_lv"},
	interval   = 1,
	chance     = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		-- The action here is to make the solar array produce power
		-- Power is dependent on the light level and the height above ground
		-- 130m and above is optimal as it would be above cloud level.
                -- Height gives 1/4 of the effect, light 3/4. Max. effect is 160EU for the array.
                -- There are many ways to cheat by using other light sources like lamps.
                -- As there is no way to determine if light is sunlight that is just a shame.
                -- To take care of some of it solar arrays do not work outside daylight hours or if
                -- built below -10m
		local pos1={}
		pos1.y=pos.y+1
		pos1.x=pos.x
		pos1.z=pos.z

		local light = minetest.env:get_node_light(pos1, nil)
		local time_of_day = minetest.env:get_timeofday()
		local meta = minetest.env:get_meta(pos)
		if light == nil then light = 0 end
		-- turn on array only during day time and if sufficient light
                -- I know this is counter intuitive when cheating by using other light sources.
		if light >= 12 and time_of_day>=0.24 and time_of_day<=0.76 and pos.y > -10 then
			local internal_EU_buffer      = meta:get_float("internal_EU_buffer")
			local internal_EU_buffer_size = meta:get_float("internal_EU_buffer_size")
			local charge_to_give          = math.floor(light*(light*0.5333+pos1.y/130*2.6667))
			if charge_to_give<0   then charge_to_give=0 end
			if charge_to_give>160 then charge_to_give=160 end
			if internal_EU_buffer+charge_to_give>internal_EU_buffer_size then
			   charge_to_give=internal_EU_buffer_size-internal_EU_buffer
			end
			meta:set_string("infotext", "Solar Array is active ("..charge_to_give.."EU)")
			meta:set_float("active",1)
			internal_EU_buffer=internal_EU_buffer+charge_to_give
			meta:set_float("internal_EU_buffer",internal_EU_buffer)
			
		else
			meta:set_string("infotext", "Solar Array is inactive");
			meta:set_float("active",0)
		end
	end,
}) 

register_LV_machine ("technic:solar_array_lv","PR")
