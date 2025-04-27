//initialize the TXR component
txr_init();

//add demo functions to TXR parser
txr_function_add("abs", scr_txr_demo_abs, 1);
txr_function_add("lerp", scr_txr_demo_lerp, 3);
txr_function_add("draw_text", scr_txr_demo_draw_text, 3);
txr_function_add("trace", scr_txr_demo_trace, -1);
txr_function_add("wait", scr_txr_demo_wait, 1);
txr_function_add("dialog", scr_txr_demo_dlg, -1);
txr_function_add("call_label", scr_txr_demo_call_label, 1);
txr_function_add("get_dummy", scr_txr_demo_get_dummy, 0);
txr_function_add("array", scr_txr_demo_array, -1);
txr_function_add("assert", scr_txr_demo_assert, 2);

//add AGE constants to TXR parser
txr_constant_add("noone", noone);
txr_constant_add("_", undefined);
txr_constant_add("eDirRight", AGE_DIR_RIGHT);
txr_constant_add("eDirLeft", AGE_DIR_LEFT);
txr_constant_add("eDirUp", AGE_DIR_UP);
txr_constant_add("eDirDown", AGE_DIR_DOWN);
txr_constant_add("eForward", age.forward);
txr_constant_add("eBackward", age.backward);
txr_constant_add("eOnce", age.once);
txr_constant_add("eRepeat", age.loop);
txr_constant_add("eBlock", true);
txr_constant_add("eNoBlock", false);
txr_constant_add("eOptionOn", age.option_on);
txr_constant_add("eOptionOff", age.option_off);
txr_constant_add("eOptionOffForNow", age.option_off_for_now);
txr_constant_add("eOptionOffForever", age.option_off_forever);
txr_constant_add("eAnywhere", true);

//add AGE functions to TXR parser
txr_function_add("wait",txr_wait,1);

txr_function_add("set_timer",txr_set_timer,2);
txr_function_add("is_timer_expired",txr_is_timer_expired,1);
txr_function_add("stop_timer",txr_stop_timer,1);
txr_function_add("get_timer_pos",txr_get_timer_pos,1);

txr_function_add("claim_event",txr_claim_event,0);

txr_function_add("show_message", txr_demo_show_message,1);
txr_function_add("show_debug_message", txr_demo_show_debug_message,1);

txr_function_add("current_dialog_return", txr_dialog_return,0);
txr_function_add("current_dialog_goto_previous", txr_dialog_goto_previous,0);
txr_function_add("current_dialog_goto_dialog", txr_dialog_goto_dialog,1);
txr_function_add("current_dialog_stop", txr_dialog_stop,0);

txr_function_add("start_cutscene", txr_start_cutscene,0);
txr_function_add("end_cutscene", txr_end_cutscene,0);
txr_function_add("skip_cutscene", txr_skip_cutscene,0);

txr_function_add("save_game", txr_save_game,1);
txr_function_add("load_game", txr_load_game,1);


//provide the default function that is called when a function is unknown to TXR
txr_function_default = scr_txr_demo_default_func;

//@TODO: delete this part because the threads will manage their own destruction in teh future
/*
//create array that stores the running threads and monitors them for whether they have finished and can be destroyed
//not all threads will be stored in this array. Some threads (like repeatedly_execute) will be restarted every frame
//and thus will not be destroyed automatically once they have run once
threads = [];
*/

