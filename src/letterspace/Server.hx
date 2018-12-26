package letterspace;

#if owl_client

class Mesh extends owl.Mesh {
	override function createNode( id : String, ?info : Dynamic ) : Node {
		//trace("createNode "+info);
		return new Node( id, info.user );
	}
}

class Node extends owl.Node {
	public var user(default,null) : String;
	public function new( id : String, user : String ) {
		super( id );
		this.user = user;
	}
}

class Server extends owl.Server {
	override function createMesh( id : String ) : Mesh {
		//trace("createMesh");
		return new Mesh( this, id );
	}
}

#elseif owl_server

class Mesh extends owl.Mesh {}
class Node extends owl.Node {}

class Server extends owl.Server {

	//static inline var HOST = '195.201.41.121';
	static inline var HOST = '192.168.0.10';
	static inline var PORT = 1377;

	override function createMesh( id : String ) : Mesh {
		return new letterspace.Mesh( id );
	}

	static function main() {
		var server = new letterspace.Server( HOST, PORT );
		server.start().then( function(_) {
			trace('SERVER READY');
			server.addMesh( new owl.Mesh('letterspace') );
        });
	}
}

#end
