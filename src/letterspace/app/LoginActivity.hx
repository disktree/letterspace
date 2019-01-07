package letterspace.app;

import letterspace.game.*;
import owl.Mesh;

class LoginActivity extends Activity {

	var user : String;

	public function new( user : String ) {
		super();
		this.user = user;
	}

	override function onStart() {

		var status = document.createDivElement();
		status.classList.add( 'info' );
		status.textContent = 'CONNECTING';
		element.appendChild( status );

		App.server.join( 'letterspace', { user : user } ).then( function(mesh:Mesh){

			console.info('MESH JOINED '+mesh.numNodes );

			status.textContent = 'MESH JOINED';

			//var level = new Level( 2000, 1000, 0xff050505, "helvetica", "AAAAAAAAAAAAAAABCDEFG012" );
			var user = new User( user, User.COLORS[mesh.numNodes] );
			//var game = new Game( mesh, level, user );

			Activity.set( new GameActivity( mesh, user ) );
		});
	}

}
