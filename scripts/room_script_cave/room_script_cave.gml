function cave_doorway_look_at()
{
	txr_run(@'
		//cIndi.face_direction(AGE_DIR_UP);
		//wait(30);
		//var number = hat.name;
		//hat.jump();
		//cIndi.jumping(20);
		//cIndi.say("Hello[World", "World", 1234);
		//cIndi.say("A large doorway");
		//cIndi.face_direction(AGE_DIR_DOWN);
		//cIndi.say("My name is %.", cIndi.name);
		//cIndi.walk(150,200,true);
		//cIndi.name = "Hannes";
		//cIndi.say("My name is now %.", cIndi.name);
		cIndi.lose_inventory(iMap);
		');
}

function cave_skeleton_look_at()
{
	txr_run(@'
		//cIndi.face_direction(AGE_DIR_RIGHT);
		//wait(30);
		//cIndi.say("These guys have seen better days.");
		//cIndi.face_direction(AGE_DIR_DOWN);
		//cIndi.change_room(rm_outside);
		//cIndi.animate("s_indi_animation",0.1,eOnce,eBlock);
		//dTest.start();
		//cIndi.add_inventory(iKey);
		cIndi.testerei = 243;
		');
}