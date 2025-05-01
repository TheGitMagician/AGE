//txr_run(@'
//		dTestBranch1.start();
//		');

//show_message(json_stringify(cIndi.inventory_items,true));

//txr_run(@'
//	//save_game(0);
//	cIndi.say("My very long test sentence is spoken now.");
//	');

//txr_run(@'
//	cIndi.add_inventory(oHat);
//	');

//show_debug_message(walkarea_manager.point_get_walkarea_index(mouse_x,mouse_y));
walkarea_manager.update_walkarea_mask_original();
var time_start = current_time
//walkarea_manager.point_get_walkarea_index(mouse_x,mouse_y);// update_walkarea_mask();
var i=0;
while (i<100)
{
	walkarea_manager.update_mp_grid_original();
	i ++;
}
//walkarea_manager.find_nearest_point_on_walkarea(mouse_x,mouse_y);
show_debug_message(current_time-time_start);

//walkarea_manager.set_scaling(0,0.8,1.2);

//cIndi.add_inventory(iMap);

//loading_the_game_was_requested = 1;