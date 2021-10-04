return {

	danger = {

		{
			asset = 'invisible',
			event = {
				collider = 'body',
				trigger = 'attack',
			},
			
			method = 'distribute',
			weight = 1,
			depth = 1,
			bottom = 80,
			buffer = 2,
			density = 0.95,
		},
	},

	start = {

		{
			asset = 'invisible',
			event = {
				collider = 'body',
				trigger = 'toggle',
			},
			
			method = 'absolute',
			weight = 1,
			depth = 1,
			bottom = 75,
			buffer = 32,
			position = 1,
			density = 1,
		},
	},




	-------

	grass = {
		{
			asset = 'grass',
			method = 'loop',
			weight = 1,
			depth = 0.6,
			bottom = -70,
			density = 0.3,
		},
	},

	grass_bunch = {
		{
			asset = 'grass_tuft',
			method = 'distribute',
			weight = 1,
			depth = 1.2,
			bottom = 110,
			buffer = 15,
			density = 0.75,
		},
	},

	hill_1 = {

		{
			asset = 'hill_1',
			method = 'loop',
			weight = 1,
			depth = 11,
			bottom = 200,
		},
	},

	hill_2 = {
		{
			asset = 'hill_2',
			method = 'loop',
			weight = 1,
			depth = 9,
			bottom = 130,
		},
	},

	hill_3 = {

		{
			asset = 'hill_3',
			method = 'loop',
			weight = 1,
			depth = 6,
			bottom = 145,
		},
	},

	hill_4 = {

		{
			asset = 'hill_4',
			method = 'loop',
			weight = 1,
			depth = 3,
			bottom = -35,
		},
	},

	hill_5 = {

		{
			asset = 'hill_5',
			method = 'loop',
			weight = 1,
			depth = 1.1,
			bottom = 10,
		},
	},

	hill_6 = {

		{
			asset = 'hill_6',
			method = 'loop',
			weight = 1,
			depth = 0.8,
			bottom = -90,
		},
	},

	clouds = {

		{
			asset = 'cloud',
			method = 'distribute',
			weight = 1,
			depth = 13,
			bottom = 300,
			buffer = 3,
			density = 0.9,
		},
	},

	mountain = {

		{
			asset = 'mountain',
			method = 'absolute',
			weight = 1,
			depth = 20,
			bottom = 260,
			buffer = 0.5,
			density = 1,
			position = 0.3,
			max = 1,
		},
	},

	trees_far = {

		{
			asset = 'trees_far',
			method = 'distribute',
			weight = 1,
			depth = 8,
			bottom = 230,
			buffer = 1,
			density = 0.3,
		}

	},

	trees_middle = {

		{
			asset = 'trees_middle',
			method = 'distribute',
			weight = 1,
			depth = 5,
			bottom = 140,
			buffer = 4,
			density = 0.85,
		}

	},

	trees_near = {

		{
			asset = 'trees_near',
			method = 'distribute',
			weight = 1,
			depth = 1.3,
			bottom = 100,
			buffer = 1.2,
			density = 1,
		}

	},

	boulders = {

		{
			asset = 'boulder',
			method = 'distribute',
			weight = 1,
			depth = 8.5,
			bottom = 190,
			buffer = 2,
			density = 0.9,
		}

	},

}