package letterspace.app;

import letterspace.game.Letter;
import letterspace.game.Level;
import letterspace.game.Space;
import letterspace.game.Menu;
import letterspace.game.User;
import owl.Mesh;
import owl.Node;

enum abstract SyncType(Int) from Int to Int {
	var status_req = 0;
	var status_res = 1;
	var start = 2;
	var drag = 3;
	var stop = 4;
}

class GameActivity extends Activity {

	var mesh : Mesh;
	var level : Level;
	var user : User;
	var space : Space;
	var menu : Menu;

	public function new( mesh : Mesh, user : User ) {

		super();
		this.mesh = mesh;
		this.user = user;

		var canvas = document.createCanvasElement();
		canvas.id = 'webgl';
		element.appendChild( canvas );

		//menu = new Menu();
		//element.appendChild( menu.element );
	}

	override function onStart() {

		var charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split("");
		//var chars = charset.join('');
		var chars = new Array<String>();
		for( i in 0...4 ) chars = chars.concat( charset );
		var level = new Level( 4000, 3000, "helvetica2", chars, Level.THEME.get('apollo') );
		//var user = new User();

		menu = new Menu( user.name );
		element.appendChild( menu.element );
		//menu.addUser( user.name );

		Space.create( function(space){

			this.space = space;

			space.init( level, user );

			space.onDragStart = function(l) {
				sendLetterUpdate( start, l );
			}
			space.onDrag = function(l) {
				sendLetterUpdate( drag, l );
			}
			space.onDragStop = function(l) {
				sendLetterUpdate( stop, l );
			}

			mesh.onNodeJoin = function(n:Node){
				trace('NODE JOINED '+n.info.user);
				menu.addUser( n.info.user );
			}
			mesh.onNodeLeave = function(n:Node){
				trace('NODE LEFT '+n.info.user);
				menu.removeUser( n.info.user );
			}
			mesh.onNodeData = function(n:Node,buf:ArrayBuffer){
				trace('NODE DATA '+n.info.user);
				var v = new DataView( buf );
				var t : SyncType = v.getUint8(0);
				switch t {
				case status_req:
					trace("NODE WANTS STATUS DATA");

					var res = new DataView( new ArrayBuffer( 1 + space.letters.length * 4 ) );
					res.setUint8( 0, status_res );
					var i = 1;
					for( l in space.letters ) {
						res.setUint16( i, Std.int( l.x ) );
						res.setUint16( i+2, Std.int( l.y ) );
						i += 4;
					}
					n.send( res );

				case status_res:
					trace("GOT STATUS DATA ...");
					var i = 1;
					for( l in space.letters ) {
						l.setPosition( v.getUint16( i ), v.getUint16( i+2 ) );
						i += 4;
					}
					//letterContainer.visible = true;

				case _:
					var l = space.letters[v.getUint16(1)];
					var x = v.getUint16(3);
					var y = v.getUint16(5);
					switch t {
					case start:
						l.startDrag( n.info.user );
					case stop: l.stopDrag();
					case _:
					}
					l.setPosition( x, y );
				}
			}

			if( mesh.numNodes == 0 ) {
				//trace(" I AM LONLEY ");
				for( l in space.letters ) {
					l.setPosition(
						Math.random() * (space.width-l.width),
						Math.random() * (space.height-l.height)
					);
				}
			} else {
				for( n in mesh ) {
					//menu.addUser( cast(n,letterspace.Node).user );
					menu.addUser( n.info.user );
				}
				///request status from a node
				var u = new Uint8Array( 1 );
				u[0] = status_req;
				mesh.first().send( u );
			}
		});

		window.onbeforeunload = function(e) {
			#if dev
			return null;
			#else
			return 'Exit?';
			#end
		}
	}

	function sendLetterUpdate( t : SyncType, l : Letter  ) {
		//trace(mesh.numNodes);
		//if( mesh.numNodes > 0 ) {
			var v = new DataView( new ArrayBuffer( 7 ) );
			v.setUint8( 0, t );
			v.setUint16( 1, l.index );
			v.setUint16( 3, Std.int( l.x ) );
			v.setUint16( 5, Std.int( l.y ) );
			mesh.send( v );
		//}
	}

}
