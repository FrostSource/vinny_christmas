# Vinny Almost Misses Christmas
Source project for the Half-Life: Alyx map "Vinny Almost Misses Christmas".

Being my first map there is bound to be a bunch of inefficient mapping methods so feel free to give feedback on things being done incorrectly or if you know of any fixes for the issues noted in the map.

If you want to compile and run this map for yourself there are two things you need to do first:

1. Two folders are in the **content** folder for convenience sake during development but must be in the **game** folder when the game runs:
	* scripts/
	* panorama/videos/

2. Two models along with their textures are excluded due to their strict licenses. They will show up as giant errors in the map and will need to be replaced with any generic models that can fit in their place.

## Things I could not fix

If you know of any way to solve these issues I would LOVE to know how.

* Objectives notes become blurry/low quality when away from them and won't pop back in until the player shoves their face into them.
* Some areas have noticeable hitches when moving close such as: Jerma's bedroom doorway, Saw freezer by the button, objectives notice board.
* Bunker room with hole has black props sometimes.
* Initial light when player gets captured has buggy fog. Maybe narrowed it down to player being teleported instead of moving over time.
