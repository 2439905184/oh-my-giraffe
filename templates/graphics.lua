-- require the atlas here?
local quads = require 'templates/quads'
return {
	dusk = {
		variants = {
			{
				static = quads['assets/images/sky/dusk.png']
			},
		},
	},

	dawn = {
		variants = {
			{
				static = quads['assets/images/sky/dawn.png']
			},
		},
	},

	sky = {
		variants = {
			{
				static = quads['assets/images/sky/pixel.png']
			},
		},
	},

	pixel = {
		variants = {
			{
				static = quads['assets/images/sky/pixel.png']
			},
		},
	},

	orb = {
		variants = {
			{
				static = quads['assets/images/edibles/orb.png']
			},
		},
	},

	lion_icon = {
		variants = {
			{
				static = quads['assets/images/lion/icon.png']
			},
		},
	},

	lion_head = {
		variants = {
			{
				static = quads['assets/images/lion/head2.png']
			},
		},
	},

	lion_head_sleeping = {
		variants = {
			{
				static = quads['assets/images/lion/head2_sleepy.png']
			},
		},
	},

	lioness_head = {
		variants = {
			{
				weight = 1.5,
				static = quads['assets/images/lion/head.png']
			},
		},
	},

	lioness_head_sleeping = {
		variants = {
			{
				static = quads['assets/images/lion/head_sleepy.png']
			},
		},
	},

	lion_body = {
		variants = {
			{
				static = quads['assets/images/lion/body.png']
			}
		},
	},

	lion_legs_sleeping_hind = {
		variants = {
			{
				static = quads['assets/images/lion/legs_hind_sleeping.png'],
			},

		},
	},

	lion_legs_sleeping_fore = {
		variants = {
			{
				static = quads['assets/images/lion/legs_hind_sleeping.png'],
			},

		},
	},


	lion_legs_leaping_hind = {
		variants = {
			{
				static = quads['assets/images/lion/legs_hind_leaping.png'],
			},

		},
	},

	lion_legs_leaping_fore = {
		variants = {
			{
				static = quads['assets/images/lion/legs_fore_leaping.png'],
			},

		},
	},

	lion_legs = {
		variants = {
			{
				frames = 8,
				interval = 0.05,
				static = quads['assets/images/lion/legs.png'],
			},

		},
	},

	lion_tail = {
		variants = {
			{
				frames = 6,
				interval = 0.1,
				static = quads['assets/images/lion/tail.png'],
			},

		},
	},

	giraffe_tail_resting = {
		variants = {
			{
				static = quads['assets/images/giraffe/tail_down.png'],
			},
		},
	},

	giraffe_tail_flipped = {
		variants = {
			{
				static = quads['assets/images/giraffe/tail_flipped.png'],
			},

		},
	},

	giraffe_tail_running = {
		variants = {
			{
				frames = 6,
				interval = 0.2,
				static = quads['assets/images/giraffe/tail.png'],
			},

		},
	},

	chewing = {
		variants = {
			{
				frames = 4,
				interval = 0.05,
				static = quads['assets/images/giraffe/chewing.png'],
			},

		},
	},

	giraffe_head_blink = {
		variants = {
			{
				static = quads['assets/images/giraffe/head_wink.png'],
			},

		},
	},

	giraffe_head = {
		variants = {
			{
				static = quads['assets/images/giraffe/head.png'],
			},

		},
	},

	giraffe_horn = {
		variants = {
			{
				static = quads['assets/images/giraffe/horns.png'],
			},

		},
	},

	giraffe_spot = {
		variants = {
			{
				static = quads['assets/images/giraffe/spot.png'],
			},

		},
	},

	giraffe_ear = {
		variants = {
			{
				static = quads['assets/images/giraffe/ear.png'],
			},

		},
	},

	giraffe_body = {
		variants = {
			{
				static = quads['assets/images/giraffe/body.png'],
			},

		},
	},

	mouth = {
		variants = {
			{
				static = quads['assets/images/giraffe/mouth.png'],
			},

		},
	},

	legs = {
		variants = {
			{
				frames = 8,
				interval = 0.1,
				static = quads['assets/images/giraffe/legs.png'],
			},

		},
	},

	legs_flipped = {
		variants = {
			{
				static = quads['assets/images/giraffe/legs_flipped.png'],
			},

		},
	},

	legs_resting = {
		variants = {
			{
				static = quads['assets/images/giraffe/legs_resting.png'],
			},

		},
	},

	legs_resting_hind = {
		variants = {
			{
				static = quads['assets/images/giraffe/legs_resting_hind.png'],
			},

		},
	},

	legs_skidding = {
		variants = {
			{
				frames = 2,
				interval = 0.07,
				static = quads['assets/images/giraffe/legs_skidding.png'],
			},

		},
	},

	legs_jumping = {
		variants = {
			{
				static = quads['assets/images/giraffe/legs_jumping.png'],
			},

		},
	},

	grass = {
		variants = {
			{
				static = quads['assets/images/grass/grass.png'],
			},
		},
	},

	grass_tuft = {
		variants = {
			{
				static = quads['assets/images/grass/bunch1.png'],
			},
			{
				static = quads['assets/images/grass/bunch2.png'],
			},
			{
				static = quads['assets/images/grass/bunch3.png'],
			},
		},
	},

	mountain = {
		variants = {
			{
				static = quads['assets/images/moutains/mountain.png'],
			},

		},
	},

	hill_1 = {
		variants = {
			{
				static = quads['assets/images/hills/hill1-1.png'],
			},
			{
				static = quads['assets/images/hills/hill1-2.png'],
			},
			{
				weight = 5,
				static = quads['assets/images/hills/hill1-3.png'],
			},
			{
				static = quads['assets/images/hills/hill1-4.png'],
			},

		},
	},

	hill_2 = {
		variants = {
			{
				weight = 1,
				static = quads['assets/images/hills/hill2.png'],
			},

		},
	},

	hill_3 = {
		variants = {
			{
				static = quads['assets/images/hills/hill3.png'],
			},

		},
	},

	hill_4 = {
		variants = {
			{
				static = quads['assets/images/hills/hill4.png'],
			},

		},
	},

	hill_5 = {
		variants = {
			{
				static = quads['assets/images/hills/hill5.png'],
			},

		},
	},

	hill_6 = {
		variants = {
			{
				static = quads['assets/images/hills/hill6.png'],
			},

		},
	},

	boulder = {
		variants = {
			{
				static = quads['assets/images/rocks/boulder1.png'],
			},
			{
				static = quads['assets/images/rocks/boulder2.png'],
			},
			{
				static = quads['assets/images/rocks/boulder3.png'],
			},
		},
	},

	cloud = {
		variants = {
			{
				static = quads['assets/images/clouds/cloud1.png'],
			},
			{
				static = quads['assets/images/clouds/cloud2.png'],
			},
			{
				static = quads['assets/images/clouds/cloud3.png'],
			},
			{
				static = quads['assets/images/clouds/cloud4.png'],
			},

		},
	},

	-- todo
	trees_far = {
		variants = {
			{
				static = quads['assets/images/trees/bgtree1.png'],
			},
			{
				static = quads['assets/images/trees/bgtree2.png'],
			},

		},
	},

	trees_middle = {
		variants = {
			{
				static = quads['assets/images/trees/mgtree1.png'],
			},

		},
	},

	trees_near = {
		variants = {
			{
				weight = 2,
				static = quads['assets/images/trees/fgtree1.png'],
			},
			{
				static = quads['assets/images/trees/fgtree2.png'],
			},
			{
				weight = 2,
				static = quads['assets/images/trees/fgtree3.png'],
			},

		},
	},

	edible = {
		variants = {
			{
				weight = 40,
				static = quads['assets/images/edibles/eggplant.png'],
			},
			{
				weight = 30,
				static = quads['assets/images/edibles/fuschia.png'],
			},
			{
				weight = 5,
				static = quads['assets/images/edibles/cocoa.png'],
			},
			--[[
			{
				weight = 30,
				static = quads['assets/images/edibles/pineapple.png'],
			},
			]]--
			--[[
			{
				weight = 1,
				static = quads['assets/images/edibles/pineapple.png'],
			},
			{
				weight = 1,
				static = quads['assets/images/edibles/dragonfruit.png'],
			},
			--]]
		},
	},

	vine = {
		variants = {
			{
				static = quads['assets/images/edibles/vine.png'],
			}
		}
	},

	touch = {
		variants = {
			{
				static = quads['assets/images/ui/touch.png'],
			}
		}
	},

	flash = {
		variants = {
			{
				static = quads['assets/images/ui/flash.png'],
			}
		}
	},
}