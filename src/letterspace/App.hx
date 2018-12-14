package letterspace;

class App extends hxd.App {

	public static var server(default,null) : om.rtc.mesh.Server;

	static var status : Element;

	static function setStatusText( str = "" ) {
		status.style.display = if( str == null || str.length == 0 ) 'none' else 'block';
		status.textContent = str;
	}

	static function main() {

		status = document.getElementById( 'status' );

		if( !navigator.onLine ) {
			setStatusText( 'NOT ONLINE' );
			return;
		}

		setStatusText();

		hxd.Res.initEmbed();

		var ip = '192.168.0.10';
		var port = 1377;

		server = new om.rtc.mesh.Server( ip, port );
		server.connect().then( function(srv){

			console.log('Server connected ');

			var mesh = new letterspace.net.Mesh( 'letterspace' );
			mesh.onSignal = server.sendSignal;
			server.onSignal = function(msg){
				//trace("ON SERVER SIGNAL "+msg);
				mesh.handleSignal(msg);
			}
			server.onDisconnect = function(?e){
				console.warn(e.toString());
				setStatusText(e.toString());
			}
			mesh.onJoin = function(){
	            console.log( 'Joined '+mesh.id+' ('+mesh.numNodes+'/'+mesh.getConnectedNodes().length+')' );
				if( mesh.numNodes == 0 ) {
					new Game( mesh );
				} else {
					mesh.onNodeConnect = function(node){
						console.log( '['+mesh.numNodes+'/'+mesh.getConnectedNodes().length+']' );
						var numConnectedNodes = mesh.getConnectedNodes().length;
	                    if( numConnectedNodes == mesh.numNodes ) {
	                        new Game( mesh );
	                    }
					}
				}
			}
			mesh.join();

		}).catchError( function(e){
			trace( e );
		});


	}
}
