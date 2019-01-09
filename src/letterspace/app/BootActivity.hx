package letterspace.app;

/*
private typedef ServerInfo = {
	var host : String;
	var port : Int;
	@:optional var dev : Bool;
}
*/

class BootActivity extends Activity {

	var status : DivElement;
	//var servers : Array<ServerInfo>;
	//var serverIndex : Int;

	public function new() {
		super();
		status = document.createDivElement();
		status.classList.add( 'status' );
		element.appendChild( status );
	}

	override function onStart() {
		/*
		fetchJson( 'servers.json' ).then( function(servers:Array<ServerInfo>){
			this.servers = servers;
			trace( servers);
		});
		*/
		var host = '192.168.0.10';
		//var host = '195.201.41.121';
		var port = 1377;
		//var port = 8080;
		connectServer( host, port );
	}

	function connectServer( host : String, port : Int ) {
		if( navigator.onLine ) {
			status.textContent = 'connecting';
			delay( function(){
				App.server.onDisconnect = function(?reason){
					console.warn(reason);
					status.textContent = 'disconnect';
					if( reason != null ) status.textContent += ' : '+reason;
				}
				App.server.connect( host, port ).then( function(s){
					App.server.onDisconnect = null;//TODO
					status.textContent = 'connected';
					delay( function(){
						//Activity.set( new LoginActivity( 'USER_'+Std.int(Math.random()*1000) ) );
						Activity.set( new LobbyActivity() );
					}, 200 );
				}).catchError( function(e){
					console.error(e);
					status.textContent = 'server unavailable';
					//delay( connectServer, 5000 );
				});
			}, 100 );
		} else {
			Activity.set( new ErrorActivity( 'internet connection required' ) );
		}
	}

}
