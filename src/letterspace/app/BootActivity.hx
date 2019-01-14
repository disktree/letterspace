package letterspace.app;

class BootActivity extends Activity {

	//static inline var HOST = '195.201.41.121';
	static inline var HOST = '192.168.0.10';
	static inline var PORT = 1377;

	var status : DivElement;

	public function new() {
		super();
		status = document.createDivElement();
		status.classList.add( 'status' );
		element.appendChild( status );
	}

	override function onStart() {
		delay( function(){
			connectServer( HOST, PORT );
		}, 100 );
	}

	function connectServer( host : String, port : Int ) {

		status.textContent = 'connecting $host:$port';

		App.server.onDisconnect = function(?reason){
			console.warn(reason);
			status.textContent = 'disconnect';
			if( reason != null ) status.textContent += ' : '+reason;
		}
		App.server.connect( host, port ).then( function(s){

			App.server.onDisconnect = null;//TODO

			status.textContent = 'connected';

			hxd.Res.initEmbed( { compressSounds: true } );

			delay( function(){
				Activity.set( new LobbyActivity() );
			}, 200 );

		}).catchError( function(e){

			console.error(e);

			var sound = document.createAudioElement();
			sound.src = 'snd/server_unavailable.mp3';
			sound.play();

			status.textContent = 'server unavailable';
			status.onclick = function() {
				status.onclick = null;
				status.textContent = '...';
				delay( function(){
					connectServer( HOST, PORT );
				}, 200 );
			}
		});
	}

}
