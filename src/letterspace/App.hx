package letterspace;

import letterspace.game.Game;
import letterspace.net.Mesh;
import letterspace.net.Server;

@:keep
class App  {

	static final HOST = '192.168.0.10';
	//static final HOST = '195.201.41.121';
	static final PORT = 1377;
	static final MESH = 'letterspace';

	static var storage : Storage;
	static var server : Server;
	static var game : Game;

	public static function saveState() {
		window.fetch( 'http://$HOST:$PORT/letterspace' );
	}

	@:expose("login")
	static function _login() {
		var form = cast document.querySelector( 'form.login' );
		var input : InputElement = untyped form.elements.item(0);
		var user : String = input.value;
		if( user.length > 0 ) {

			form.remove();
			input.disabled = true;
			storage.set( 'user', user );

			doLogin( user );

			/*
			server = new Server( HOST, PORT );
			server.connect().then( function(s){

				console.info( 'SERVER CONNECTED '+server.id );

				server.onDisconnect = function(){
					console.warn( 'SERVER DISCONNECTED' );
					//..
				}

				form.remove();

				server.join( 'letterspace', { user : user } ).then( function(mesh:Mesh){

					console.info('MESH JOINED '+mesh.numNodes );
					for( n in mesh ) trace(n);

					game = new Game( mesh, user );

					window.onbeforeunload = function(e) {
						//App.saveState();
						return null;
					}
				});

			}).catchError( function(e){
				trace(e);
				input.classList.add( 'error' );
				input.value = 'SERVER OFFLINE';
			});
			*/

		} else {
			input.value = 'Invalid';
		}
		return false;
	}

	static function doLogin( user : String ) {

		server = new Server( HOST, PORT );
		server.connect().then( function(s){

			console.info( 'SERVER CONNECTED '+server.id );

			server.onDisconnect = function(){
				console.warn( 'SERVER DISCONNECTED' );
				//..
			}

			//form.remove();

			server.join( 'letterspace', { user : user } ).then( function(mesh:Mesh){

				console.info('MESH JOINED '+mesh.numNodes );
				for( n in mesh ) trace(n);

				game = new Game( mesh, user, { width: 6000, height: 6000 } );

				window.onbeforeunload = function(e) {
					//App.saveState();
					return null;
				}
			});

		}).catchError( function(e){
			trace(e);
			//input.classList.add( 'error' );
			//input.value = 'SERVER OFFLINE';
		});
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
	}
}
