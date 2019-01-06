package letterspace;

#if owl_client

/*
class Mesh extends owl.Mesh {
	override function createNode( id : String, ?configuration : js.html.rtc.Configuration, ?info : Dynamic ) : Node {
		trace("createNode "+info);
		return new Node( id, configuration, info.user );
	}
}

class Node extends owl.Node {

	public var user(default,null) : String;

	public function new( id : String, ?configuration : js.html.rtc.Configuration, user : String ) {
		super( id, configuration );
		this.user = user;
	}
}
*/

class Server extends owl.Server {

	/*TODO load json
	public static var HOSTS(default,null) = [
		{ host:'' }
	];
	*/

	/*
	override function createMesh( id : String ) : Mesh {
		trace("createMesh");
		return new letterspace.Mesh( this, id );
	}
	*/
}

#elseif owl_server

class Mesh extends owl.Mesh {}
class Node extends owl.Node {}

class Server extends owl.Server {

	override function createMesh( id : String ) : Mesh {
		return new letterspace.Mesh( id );
	}

	static function main() {

		//'195.201.41.121';
		var host = '192.168.0.10';
		var port = 1377;

		var server = new letterspace.Server( host, port );
		server.start().then( function(_) {
			trace('SERVER READY');
			server.addMesh( new owl.Mesh('letterspace') );
        });
	}
}

#end
