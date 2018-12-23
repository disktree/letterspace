package letterspace;

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

class Mesh extends owl.Mesh {
	override function createNode( id : String, ?info : Dynamic ) : Node {
		//trace("createNode "+info);
		return new Node( id, info.user );
	}
}

/*
class Node extends owl.Node {
	public var user(default,null) : String;
	public function new( id : String, user : String ) {
		super( id );
		this.user = user;
	}
}
*/

@:keep
class App  {

	static var HOST = '192.168.0.10';
	static var PORT = 1377;
	static var MESH = 'letterspace';

	static var storage : Storage;
	static var server : owl.Server;
	//static var game : Game;
	//static var space : Space;

	public static function saveState() {
		window.fetch( 'http://$HOST:$PORT/letterspace' );
	}

	@:expose("login")
	static function _login() {
		var form = cast document.querySelector( 'form.login' );
		var input : InputElement = untyped form.elements.item(0);
		var user : String = input.value;
		if( user.length > 0 ) {
			input.disabled = true;
			storage.set( 'user', user );
			server = new letterspace.Server( HOST, PORT );
			server.connect().then( function(s){

				console.info( 'SERVER CONNECTED '+server.id );

				form.remove();

				server.join( 'letterspace', { user : user } ).then( function(mesh){

					console.info('MESH JOINED '+mesh.numNodes );
					for( n in mesh ) trace(n);

					//var canvas = document.createCanvasElement();
					//canvas.id = 'webgl';
					//document.body.querySelector( 'main' ).appendChild( canvas );

					//hxd.Res.initEmbed();
					//space = new letterspace.Space( mesh, user, 6000, 6000 );
					var game = new Game( mesh, user );

				});
			}).catchError( function(e){
				trace(e);
				input.classList.add( 'error' );
				input.value = 'SERVER OFFLINE';
			});
		} else {
			input.value = 'Invalid';
		}
		return false;
	}

	static function main() {

		console.info('LETTERSPACE');

		if( !navigator.onLine ) {
			console.warn( 'NOT ONLINE' );
			return;
		}

		storage = new Storage( 'letterspace_' );

		var form = cast document.querySelector( 'form.login' );
		var input : InputElement = form.elements.item(0);
		input.value = storage.get( 'user' );
		input.focus();

		window.onbeforeunload = function(e) {
			//App.saveState();
			return null;
		}
	}
}
