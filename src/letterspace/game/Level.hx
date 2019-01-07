package letterspace.game;

typedef BackgroundTheme = {
	color : Int,
	grid : {
	   color : Int,
	   size : Int
   }
}

typedef Theme = {
	letter : {
		//scale : Float
		color : Int
	},
	background : BackgroundTheme
}

class Level {

	public static var THEME(default,null) : Map<String,Theme> = [
		"apollo" => {
			letter : { color: 0xffe47464 },
			background: { color : 0xff47424a, grid : { color : 0xff5f5353, size : 20 } }
		},
		"battlestation" => {
			letter : { color: 0xffaffec7 },
			background: { color : 0xff333333, grid : { color : 0xff555555, size : 20 } }
		},
		"noir" => {
			letter : { color: 0xffcccccc },
			background: { color : 0xff222222, grid : { color : 0xff444444, size : 20 } }
		},
		"soyuz" => {
			letter : { color: 0xff999999 },
			background: { color : 0xff222222, grid : { color : 0xff333333, size : 20 } }
		}
	];

	public final width : Int;
	public final height : Int;
	public final font : String;
	public final chars : Array<String>;
	public final theme : Theme;

	public function new( width : Int, height : Int, font : String, chars : Array<String>, theme : Theme ) {
		this.width = width;
		this.height = height;
		this.font = font;
		this.chars = chars;
		this.theme = (theme != null) ? theme : {
			letter : { color: 0xffa0a0a0 },
			background: { color : 0xff000000, grid : { color : 0xff111111, size : 20 } }
		};
	}
}
