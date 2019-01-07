package letterspace.game;

class User {

	public static final COLORS = [
		0xFF6F00,
		0x0D47A1,
		0x006064,
		0xBF360C,
		0x311B92,
		0x1B5E20,
		0x1A237E,
		0x01579B,
	];

	public final name : String;
	public final color : Int;

	public function new( name : String, color = 0x000000 ) {
		this.name = name;
		this.color = color;
	}

}
