//exit if this is not an AGE room (all AGE rooms need to have the tag "AGE")
if (!asset_has_tags(room, "AGE", asset_room))
	exit

//hide Room Layer for walkareas
layer_set_visible("Walkareas",false);

//load walkarea mask for this room
walkarea_manager.room_start();

//load repeatedly execute scripts for this room
load_room_threads();

//check if we are in a cutscene which is skipped
if (continue_skipping_cutscene_after_room_change)
{
	continue_skipping_cutscene_after_room_change = false;
	skipping_cutscene = true;
	fast_forward();
}