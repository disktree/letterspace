package letterspace;

import letterspace.Server;
import letterspace.app.Activity;
import letterspace.app.BootActivity;
import letterspace.app.ErrorActivity;
import letterspace.game.Tilemap;

class App  {

	public static inline var VERSION = '0.0.0';
	public static inline var REV = '0';

	//public static var isMobile(default,null) = om.System.isMobile();
	public static var hidden(default,null) = false;
	public static var storage(default,null) : Storage;
	public static var server(default,null) : Server;

	static function main() {

		console.info( 'LETTERSPACE $VERSION' );

		window.onload = function(){

			//for( k in Tileset.MAP.keys() ) trace(k);
			//for( k=>v in Tileset.MAP ) trace(k);

			/*
			var params = new js.html.URLSearchParams( window.location.search );
			if( params.has( 'host' ) ) host = params.get( 'host' );
			if( params.has( 'port' ) ) port = Std.parseInt( params.get( 'port' ) );
			*/

			var mainElement = document.querySelector( 'main' );

			if( System.isMobile() ) {
				Activity.init( new ErrorActivity( 'desktop devices only' ), mainElement );
				return;
			}
			if( !navigator.onLine ) {
				Activity.init( new ErrorActivity( 'internet connection required' ), mainElement );
				return;
			}

			storage = new Storage( 'letterspace_' );
			server = new Server();

			Activity.init( new BootActivity(), mainElement ).then( function(_){
				/*
				window.addEventListener( 'beforeunload', function(e){
					trace(e);
				}, false );
				*/
				document.addEventListener( 'visibilitychange', function(e) {
					App.hidden = document.hidden;
				}, false );
			});
		}
	}
}
