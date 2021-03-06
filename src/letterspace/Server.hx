package letterspace;

import om.URL;

class Server extends owl.Server {

	#if owl_client

	public inline function lobby() : Promise<Dynamic> {
		return request( 'lobby' );
	}

	override function createMesh( id : String ) : Mesh {
		return new letterspace.Mesh( this, id );
	}

	#elseif owl_server

	static var ALLOWED_ORIGINS(default,null) = [
		"http://disktree.net",
		"https://disktree.net",
		"http://letterspace.disktree.net",
		#if dev
		"http://localhost",
		"http://127.0.0.1",
		"http://192.168.0.10",
		#end
	];

	public static var isSystemService(default,null) = false;

	override function createMesh( id : String ) {
		return throw "forbidden";
	}

	override function handleRequest( req : js.node.http.IncomingMessage, res : js.node.http.ServerResponse ) {

		var origin = req.headers["origin"];
		if( ALLOWED_ORIGINS.indexOf( origin ) != -1 ) {
			res.setHeader( 'Access-Control-Allow-Origin', origin );
			res.setHeader( 'Access-Control-Allow-Methods', 'GET,POST' );
		} else {
			res.statusCode = 403;
			res.end();
			return;
		}

		var url = URL.parse( req.url, true );
		var path = url.path.substr(1);
		var parts = path.split( '/' );
		switch parts[0] {
		case 'lobby':
			//TODO
			/*
			var data = [for(m in meshes)
				{
					mesh: m.id,
					nodes: [for(n in m.nodes) m.credentials.get( n.id )]
				}
			];
			*/
			var data = [for( m in meshes) cast(m,Mesh).level ];
			res.end( Json.stringify( data ) );

		case 'status':
			var mesh = parts[1];
			//trace('STATUS:'+mesh+':'+parts[2]);
			if( meshes.exists( mesh ) ) {
				var path = process.argv[1].directory()+'/status/$mesh.json';
				switch parts[2] {
				case 'get',null:
					var str = sys.FileSystem.exists( path ) ? sys.io.File.getContent( path ) : '[]';
					res.end( str );
				case 'set':
					var str = '';
					req.on( 'data', c -> str += c );
					req.on( 'end', () -> {
						//TODO validate data
						//trace(">>>>>>>>>>>>>>>> "+path);
						//var data = Json.parse( str );
						//trace(data);
						//var dir = process.argv[1].directory();
						sys.io.File.saveContent( path, str );
						res.end();
					});
				default:
				}
			}
			/*
			switch parts[1] {
			case 'get':
				trace("GET ...");
				res.setHeader( 'Content-Type', 'text/json' );
				var path = process.argv[1].directory()+'/status.json';
				trace(path);
				//Fs.exists( path, function );
				var str = sys.FileSystem.exists( path ) ? sys.io.File.getContent( path ) : '[]';
				res.end( str );
			case 'set':
				trace("SET ... ");
				var str = '';
				req.on( 'data', c -> str += c );
				req.on( 'end', () -> {
					//var data = Json.parse( str );
					//trace(data);
					var dir = process.argv[1].directory();
					sys.io.File.saveContent( '$dir/status.json', str );
					res.end();
				});
			}
			*/
		}
	}

	public static function log( msg : Dynamic ) {
		if( !isSystemService ) print( DateTools.format( Date.now(), "%H:%M:%S" )+' ' );
		println( msg );
	}

	public static function exit( ?msg : Dynamic, code = 0 ) {
		if( msg != null ) println( msg );
		Sys.exit( code );
	}

	static function main() {

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

		if( isSystemService && !System.is( 'linux' ) ) exit( 'linux only', 1 );

		switch host {
		case null,'auto':
			host = om.Network.getLocalIP()[0];
			if( host == null ) exit( 'failed to resolve host name', 1 );
		default:
		}

		if( !sys.FileSystem.exists( 'status' ) )
			sys.FileSystem.createDirectory( 'status' );

		Fs.readdir( 'level', function(e,files){

			var levels = files.filter( f -> return f.extension() == 'json' ).map( f -> return f.withoutExtension() );

			log( 'START $host:$port' );

			var server = new Server( host, port, 1000 );
			server.start().then( function(_) {
				return Promise.all( levels.map( id -> return Mesh.load( id ) ) ).then( meshes -> {
					for( m in meshes ) {
						server.addMesh( m );
					}
				});
			}).catchError( function(e){
				exit( e );
			});
		});
	}

	#end
}
