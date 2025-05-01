//exit if this is not an AGE room (all AGE rooms need to have the tag "AGE")
if (!asset_has_tags(room, "AGE", asset_room))
	exit

//unload walkarea mask for this room
walkarea_manager.__room_end(); //@TODO check if this call is still necessary after bug #10520 has been resolved

//unload repeatedly execute scripts for this room
unload_room_threads();