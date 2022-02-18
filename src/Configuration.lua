return {	
	BUFFER_FOLDER_NAME = "BufferedItems";
-- 	- The name of the folder that will store items in the buffer.

	HIDE_UNPOPPED_ITEMS = true;
--	(Security setting)
--	- Hides unpopped items in buffers that aren't owned by the local player by storing the buffers in nil.
	
	BUFFER_DISABLE_CAN_TOUCH = true;
--	(Security setting)
-- 	- If true, items in the buffer will not fire touch events until popped.
	
	
	
-- 	[EXPERIMENTAL]
	
	ENABLE_LOCAL_COLLISIONS = false;
--	(Security setting)
-- 	- If true, any Parts in a buffer with the Attribute/CollectionService tag "LocalCollisions" will only be able to push around 
--	whatever the client has network ownership over.
-- 	- This has been marked as experimental as it can cause strange problems when
--	items interact with sleeping assemblies not owned by the client.
}