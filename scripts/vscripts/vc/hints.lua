-- Hint reminders:
-- 1 = Explore
-- 2 = Cookies
-- 3 = Milk
-- 4 = Attic tree
-- 5 = Attic tree placement
-- 6 = Attic key
-- 7 = Santa crash
-- 8 = Gift placement
-- 9 = Downstairs bathroom
local HintReminders = {
	-- 'There are no hints for this area',
	'There are still places you haven\'t explored',
	'Santa needs cookies by the fireplace',
	'Santa needs milk to wash down the cookies',
	'There is one Christmas tree box left in the attic',
	'Put the Christmas tree box in the spot near the fireplace',
	'There is still a prize waiting in the basement',
	'Find out what that noise on the roof was',
	'Gifts should be put next to the Christmas tree',

	'There is something to do in the downstairs bathroom',
}

-- Hint areas:
-- 1 = Hint intro
-- 2 = Gift Vinny
-- 3 = Gift kitchen
-- 4 = Gift car
-- 5 = Gift Joel/Meat
-- 6 = Gift bunker
-- 7 = Toilet unclog
-- 8 = Pipe climbing
-- 9 = Tree outside
-- 10 = Basement door handle
-- 11 = Fridge key
-- 12 = Baking cookies
-- 13 = Pouring milk
-- 14 = Milk placement
-- 15 = Pachinko
-- 16 = Attic key
-- 17 = Meat somber
-- 18 = Attic maze
-- 19 = Saw main
-- 20 = Saw grenade puzzle
-- 21 = Credits
-- 22 = Basement trap door
-- 23 = Don't be pussy
-- 24 = Oven wait
-- 25 = Bunker
-- 26 = Christmas complete
-- 27 = Front door
-- 28 = Kitchen door
-- 29 = Feeding Meat
-- 30 = Higgs corridor
local HintAreas = {
	{
		'I give hints about the area when shook! Shake again!',
		'Each shake will give a more detailed hint.',
		'Put me in your wrist pocket\nI help make the game VineProof™'
	},

	{
		'There is a gift nearby...',
		'Check the closet',
		'Look at the top shelf of the bedroom closet'
	},
	{
		'There is a gift nearby...',
		'Check the cupboards',
		'Check the cupboard next to the cat clock'
	},
	{
		'There is a gift nearby...',
		'Vinny might have left one in the car while drunk'
	},
	{
		'There is a gift nearby...',
		'A horrid smell is rising into the air...',
		'Does Meat have a secret under his room?',
		'Move boxes and break the hidden boards'
	},
	{
		'There is a gift nearby...',
		'What\'s down that hole?',
		'Use the wheel to raise the bucket'
	},

	{
		'A useful tool could unclog the toilet',
		'Vinny keeps a plunger in one of the bathrooms',
		'It might take a few plunges'
	},

	{
		'How could you climb to the roof?',
		'The drain pipes seem sturdy',
		'There is a drain pipe near the front door',
		'Climb all the way to the top'
	},

	{
		'The tree needs an axe to be chopped down',
		'Where would Vinny keep an axe?',
		'Vinny keeps an axe in his shed',
		'Maybe someone buried the handle nearby',
		'A shovel could dig the dirt pit by the tree',
		'The handle from the pit might open the shed door',
		'The tree just needs to be hit in the right spots'
	},

	{
		'Meat will need to clean the door handle',
		'Meat should be brought down from his room',
		'Bring Meat back here after feeding him'
	},

	{
		'The fridge key is somewhere in the kitchen',
		'I can tell you all the places the key might be\nif you really don\'t want to look',
		'Under the sink',
		'Third drawer down next to the sink',
		'Third drawer down next to the fridge',
		'Bottom drawer of the big cupboard'
	},

	{
		'There are baking instructions near the oven',
		'3 ingredients are needed to bake cookies',
		'Find flour, sugar and butter',
		'They all need to be put in the oven',
		'The oven needs to be turned on'
	},

	{
		'Milk is typically found in a fridge',
		'Pour the milk into a glass',
		'Put glass of milk by the fireplace'
	},

	{
		'Don\'t make Santa drink out of the carton...'
	},

	{
		'Yes you do have to play Pachinko',
		'Pachinko is played by throwing balls over the top',
		'Pachinko isn\'t that hard',
		'Don\'t worry you\'ll get a free pass eventually'
	},

	{
		'The attic needs a key to open',
		'The attic key is probably somewhere deeper in the house',
	},

	{
		'Bringing a gherkin to meat\'s door might help',
		'Meat\'s gherkins are kept in the fridge'
	},

	{
		'One of these boxes up here has to be important right?',
		'Come on you love mazes!',
		'Just a bit of corner turning',
		'From ladder:\nR3,L2,R2,F,L2'
	},

	{
		'(つ◉益◉)つ Don\'t leave me here!',
		'(ง’̀-‘́)ง Put me back in your wrist pocket'
	},

	{
		'Grenades could be useful here',
		'Try throwing grenades in fence holes',
		'A switch needs to be blown into the air and caught',
		'A door needs to be blown open from behind',
		'The switch needs to be installed in the power mains'
	},

	{
		'Sorry you can\'t skip the credits :)',
		'You\'re a cool person for playing my game :)'
	},

	{
		'Something is holding these doors shut tight',
		'You\'ll need to examine it from the other side',
		'There might be a way through the kitchen'
	},

	{
		'Don\'t be a pussy'
	},

	{
		'If all the ingredients are in you just have to wait',
		'The cookies need time to bake'
	},

	{
		'It\'s so dark here, maybe there\'s a light you can use',
		'Looks like a way out next to the locker',
		'The barrels need to be pushed out of the way'
	},

	{
		'Everything is ready for Christmas tomorrow!',
		'Time to sit back and relax'
	},

	{
		'The code for the door must be kept somewhere in the house',
		'The door code has been put where no one will stick their hands',
		'Unclog the downstairs toilet to find the front door code'
	},

	{
		'The door appears to be blocked by barrels',
		'The door only opens outwards so the barrels need to be moved',
		'You will need to get to the other side to move the barrels'
	},

	{
		'Meat looks sad and hungry',
		'What does Meat like to eat?',
		'Feed Meat a gherkin from the fridge',
	},

	{
		'Return it',
		'He will return',
	}
}

return {
    reminders = HintReminders,
    areas = HintAreas
}