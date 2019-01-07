package letterspace;

/*
#if owl_client

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

#if owl_server

import om.System;
import Sys.print;
import Sys.println;

class Mesh extends owl.Mesh {}
class Node extends owl.Node {}

#end

class Server extends owl.Server {

	#if owl_client
	/*
	//TODO load json
	public static var HOSTS(default,null) = [
		{ host:'' }
	];

	override function createMesh( id : String ) : Mesh {
		trace("createMesh");
		return new letterspace.Mesh( this, id );
	}
	*/
	#end

	#if owl_server

	public static var isSystemService(default,null) = false;
	public static var server(default,null) : Server;

	override function createMesh( id : String ) : Mesh {
		return new letterspace.Mesh( id );
	}

	static function exit( ?msg : Dynamic, code = 0 ) {
		if( msg != null ) println( msg );
		Sys.exit( code );
	}

	static function main() {

		if( !System.is( 'linux' ) ) exit( 'linux only', 1 );

		var host : String = null;
		var port = 1377;

		var argsHandler : {getDoc:Void->String,parse:Array<Dynamic>->Void};
		argsHandler = hxargs.Args.generate([
			["--service"] => function() isSystemService = true,
			@doc("Host name")["-host"] => function(name:String) host = name,
			@doc("Port number")["-port"] => function(number:Int) port = number,
			@doc("Print usage")["--help"] => function() {
				exit( 'Usage : letterserver <cmd> [params]\n'+argsHandler.getDoc(), 1 );
			},
			_ => function(arg) exit( 'Unknown parameter: $arg', 1 )
		]);
		argsHandler.parse( Sys.args() );

		switch host {
		case null,'auto':
			host = om.Network.getLocalIP()[0];
			if( host == null ) exit( 'failed to resolve host name', 1 );
		default:
		}

		println( 'Starting server $host:$port' );

		server = new letterspace.Server( host, port );
		server.start().then( function(_) {
			server.addMesh( new owl.Mesh('letterspace') );
        }).catchError( function(e){
			exit(e);
		});
	}

	#end
}
