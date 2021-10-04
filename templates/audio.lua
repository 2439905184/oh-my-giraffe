return {
	hiscore = {
		variants = {
			{
				source = la.newSource('assets/audio/environmental/sfx_end_run.mp3', 'static'),
			},
		},
	},
	powerup = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/powerup.mp3', 'static'),
			},
		},
	},
	drum = {
		variants = {
			{
				source = la.newSource('assets/audio/environmental/roll.mp3', 'static'),
			},
		},
	},
	pop = {
		variants = {
			{
				source = la.newSource('assets/audio/edibles/pop.mp3', 'static'),
				pitch = {0.5, 1.5},
			},
		},
	},
	squash = {
		tags = {'bendable'},
		variants = {
			{
				source = la.newSource('assets/audio/edibles/sfx_squash1.mp3', 'static'),
				pitch = {0.7, 1},
				volume = {0.15, 0.2},
			},
			{
				source = la.newSource('assets/audio/edibles/sfx_squash2.mp3', 'static'),
				pitch = {0.7, 1},
				volume = {0.15, 0.2},
			},
			{
				source = la.newSource('assets/audio/edibles/sfx_squash3.mp3', 'static'),
				pitch = {0.7, 1},
				volume = {0.15, 0.2},
			},
			{
				source = la.newSource('assets/audio/edibles/sfx_squash4.mp3', 'static'),
				pitch = {0.7, 1},
				volume = {0.15, 0.2},
			},
			{
				source = la.newSource('assets/audio/edibles/sfx_squash5.mp3', 'static'),
				pitch = {0.7, 1},
				volume = {0.15, 0.2},
			},
			{
				source = la.newSource('assets/audio/edibles/sfx_squash6.mp3', 'static'),
				pitch = {0.7, 1},
				volume = {0.15, 0.2},
			},
		},
	},
	bounce = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/bwoop.mp3', 'static'),
				volume = {9.4, 9.5},
				pitch = {0.7, 1.2},
			},
		},
	},
	chew = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/chew1.mp3', 'static'),
				pitch = {0.75, 0.85},
				volume = {0.5, 0.55},
			},
			{
				source = la.newSource('assets/audio/giraffe/chew2.mp3', 'static'),
				pitch = {0.75, 0.85},
				volume = {0.5, 0.55},
			},
			{
				source = la.newSource('assets/audio/giraffe/chew3.mp3', 'static'),
				pitch = {0.75, 0.85},
				volume = {0.5, 0.55},
			},
		},
	},

	nibble = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/nibble1.mp3', 'static'),
				pitch = {0.8, 1.1},
				volume = {0.3, 0.4},
			},
			{
				source = la.newSource('assets/audio/giraffe/nibble2.mp3', 'static'),
				pitch = {0.8, 1.1},
				volume = {0.3, 0.4},
			},
			{
				source = la.newSource('assets/audio/giraffe/nibble3.mp3', 'static'),
				pitch = {0.8, 1.1},
				volume = {0.3, 0.4},
			},
			{
				source = la.newSource('assets/audio/giraffe/nibble4.mp3', 'static'),
				pitch = {0.8, 1.1},
				volume = {0.3, 0.4},
			},
		},
	},
	roar = {
		tags = {'bendable'},
		variants = {
			{
				source = la.newSource('assets/audio/lion/sfx_lion_entrance1.mp3', 'static'),
				pitch = {0.8, 1.2},
				volume = {0.3, 0.4},
			},
			{
				source = la.newSource('assets/audio/lion/sfx_lion_entrance2.mp3', 'static'),
				pitch = {0.8, 1.2},
				volume = {0.3, 0.4},
			},
			{
				source = la.newSource('assets/audio/lion/sfx_lion_entrance3.mp3', 'static'),
				pitch = {0.8, 1.2},
				volume = {0.3, 0.4},
			},
			{
				source = la.newSource('assets/audio/lion/sfx_lion_entrance4.mp3', 'static'),
				pitch = {0.8, 1.2},
				volume = {0.3, 0.4},
			},
		},
	},
	step_left = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/step_l.mp3', 'static'),
				pitch = {0.9, 1.1},
				volume = {0.4, 0.4}
			},
		},
	},
	step_right = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/step_r.mp3', 'static'),
				pitch = {0.9, 1.1},
				volume = {0.4, 0.4}
			},
		},
	},
	skid = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/skid.mp3', 'static'),
				pitch = {0.7, 1.4},
				volume = {0.04, 0.04}
			},
		},
	},
	whimper = {
		variants = {
			{
				source = la.newSource('assets/audio/lion/sfx_lion_damage2.mp3', 'static'),
				volume = {0.6, 0.7}
			},
			{
				source = la.newSource('assets/audio/lion/sfx_lion_damage3.mp3', 'static'),
				volume = {0.6, 0.7}
			},
			{
				source = la.newSource('assets/audio/lion/sfx_lion_damage4.mp3', 'static'),
				volume = {0.6, 0.7}
			},
			{
				source = la.newSource('assets/audio/lion/sfx_lion_damage5.mp3', 'static'),
				volume = {0.6, 0.7}
			},
			{
				source = la.newSource('assets/audio/lion/death3.mp3', 'static'),
				pitch = {0.95, 1.1},
				volume = {0.6, 0.65},
			},
			{
				source = la.newSource('assets/audio/lion/death4.mp3', 'static'),
				pitch = {0.95, 1.1},
				volume = {0.6, 0.65},
			},
			{
				source = la.newSource('assets/audio/lion/death5.mp3', 'static'),
				pitch = {0.95, 1.1},
				volume = {0.6, 0.65},
			},
		},
	},
	thump = {
		variants = {
			{
				source = la.newSource('assets/audio/lion/thump.mp3', 'static'),
				volume = {20, 20},
				pitch = {1.6, 1.7}
			},
		}
	},

	click = {
		variants = {
			{
				source = la.newSource('assets/audio/ui/click.mp3', 'static'),
				volume = {1, 1},
				pitch = {0.5, 0.9}
			},
		}
	},

	boo = {
		variants = {
			{
				source = la.newSource('assets/audio/ui/boo.mp3', 'static'),
				volume = {0.6, 0.7},
				pitch = {0.9, 1.1}
			},
		}
	},

	roll = {
		variants = {
			{
				source = la.newSource('assets/audio/environmental/sfx_lion_danger.mp3', 'static'),
				volume = {0.6, 0.7},
				pitch = {0.9, 1.1}
			},
		}
	},

	honk = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/hoot.mp3', 'static'),
				volume = {1, 1},
				pitch = {0.8, 0.9}
			},
		}
	},

	thud2 = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/thud.mp3', 'static'),
				volume = {1, 1},
				pitch = {1, 1.1}
			},
		}
	},

	thud = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/thump.mp3', 'static'),
				volume = {1, 1},
				pitch = {1.5, 1.6}
			},
		}
	},

	howl = {
		variants = {
			{
				source = la.newSource('assets/audio/giraffe/howl1.mp3', 'static'),
				volume = {1, 1},
				pitch = {0.65, 0.65}
			},
			{
				source = la.newSource('assets/audio/giraffe/howl2.mp3', 'static'),
				volume = {1, 1},
				pitch = {0.65, 0.65}
			},
			{
				source = la.newSource('assets/audio/giraffe/howl3.mp3', 'static'),
				volume = {1, 1},
				pitch = {0.65, 0.65}
			},
		}
	},

	wind = {
		variants = {
			{
				source = la.newSource('assets/audio/environmental/wind.mp3', 'static')
			},
		},
	},

	birds = {
		tags = {'ambient'},
		variants = {
			{
				source = la.newSource('assets/audio/environmental/sfx_ambience_day.mp3', 'stream'),
				volume = {0.5, 0.5},
			},
		},
	},

	chirp = {
		tags = {'ambient'},
		variants = {
			{
				source = la.newSource('assets/audio/environmental/bird.mp3', 'static'),
				volume = {0.3, 0.3},
			},
		},
	},
	wolf = {
		variants = {
			{
				source = la.newSource('assets/audio/environmental/howl.mp3', 'static'),
				volume = {0.6, 0.7},
				pitch = {0.9, 1.1}
			},
		}
	},
	crickets = {
		tags = {'ambient'},
		variants = {
			{
				source = la.newSource('assets/audio/environmental/sfx_ambience_night.mp3', 'stream'),
				volume = {1, 1},
				pitch = {1, 1}
			},
		}
	}
}