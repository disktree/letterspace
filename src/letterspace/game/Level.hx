package letterspace.game;

import h2d.Tile;

class Level {

	public final width : Int;
	public final height : Int;
	public final background : Int;
	public final font : String;
	public final chars : Array<String>;

	public function new( width : Int, height : Int, background : Int, font : String, chars : String ) {
		this.width = width;
		this.height = height;
		this.background = background;
		this.font = font;
		this.chars = chars.split('');
	}
}
