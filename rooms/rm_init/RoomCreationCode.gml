instance_create_layer(0,0,"Instances",o_txr);

instance_create_layer(0,0,"Instances",o_age_main);

instance_create_layer(0,0,"Instances",o_game);

instance_create_layer(0,0,"Instances",o_gui);


o_age_main.start_game();
o_age_main.load_global_threads();

room_goto(rm_cave);