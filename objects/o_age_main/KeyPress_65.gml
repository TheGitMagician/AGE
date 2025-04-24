//txr_run(@'
//		dTestBranch1.start();
//		');

//show_message(json_stringify(cIndi.inventory_items,true));

//walkarea_manager.update_walkarea_mask();

txr_run(@'
	player.change_room(rm_outside);
	');

//loading_the_game_was_requested = 1;