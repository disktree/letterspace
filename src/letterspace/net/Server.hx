package letterspace.net;

class Server extends owl.Server {

	override function createMesh( id : String ) : Mesh {
		//trace("createMesh");
		return new Mesh( this, id );
	}
}
