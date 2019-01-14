package letterspace;

typedef Level = {
	name : String,
	width : Int,
	height : Int,
	theme : String,
	letter : {
		font : String,
		?scale : Float,
		?num : Int,
	},
	letters : Array<{
		char : String,
		?font : String,
		?scale : Float,
		?num : Int,
		?pos : Array<Int>
	}>,
	//?status : Dynamic
}
