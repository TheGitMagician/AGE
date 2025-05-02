//show_debug_message(walkarea_manager.is_point_on_walkarea(mouse_x,mouse_y));

//walkarea_manager.calculate_path_to_point(cIndi.x,cIndi.y,mouse_x,mouse_y);

//txr_run(@'
//	load_game(0);
//	');

txr_run(@'
	skip_cutscene();
	');

//txr_run(@'
//	if (cIndi.direction == eDirRight) cIndi.face_direction(eDirUp);
//	else if (cIndi.direction == eDirUp) cIndi.face_direction(eDirLeft);
//	else if (cIndi.direction == eDirLeft) cIndi.face_direction(eDirDown);
//	else if (cIndi.direction == eDirDown) cIndi.face_direction(eDirRight);
//	');

//txr_run(@'
//	show_message(get_timer_pos(0));
//	');
//	show_message(global_manager.get_timer_pos(0));
//cIndi.x = irandom_range(-100,room_width+100);
//cIndi.y = irandom_range(-100,room_height+100);

//show_debug_message(walkarea_manager.get_scaling_at_walkarea_y(0,mouse_y));

//txr_run(@'
//	if (cSophia.current_room == rm_cave) cSophia.change_room(rm_outside);
//	else cSophia.change_room(rm_cave);
//	');


//txr_run(@'
//	if (cSophia.current_room == rm_cave)
//	{	
//		cSophia.change_room("rm_outside", 180, 110, eDirUp);
//	}
//	else
//	{
//		cSophia.change_room("rm_cave", 150, 90, eDirDown);
//	}
//	');