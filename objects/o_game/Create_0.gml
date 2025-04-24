// ------- Characters -------
o_age_main.create_character("cIndi", {
	starting_room: rm_cave,
	x: 150,
	y: 120,
	name: "Indi",
	walking_costume: "s_indi_standard",
	is_player_character: true
});

o_age_main.create_character("cSophia", {
	starting_room: rm_cave,
	x: 115,
	y: 130,
	name: "Sophia",
	walking_costume: "s_sophia_standard",
	speech_color: c_fuchsia
});


// ------- Objects -------
o_age_main.create_object("oHat", {
	in_room: rm_cave,
	x: 192,
	y: 64,
	name: "Hat",
	sprite: s_hat
});

o_age_main.create_object("oHatMoveAlways", {
	in_room: rm_cave,
	x: 224,
	y: 64,
	name: "Evermoving Hat",
	sprite: s_hat
});


// ------- Inventory Items -------
o_age_main.create_inventory_item("iKey", {
	name: "Key",
	sprite: noone
});

o_age_main.create_inventory_item("iCoin", {
	name: "Coin",
	sprite: noone
});

o_age_main.create_inventory_item("iMap", {
	name: "Map",
	sprite: noone
});