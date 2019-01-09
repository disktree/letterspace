package letterspace;

import letterspace.Server;
import letterspace.app.Activity;
import letterspace.game.Tileset;

class App  {

	public static inline var VERSION = '0.0.0';

	//public static var isMobile(default,null) = om.System.isMobile();
	public static var hidden(default,null) = false;
	public static var storage(default,null) : Storage;
	public static var server(default,null) : Server;

	static function main() {

		console.info( 'LETTERSPACE' );

		//for( k in Tileset.MAP.keys() ) trace(k);
		//for( k=>v in Tileset.MAP ) trace(k);

		/*
		var host = '192.168.0.10';
		var port = 1377;
		var params = new js.html.URLSearchParams( window.location.search );
		if( params.has( 'host' ) ) host = params.get( 'host' );
		if( params.has( 'port' ) ) port = Std.parseInt( params.get( 'port' ) );
		*/

		if( System.isMobile() ) {
			Activity.boot( new letterspace.app.ErrorActivity( 'DESKTOP DEVICES ONLY' ) );
		} else {

			storage = new Storage( 'letterspace_' );
			server = new Server();

			hxd.Res.initEmbed( { compressSounds: true } );

			Activity.boot( new letterspace.app.BootActivity() );

			document.addEventListener( 'visibilitychange', function(e) {
				App.hidden = document.hidden;
			}, false );
		}
	}
}
