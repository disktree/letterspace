package letterspace;

class App  {

	//static var HOST = '192.168.0.10';
	static var HOST = '192.168.0.80';
	static var PORT = 1377;

	public static var server(default,null) : owl.Server;

	public static function saveState() {
		window.fetch( 'http://$HOST:$PORT/letterspace' );
	}

	static function main() {

		trace(navigator);

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
				var space = new letterspace.Space( mesh, 10000, 8000 );
			});
		});
	}
}
