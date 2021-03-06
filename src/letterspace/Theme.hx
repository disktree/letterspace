package letterspace;

typedef Letter = {
	color : Int,
	outline : {
		color : Int,
		thick : Int
	},
	?shadow: {
		distance : Float,
		angle : Float,
		color : Int,
		alpha : Float,
		radius : Float,
		gain : Float
	}
}

typedef Background = {
	color : Int,
	gradient : {
		color : Int,
		//sx,sy
	},
	grid : {
		color : Int,
		size : Int,
		//thick : Int
   	}
}

class Theme {

	static var MAP : Map<String,Theme> = [
		"antireal" => new Theme(
			{
				color : 0xffA7AFB2,
				outline : {
					color : 0x00ff00,
					thick : 10
				},
				shadow : {
					distance : 3,
					angle : 0.785,
					color : 0x000000,
					alpha : 0.3,
					radius : 6.0,
					gain : 2.0
				}
			},
			{
				color : 0xff13181E,
				gradient : {
					color : 0x55000000
				},
				grid : {
					color : 0x99252126,
					size : 10,
				}
			}
		),
		"red" => new Theme(
			{
				color : 0xFFAE263E,
				outline : {
					color : 0xE3E3EE,
					thick : 1
				}
			},
			{
				color : 0xff1A1721,
				gradient : {
					color : 0x55000000
				},
				grid : {
					color : 0x55582232,
					size : 10
				}
			}
		),
	];

	public static inline function get( name : String ) : Theme {
		return MAP.get( name );
	}

	public final background : Background;
	public final letter : Letter;

	function new( letter : Letter, background : Background ) {
		this.background =  background;
		this.letter =  letter;
	}

}
