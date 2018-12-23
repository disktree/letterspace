package letterspace.net;

class Mesh extends owl.Mesh {
	
	override function createNode( id : String, ?info : Dynamic ) : Node {
		//trace("createNode "+info);
		return new Node( id, info.user );
	}
}
