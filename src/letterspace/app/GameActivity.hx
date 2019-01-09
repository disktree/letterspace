package letterspace.app;

import letterspace.game.Letter;
import letterspace.game.Level;
import letterspace.game.Space;
import letterspace.game.Menu;
import letterspace.game.Tileset;
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
	var users : Map<String,User>;
	var canvas : CanvasElement;
	var space : Space;
	var menu : Menu;

	var status : Array<Array<Int>>;

	public function new( mesh : Mesh, level : Level, user : User, ?status : Array<Array<Int>> ) {

		super();
		this.mesh = mesh;
		this.level = level;
		this.user = user;

		this.status = status;

		canvas = document.createCanvasElement();
		canvas.id = 'webgl';
		canvas.style.display = 'none';
		element.appendChild( canvas );

		menu = new Menu( element, user );
	}

	override function onStart() {

		users = [];

		Space.create( function(space){

			this.space = space;

			space.init( level, user );
			space.setViewportPos();

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
				trace('NODE JOINED '+n.info.name);
				var user = new User( n.info.name, n.info.color );
				users.set( n.id, user );
				menu.addUser( user );
				updateWindowTitle();
			}
			mesh.onNodeLeave = function(n:Node){
				trace('NODE LEFT '+n.info.name);
				users.remove( n.id );
				menu.removeUser( n.info.name );
				updateWindowTitle();
			}
			mesh.onNodeData = function(n:Node,buf:ArrayBuffer){
				//trace('NODE DATA '+n.info.user);
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
						var user = users.get( n.id );
						l.startDrag( user );
					case stop: l.stopDrag();
					case _:
					}
					l.setPosition( x, y );
				}
			}

			if( mesh.numNodes == 0 ) {
				//trace(" I AM LONLEY ");
				//trace(status);
				if( status != null ) {
					var i = 0;
					for( pos in status ) {
						space.letters[i].setPosition( pos[0], pos[1] );
						i++;
					}
				} else {
					for( l in space.letters ) {
						l.setPosition(
							Std.int( Math.random() * (space.width-l.width) ),
							Std.int( Math.random() * (space.height-l.height) )
						);
					}
				}
			
				/*
				App.server.getStatus().then( function(r){
					//trace(r.length,space.letters.length);
					//trace(r);
					if( r.length > 0 && r.length == space.letters.length ) {
						var i = 0;
						for( pos in r ) {
							space.letters[i].setPosition( pos[0], pos[1] );
							i++;
						}
					} else {
						for( l in space.letters ) {
							l.setPosition(
								Std.int( Math.random() * (space.width-l.width) ),
								Std.int( Math.random() * (space.height-l.height) )
							);
						}
					}
				});
				*/
			} else {
				for( n in mesh ) {
					var user = new User( n.info.name, n.info.color );
					users.set( n.id, user );
					menu.addUser( user );
				}
				///TODO request status from a node
				var u = new Uint8Array( 1 );
				u[0] = status_req;
				mesh.first().send( u );
			}

			updateWindowTitle();

			canvas.style.display = 'block';

			App.server.onDisconnect = function(?reason){
				//mesh.leave();
				Activity.set( new ErrorActivity('DISCONNECTED: $reason') );
			}

			window.addEventListener( 'beforeunload', handleBeforeUnload, false );
		});
	}

	override function onStop() {
		window.removeEventListener( 'beforeunload', handleBeforeUnload );
	}

	function handleBeforeUnload(e) {
		e.preventDefault();
		if( mesh.numNodes == 0 ) {
			//TODO send status to server for storage
			var status = new Array<Array<Int>>();
			for( l in space ) {
				status.push( [Std.int(l.x),Std.int(l.y)] );
			}
			App.server.setStatus( status ).then( function(_){
				mesh.leave();
				space.dispose();
			}).catchError( function(e){
				console.error(e);
				mesh.leave();
				space.dispose();
			});
			e.returnValue = '';
			//return 'EXIT?';
		} else {
			mesh.leave();
			space.dispose();
			//e.returnValue = '';
			//return null;
		}
	}

	function updateWindowTitle() {
		document.title = 'LETTERSPACE ('+(mesh.numNodes+1)+')';
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
