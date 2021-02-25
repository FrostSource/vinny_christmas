# Vinny Almost Misses Christmas
Source project for the Half-Life: Alyx map "Vinny Almost Misses Christmas".

Being my first map there is bound to be a bunch of inefficient mapping methods so feel free to give feedback on things being done incorrectly or if you know of any fixes for the issues noted in the map.

If you want to compile and run this map for yourself there are two things you need to do first:

1. Two folders are in the **content** folder for convenience sake during development but must be in the **game** folder when the game runs:
	* scripts/
	* panorama/videos/

2. A few models along with their textures are excluded due to their strict licenses. They will show up as giant errors or red meshes in the map and will need to be replaced with any generic models that can fit in their place.

## Using the Meat prefab in your own map

The prefab is made using many custom files, all of which need to be copied over to your own content/game folder:
* animgraphs/vinemeat.vanmgrph
* maps/prefabs/meat.vmap
* materials/meat
* models/meat/
* particles/munch.vpcf
* scripts/vscripts/meat.lua *(this file needs to be in your game folder, not content)*
* soundevents/meat_soundevents.vsndevts
* sounds/meat/

You should also add the sound event file to your resource manifest file so it looks similar to this:
```
{
	resourceManifest = 
	[
		[ 
			...
			"soundevents/meat_soundevents.vsndevts",
		],
	]
}
```

The files should compile automatically but if you find that's not the case you can open your Asset Browser, locate the `meat` files and `Right click > Full Recompile`.
The prefab has many input/output set up with descriptions. If you have any trouble installing or using Meat feel free to contact me anywhere you can find me on Discord/Steam etc..

## Things I could not fix

If you know of any way to solve these issues I would LOVE to know how.

* ~Objectives notes become blurry/low quality when away from them and won't pop back in until the player shoves their face into them.~ **Fixed by tagging the materials with no LOD**
* Some areas have noticeable hitches when moving close such as: Jerma's bedroom doorway, Saw freezer by the button, objectives notice board.
* Bunker room with hole has black props sometimes. ~~**Moving the lights a bit fixed this for some reason**~~ Randomly black again?
* ~~Initial light when player gets captured has buggy fog. Maybe narrowed it down to player being teleported instead of moving over time.~~ **Fixed by teleporting player twice**
* ~~Firework rocket makes player drop everything. Is there a way to target a specific entity?~~ **Fixed by applying 0 damage with a bullet type**
* ~~Dust(?) particles floating around without precipitation volume or any known particles that could cause it.~~ **Went away? Perhaps a rogue local particle**
* ~~Snark does not explode when shot unless model is recompiled before build.~~ **Fixed with model break changes and prefab logic**
