local defaults = {
	'grass',
	'grass_bunch',
	'trees_near',
	'trees_middle',
	'trees_far',
	'boulders',
	'hill_1',
	'hill_2',
	'hill_3',
	'hill_4',
	'hill_5',
	'mountain',
	'clouds',
}

return {

	--[[

	chunks templates contain the instances of groups it should contain
	as well as their vertical offset and depth level

	the group templates implicitely contain the spawning tactic of the assets, and the
	chunk will be passed a region to cover

	]]--


	start = {
		{
			weight = 1,
			length = 1,
			groups = defaults,
		},
	},

	eat = {
		{
			weight = 1,
			length = 1,
			groups = defaults,
		},
	},

}