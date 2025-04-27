//show_debug_message(walkarea_manager.is_point_on_walkarea(mouse_x,mouse_y));
//show_walkareas = !show_walkareas;

//walkarea_manager.calculate_path_to_point(cIndi.x,cIndi.y,mouse_x,mouse_y);

//txr_run(@'
//	load_game(0);
//	');

cIndi.x = irandom_range(-100,room_width+100);
cIndi.y = irandom_range(-100,room_height+100);

//txr_run(@'
//	if (cSophia.current_room == rm_cave)
//	{	
//		cSophia.change_room(rm_outside, 180, 110, eDirUp);
//	}
//	else
//	{
//		cSophia.change_room(rm_cave, 150, 90, eDirDown);
//	}
//	');