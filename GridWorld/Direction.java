public enum Direction { 
  
	NORTH(0),
  NORTHEAST(1),
  NORTHWEST(2),
  
  SOUTH(3),
  SOUTHEAST(4),
  SOUTHWEST(5),
  
  EAST(6),
  WEST(7);

	private final int index;

	Direction(int val) {
		this.index = val;
	}

	int val() {
		return index;
	}
}