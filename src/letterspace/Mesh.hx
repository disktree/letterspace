package letterspace;

class Mesh extends owl.Mesh {

	#if owl_client

	public inline function loadStatus() : Promise<Array<Array<Int>>> {
		return server.request( 'status/$id' );
	}

	public inline function saveStatus( data : Dynamic ) : Promise<Nil> {
		return cast server.request( 'status/$id/set', data );
	}

	override function createNode( id : String, creds : Dynamic ) : Node {
		return new Node( id, creds );
	}

	#elseif owl_server

	static var USERCOLOR = [
		0xff0000,
		0xFF6F00,
		0x0D47A1,
		0x006064,
		0xBF360C,
		0x311B92,
		0x1B5E20,
		0x1A237E,
		0x01579B,
	];

	public final level : Level;

	function new( id : String, level : Level, ?maxNodes : Int, permanent = true ) {
        super( id, maxNodes, permanent );
		this.level = level;
    }

	public override function addNode( node : owl.Node, creds : Dynamic ) : Dynamic  {
		for( n in nodes ) {
			var _creds = credentials.get( n.id );
			if( creds.name == _creds.name ) {
				var i = 0;
				while( true ) {
					var name = creds.name + i;
					if( _creds.name != name ) {
						creds.name = name;
						break;
					}
					i++;
				}
			}
		}

		/*
		var lvl = Reflect.copy( level );
		if( numNodes == 0 ) {
			var path = process.argv[1].directory()+'/level/$id-status.json';
			if( sys.FileSystem.exists( path ) ) {
				lvl.status = Json.readFile( path );
			}
		}
		*/

		super.addNode( node, creds );
		creds.color = USERCOLOR[numNodes];

		return level;
	}

	public static function load( id : String, ?maxNodes : Int, ?permanent : Bool ) : Promise<Mesh> {
		return Json.readFile( 'level/$id.json' ).then( function(level){
			return Promise.resolve( new Mesh( id, level, maxNodes, permanent ) );
		});
	}

	#end
}
