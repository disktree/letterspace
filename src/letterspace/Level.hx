package letterspace;

typedef Level = {
	var name : String;
	var width : Int;
	var height : Int;
	var theme : String;
	var letter : {
		var font : String;
		var scale : Float;
	};
	var letters : Array<Dynamic>;
}
