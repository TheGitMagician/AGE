//unload any remaining room threads
unload_room_threads();

//cleanup all game managers
global_manager.__cleanup();
character.__cleanup();
object.__cleanup();
inventory.__cleanup();
dialog.__cleanup();

walkarea_manager.__cleanup();