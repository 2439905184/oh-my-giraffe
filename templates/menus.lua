return {
	loader = {
		title = 'loader',
		position = 0.5,
		{
			label = 'loading',
			type = Loader,
		},
	},
	hint = {
		title = 'hint',
		position = 0.5,
		{
			label = '',
			type = Overlay,
		},
		{
			label = 'hint: chew the vines',
			type = MenuSubtitle,
		},
		{
			label = '',
			type = Hint,
		},

		{
			label = '',
			symbol = {default = ''},
			switch = 'close',
			action = 'retry',
			width = 0.7,
			height = 1,
		},
	},
	promo = {
		title = 'root',
		position = 0.5,
		oy = -0.2,
		{
			label = 'oh my giraffe',
			type = MenuHeader,
		},
		{
			label = 'a delightful game of survival',
			type = MenuSubtitle,
		},
	},
	leaderboard = {
		title = 'root',
		position = 0.5,
		{
			label = '',
			type = Overlay,
		},
		{
			label = 'high scores',
			type = MenuHeader,
			size = 50,
		},
		{
			label = '',
			type = LeaderboardView,
		},
		{
			label = '',
			symbol = {default = ''},
			switch = 'close',
			action = 'retry',
			width = 0.7,
			height = 1,
		},
	},
	root = {
		title = 'root',
		position = 0.5,
		oy = -0.2,
		{
			label = 'oh my giraffe',
			type = MenuHeader,
		},
		{
			label = 'eat a fruit ( * ) to begin!',
			type = MenuSubtitle,
		},
	},
	pause = {
		title = 'paused',
		position = 0.5,
		{
			label = '',
			type = Overlay,
		},
		{
			label = '',
			symbol = {default = ''},
			action = 'resume',
			width = 0.7,
			height = 1,
			color = {220, 255, 200},
		},
		{
			label = '',
			symbol = {default = ''},
			switch = 'close',
			action = 'restart',
			width = 0.7,
			height = 1,
		},
	},
	options = {
		title = 'options',
		position = 0.5,
		{
			label = 'growth',
			toggle = options.player_growth,
			symbol = {default = '', active = ''},
			height = 0.8,
		},
		{
			label = 'headbutt',
			toggle = options.headbutt,
			symbol = {default = '', active = ''},
			height = 0.8,
		},
		{
			label = 'save',
			switch = 'debug',
			color = {210, 255, 170},
		},
	},
	gameover = {
		title = 'game over',
		position = 0.5,
		oy = -0.125,
		{
			label = '',
			type = ScoreBreakdown,
		},
		{
			label = '',
			type = MenuPill,
			multiple = {
				{
					label = '',
					symbol = {default = ''},
					switch = 'leaderboard',
					width = 0.7,
					height = 1,
				},
				{
					label = '',
					symbol = {default = ''},
					switch = 'close',
					action = 'retry',
					width = 0.7,
					height = 1,
				},
			}
		},
	},
	learning = {
		title = 'game over',
		position = 0.5,
		oy = -0.1,
		{
			label = '',
			type = ScoreBreakdown,
		},

		{
			label = '',
			type = MenuPill,
			multiple = {
				{
					label = '',
					symbol = {default = ''},
					switch = 'leaderboard',
					width = 0.7,
					height = 1,
				},
				{
					label = '',
					symbol = {default = ''},
					switch = 'hint',
					width = 0.7,
					height = 1,
				},
			}
		},
	},
}