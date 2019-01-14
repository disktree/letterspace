package letterspace.app;

import owl.client.Server.Join;

/*
private typedef Info = {
	name : String,
	?color : Int,
	?status : Array<Array<Int>>,
	?level: Dynamic
}
*/

class JoinActivity extends Activity {

	var meshName : String;
	var userName : String;
	var status : DivElement;

	public function new( meshName : String, userName : String ) {

		super();
		this.meshName = meshName;
		this.userName = userName;

		status = document.createDivElement();
		status.classList.add( 'status' );
		element.appendChild( status );
	}

	override function onStart() {

		status.textContent = 'joining $meshName';

		App.server.onError = function(e){
			console.error(e);
		}

		App.server.join( meshName, { name : userName } ).then( function(join:Join<Mesh,Level>){

			var creds = join.creds;

			status.textContent = 'joined as ${creds.name}';

			delay( function(){
				Activity.set( new GameActivity( join.mesh, join.data, new Node( App.server.id, creds ) ) );
			}, 100 );

		}).catchError( function(e){
			trace(e);
		});

		/*
		App.server.join( meshName, info ).then( function(join:Join<Mesh,Info>){

			//trace(join.info.status);
			trace(join.info.level);

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
			var level = new Level( 4000, 3000, "helvetica", chars, theme );

			Activity.set( new GameActivity( mesh, level, user, join.info.status ) );

		}).catchError( function(e){
			trace(e);
		});
		*/
	}

}
