function txr_dialog_show_options() {
	o_age_main.dialog_manager.show_dialog_options = true;
}

function txr_dialog_goto_previous() {
	o_age_main.dialog_manager.goto_previous();
}

function txr_dialog_goto_dialog(_dialog) {
	o_age_main.dialog_manager.goto_dialog(_dialog);
}

function txr_dialog_stop() {
	o_age_main.dialog_manager.stop();
}