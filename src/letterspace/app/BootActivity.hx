package letterspace.app;

class BootActivity extends Activity {

	var status : DivElement;

	public function new() {
		super();
		status = document.createDivElement();
		status.classList.add( 'status' );
		element.appendChild( status );
	}

	override function onStart() {
		if( om.System.isMobile() ) {
			Activity.set( new ErrorActivity( 'DESKTOP DEVICES ONLY' ) );
		} else {
			connectServer();
		}
	}

	function connectServer() {
		if( navigator.onLine ) {
			status.textContent = 'connecting';
			delay( function(){
				App.server.connect().then( function(s){
					status.textContent = 'connected';
					delay( function(){
						Activity.set( new LoginActivity( 'USER_'+Std.int(Math.random()*1000) ) );
						//Activity.set( new LobbyActivity() );
					}, 100 );
				}).catchError( function(e){
					console.warn(e);
					status.textContent = 'server unavailable';
					//delay( connectServer, 5000 );
				});
			}, 100 );
		} else {
			Activity.set( new ErrorActivity( 'internet connection required' ) );
		}
	}

}
