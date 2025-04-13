//unload repeatedly execute scripts for this room
if (thread_room_repeatedly_execute != undefined)
{
	txr_thread_destroy(thread_room_repeatedly_execute);
}

if (thread_room_repeatedly_execute_always != undefined)
{
	txr_thread_destroy(thread_room_repeatedly_execute_always);
}