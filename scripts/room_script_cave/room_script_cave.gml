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
		//cIndi.lose_inventory(iMap);
		//cIndi.active_inventory_item = iKey;
		//show_message(cIndi.active_inventory_itemss);
		
		start_cutscene();
		cIndi.say("Does this still work?");
		wait(10);
		cSophia.say("Where are you going now?!");
		wait(10);
		cIndi.say("I will explore the outside of the cave.");
		wait(10);
		cIndi.walk(20,150,eBlock);	
		cIndi.say("See you!");
		cIndi.change_room(rm_outside,190,110,eDirRight);
		wait(20);
		cIndi.say("Looks nicer than I thought.");
		////cSophia.say("Just great...");
		////cSophia.walk(170,100,eNoBlock);
		end_cutscene();
		
		//cSophia.animate(s_indi_animation,0.2,eOnce,eBlock);
		
		//cIndi.change_room(rm_outside);
		
		');
}

function cave_skeleton_look_at()
{
	txr_run(@'
		//cIndi.walk(150,150,eBlock);
		
		//cIndi.face_direction(AGE_DIR_DOWN);
		//cIndi.animate("s_indi_animation",0.1,eOnce,eBlock);
		//dTest.start();
		//cIndi.set_inventory_quantity(iKey,0);
		//iKey.script_name = "Hello";
		//cIndi.testing = "Hallo";
		
		dTest.start();
		//wait(40);
		
		
		//cIndi.face_location(190,115);
		//wait(10);
		//cIndi.say("These guys have seen better days.");
		');
}