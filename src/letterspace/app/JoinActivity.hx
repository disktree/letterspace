package letterspace.app;

import letterspace.game.Level;
import letterspace.game.User;
import owl.client.Server.Join;
import letterspace.net.Mesh;

private typedef Info = {
	name : String,
	?color : Int,
	?status : Array<Array<Int>>,
}

class JoinActivity extends Activity {

	var meshName : String;
	var userName : String;
	var status : DivElement;

	public function new( meshName : String, userName : String ) {

		super();
		this.meshName = meshName;
		this.userName = userName;

		status = document.createDivElement();
		status.classList.add( 'info' );
		element.appendChild( status );
	}

	override function onStart() {

		status.textContent = 'JOINING';

		var info : Info = { name : userName };

		App.server.onError = function(e){
			console.error(e);
		}

		App.server.join( meshName, info ).then( function(join:Join<Mesh,Info>){

			trace(join.info.status);

			var mesh = join.mesh;
			var user = new User( join.info.name, join.info.color );

			console.info('MESH [${mesh.id}] JOINED '+mesh.numNodes+' as '+join.info.name );
			status.textContent = 'MESH JOINED';

			//TODO get level from server/mesh

			//var charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!§$%&/()=?<>+*~,;.:-_#'".split("");
			//var charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!§$%&/()=?<>+*~,;.:-_#'".split("");
			var charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!$%&/()=?<>+*~.:-'".split("");
			//charset.push('"');
			//var chars = Lambda.array( Tileset.CHARACTERS );
			var chars = new Array<String>();
			for( i in 0...10 ) chars = chars.concat( charset );
			var theme = Level.THEME.get('antireal');
			//var theme = null;
			//var level = new Level( 4000, 3000, "helvetica", chars, theme );
			var level = new Level( 4000, 3000, "fff", chars, theme );

			Activity.set( new GameActivity( mesh, level, user, join.info.status ) );

		}).catchError( function(e){
			trace(e);
		});
	}

}
