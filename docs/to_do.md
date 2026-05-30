T
- Fix movement speed:
	increasing the steps taken (distance_moved += >1) makes it janky, as every 16 we're spending a frame checking
	Need to figure out a way to accelerate this without turning distance_moved into a float, as we
	rely on it to check if we arrived at our destination

- Door interaction:
	Being next to a door and moving towards it should make it enterable

- Room transition:
	once door interaction is in, we need to figure out how to visually transition to the next room.
	Also how neighbouring rooms work.
	Also, need to update active_room on the floor! 
