function cave_doorway_look_at()
{
	txr_run(@'
		//indi.face_direction(AGE_DIR_UP);
		//wait(30);
		//var number = hat.name;
		//hat.jump();
		//indi.jumping(20);
		//indi.say("Hello[World", "World", 1234);
		//indi.say("A large doorway");
		//indi.face_direction(AGE_DIR_DOWN);
		indi.say("My name is %.", indi.name);
		indi.walk(150,200,true);
		indi.name = "Hannes";
		indi.say("My name is now %.", indi.name);
		');
}

function cave_skeleton_look_at()
{
	txr_run(@'
		//indi.face_direction(AGE_DIR_RIGHT);
		//wait(30);
		//indi.say("These guys have seen better days.");
		//indi.face_direction(AGE_DIR_DOWN);
		//indi.change_room(rm_outside);
		//indi.animate("s_indi_animation",0.1,eOnce,eBlock);
		dTest.start();
		');
}