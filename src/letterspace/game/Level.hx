package letterspace.game;

typedef LetterTheme = {
	scale : Float,
	color : Int,
	?shadow: {
		distance : Float,
		angle : Float,
		color : Int,
		alpha : Float,
		radius : Float,
		gain : Float,
	}
}

typedef BackgroundTheme = {
	color : Int,
	gradient : {
		color : Int,
		//sx,sy
	},
	grid : {
		size : Int,
		color : Int,
   	}
}

typedef Theme = {
	letter : LetterTheme,
	background : BackgroundTheme
}

class Level {

	public static var THEME(default,null) : Map<String,Theme> = [
		"apollo" => {
			letter : {
				scale : 1,
				color: 0xffe47464,
				shadow : {
					distance : 2,
					angle : 0.785,
					color : 0x000000,
					alpha : 0.3,
					radius : 6.0,
					gain : 2.0
				}
			},
			background: {
				color : 0xff47424a,
				gradient : {
					color : 0x77000000
				},
				grid : {
					color : 0x555f5353,
					size : 10
				}
			}
		},
		/*
		"battlestation" => {
			letter : { color: 0xffaffec7 },
			background: { color : 0xff333333, grid : { color : 0xff555555, size : 20 } }
		},
		"noir" => {
			letter : { color: 0xffcccccc },
			background: { color : 0xff222222, grid : { color : 0xff444444, size : 10 } }
		},
		"soyuz" => {
			letter : { color: 0xff999999 },
			background: { color : 0xff222222, grid : { color : 0xff333333, size : 10 } }
		}
		*/
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
		this.theme = (theme != null) ? theme : THEME.get('apollo');
		/*
		this.theme = (theme != null) ? theme : {
			letter : { scale : 1, color: 0xffa0a0a0 },
			background: { color : 0xff000000, grid : { color : 0xff101010, size : 10 } }
		};
		*/
	}
}
