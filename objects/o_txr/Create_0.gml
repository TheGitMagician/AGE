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
txr_constant_add("eBlock", age.block);
txr_constant_add("eNoBlock", age.no_block);
txr_constant_add("eOptionOn", age.option_on);
txr_constant_add("eOptionOff", age.option_off);
txr_constant_add("eOptionOffForNow", age.option_off_for_now);
txr_constant_add("eOptionOffForever", age.option_off_forever);

//add AGE functions to TXR parser
txr_function_add("wait",txr_wait,1);

txr_function_add("show_message", scr_txr_demo_show_message,1);

txr_function_add("current_dialog_return", txr_dialog_return,0);
txr_function_add("current_dialog_goto_previous", txr_dialog_goto_previous,0);
txr_function_add("current_dialog_goto_dialog", txr_dialog_goto_dialog,1);
txr_function_add("current_dialog_stop", txr_dialog_stop,0);

//provide the default function that is called when a function is unknown to TXR
txr_function_default = scr_txr_demo_default_func;

//create the dummy instance (e.g. used for running the timers while waiting until resuming a thread)
dummy = instance_create_depth(0, 0, 0, o_txr_dummy);

//@TODO: delete this part because the threads will manage their own destruction in teh future
/*
//create array that stores the running threads and monitors them for whether they have finished and can be destroyed
//not all threads will be stored in this array. Some threads (like repeatedly_execute) will be restarted every frame
//and thus will not be destroyed automatically once they have run once
threads = [];
*/

//@DEBUG
o_age_main.threads = 0;
