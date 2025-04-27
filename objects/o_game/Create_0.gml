// ------- Characters -------
o_age_main.character.create("cIndi", {
	starting_room: rm_cave,
	x: 150,
	y: 120,
	name: "Indi",
	walking_costume: "s_indi_standard",
	is_player_character: true
});

o_age_main.character.create("cSophia", {
	starting_room: rm_cave,
	x: 115,
	y: 130,
	name: "Sophia",
	walking_costume: "s_sophia_standard",
	speech_color: c_fuchsia
});


// ------- Objects -------
o_age_main.object.create("oHat", {
	in_room: rm_cave,
	x: 192,
	y: 64,
	name: "Hat",
	sprite: s_hat
});

o_age_main.object.create("oHatMoveAlways", {
	in_room: rm_cave,
	x: 224,
	y: 64,
	name: "Evermoving Hat",
	sprite: s_hat
});


// ------- Inventory Items -------
o_age_main.inventory.create("iKey", {
	name: "Key",
	sprite: noone
});

o_age_main.inventory.create("iCoin", {
	name: "Coin",
	sprite: noone
});

o_age_main.inventory.create("iMap", {
	name: "Map",
	sprite: noone
});


// ------- Dialogs -------
o_age_main.dialog.load_file("dialogs.txt");