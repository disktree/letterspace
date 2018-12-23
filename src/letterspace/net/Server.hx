package letterspace.net;

class Server extends owl.Server {
	/*
	public override function join( id : String, ?info : Dynamic ) : Promise<Mesh> {
		return super.join( id, info );
	}
	*/
	override function createMesh( id : String ) : Mesh {
		//trace("createMesh");
		return new Mesh( this, id );
	}
}
