//exit if this is not an AGE room (all AGE rooms need to have the tag "AGE")
if (!asset_has_tags(room, "AGE", asset_room))
	exit

//unload repeatedly execute scripts for this room
unload_room_threads();