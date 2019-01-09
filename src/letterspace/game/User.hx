package letterspace.game;

class User {

	public final name : String;
	public final color : Int;

	public function new( name : String, color = 0xFFFFFF ) {
		this.name = name;
		this.color = color;
	}
}
