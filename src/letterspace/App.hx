package letterspace;

class App  {

	//static var HOST = '192.168.0.80';
	static var HOST = '192.168.0.10';
	static var PORT = 1377;

	public static var server(default,null) : owl.Server;

	static var space : Space;

	public static function saveState() {
		window.fetch( 'http://$HOST:$PORT/letterspace' );
	}

	static function main() {

		if( !navigator.onLine ) {
			console.warn( 'NOT ONLINE' );
			return;
		}

		hxd.Res.initEmbed();

		server = new owl.Server( HOST, PORT );
		server.connect().then( function(s){
			console.info( 'SERVER CONNECTED '+server.id );
			server.join( 'letterspace' ).then( function(mesh){
				trace('MESH JOINED '+mesh.numNodes );
				space = new letterspace.Space( mesh, 6000, 6000 );
			});
		});

		window.onbeforeunload = function(e) {
			//App.saveState();
			return null;
		}
	}
}
