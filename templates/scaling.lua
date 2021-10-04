return {
	devices = {
		-- pixel density
		-- desktops, iPad 2, older phones.
		[1] = {
			defaults = {
				interface = 1,
				world = 1,
			},
			width = {
				-- non retina iphone and ipod
				[480] = {

				},
				[640] = {
					world = 0.9,
				},
				-- ipad 2
				[1024] = {
				},
				-- 11" - 13" laptops
				[1280] = {
					world = 0.95,	
				},
				[1366] = {
					world = 0.9,
				},
				-- macbook air
				[1440] = {
					
				},
				-- 13" - 15" laptops
				[1920] = {
				},
				-- 24" - 27" displays
				[2560] = {

				},
				-- 27" - 30" displays
				[3840] = {

				},
				-- 5K imac
				[5120] = {

				},

			},
		},
		[2] = {
			defaults = {
				interface = 2,
				world = 1,
			},
			width = {
				[960] = {
					interface = 0.5,
				},
				-- iphone 5, iphone 5s
				[1136] = {
					interface = 0.5,
				},
				-- nexus 4, moto x, moto g, numerous android (4.7" - 5")
				[1280] = {
					interface = 0.6,
				},
				-- iphone 6 (4.7")
				[1334] = {
					interface = 0.6,
				},
				-- iphone 6+, numerous android (5.5" - 7")
				[1920] = {
					height = {
						[1080] = {
							interface = 0.8,
							world = 0.925,
						},

						-- nexus 7
						[1200] = {
							interface = 0.8,
							world = 0.925,
						},
					},

				},
				-- ipad, nexus 9 (9" - 10")
				[2048] = {
					[1536] = {

					},
				},
				-- nexus 6 (5.9")
				-- nexus 6 could also be in 3x?
				[2560] = {
					interface = 0.9,
				},
				-- doesn't yet exist
				[3840] = {
					
				},
			}
		},
		[3] = {
			defaults = {
				interface = 2,
				world = 1,
			},
			width = {
				-- iphone 6+, numerous android
				[1920] = {

				},
			}
		},
	}
}