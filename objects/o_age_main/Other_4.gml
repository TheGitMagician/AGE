//exit if this is not an AGE room (all AGE rooms need to have the tag "AGE")
if (!asset_has_tags(room, "AGE", asset_room))
	exit

//hide walkareas
layer_set_visible("Walkareas",false);

//load walkarea mask for this room
//the order is important - first create the walkareas then let the pathfinder create its mp_grid

walkarea_manager.room_start();
pathfinder.room_start(walkarea_manager);

//load repeatedly execute scripts for this room
load_room_threads();