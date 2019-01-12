package letterspace.app;

import letterspace.game.Menu;
import letterspace.game.Letter;
import letterspace.game.Space;
import letterspace.game.Tilemap;

private enum abstract SyncType(Int) from Int to Int {
	var status_request = 0;
	var status_response = 1;
	var drag_start = 2;
	var drag = 3;
	var drag_stop = 4;
}

class GameActivity extends Activity {

	var mesh : Mesh;
	var level : Level;
	var user : Node;
	//var users : Map<String,User>;
	var space : Space;
	var menu : Menu;

	/*
	var users : Map<String,User>;
	//var status : Array<Array<Int>>;
	*/

	public function new( mesh : Mesh, level : Level, user : letterspace.Node ) {

		super();
		this.mesh = mesh;
		this.level = level;
		this.user = user;
		//this.status = status;

		var canvas = document.createCanvasElement();
		canvas.id = 'webgl';
		//canvas.width = level.width;
		//canvas.height = level.height;
		element.appendChild( canvas );

		menu = new Menu( element, user );
	}

	override function onCreate<T:Activity>() : Promise<T> {
		return Space.create( level ).then( function(space){
			this.space = space;
			return cast this;
		});
	}

	override function onStart() {

		App.server.onDisconnect = function(?r){
			console.warn(r);
			Activity.set( new ErrorActivity(r) );
		}

		mesh.onNodeJoin = function(n:Node){
			trace('NODE JOINED '+n.name);
			menu.addUser( n );
			updateWindowTitle();
		}
		mesh.onNodeLeave = function(n:Node){
			trace('NODE LEFT '+n.id);
			menu.removeUser( n );
			updateWindowTitle();
		}
		mesh.onNodeData = function(n:Node,buf:ArrayBuffer){
			//trace('NODE DATA '+n.id);
			var v = new DataView( buf );
			var t : SyncType = v.getUint8(0);
			switch t {
			case status_request:
				//trace("NODE WANTS STATUS DATA");
				var res = new DataView( new ArrayBuffer( 1 + space.letters.length * 4 ) );
				res.setUint8( 0, status_response );
				var i = 1;
				for( l in space.letters ) {
					res.setUint16( i, Std.int( l.x ) );
					res.setUint16( i+2, Std.int( l.y ) );
					i += 4;
				}
				n.send( res );
			case status_response:
				//trace("GOT STATUS DATA ...");
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
				case drag_start:
					//TODO
					//var user = users.get( n.id );
					//l.startDrag( user );
					l.startDrag( n );
					menu.setDragStart( n, l );
				case drag_stop:
					l.stopDrag();
					menu.setDragStop( n );
				case _:
				}
				l.setPosition( x, y );
			}
		}

		space.onDragStart = function(l) {
			l.startDrag( user );
			menu.setDragStart( user, l );
			sendLetterUpdate( drag_start, l );
		}
		space.onDrag = function(l) {
			sendLetterUpdate( drag, l );
		}
		space.onDragStop = function(l) {
			l.stopDrag();
			menu.setDragStop( user );
			sendLetterUpdate( drag_stop, l );
		}

		if( mesh.numNodes == 0 ) {
			for( l in space.letters ) {
				l.setPosition(
					Std.int( Math.random() * (space.width-l.width) ),
					Std.int( Math.random() * (space.height-l.height) )
				);
			}
		} else {

			for( n in mesh ) {
				//var user = new User( n.info.name, n.info.color );
				//users.set( n.id, user );
				menu.addUser( cast(n,Node) );
			}

			var u = new Uint8Array( 1 );
			u[0] = status_request;
			mesh.first().send( u );

		}

		updateWindowTitle();

		space.start();

		window.addEventListener( 'beforeunload', handleBeforeUnload, false );
		window.addEventListener( 'keyup', handleKeyUp, false );
	}

	override function onStop() {
		window.removeEventListener( 'beforeunload', handleBeforeUnload );
		window.removeEventListener( 'keyup', handleKeyUp );
		//mesh.leave();
		App.server.leave( mesh );
	//	space.dispose();
		document.title = 'LETTERSPACE';
	}

	function handleKeyUp(e) {
		//trace(e.keyCode);
		switch e.keyCode {
		case 27: //ESC
			/*
			//Activity.pop();
			space.dispose();
			delay( function(){
				Activity.set( new LobbyActivity() );
			},1000);
			//space = null;
			//Activity.set( new BootActivity() );
			*/
		}
	}

	function handleBeforeUnload(e) {
		//e.preventDefault();
		if( mesh.numNodes == 0 ) {

			//TODO send status to server for storage
			/*
			var status = new Array<Array<Int>>();
			for( l in space.letters ) {
				status.push( [Std.int(l.x),Std.int(l.y)] );
			}
			App.server.leave( mesh, status );
			*/
			App.server.leave( mesh );
			/*
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
			*/
		} else {
			//mesh.leave();
			//space.dispose();
			//e.returnValue = '';
			//return null;
		}
	}

	function updateWindowTitle() {
		document.title = level.name+' ('+(mesh.numNodes+1)+')';
	}

	/*
	function requestSpaceStatus() {
		var u = new Uint8Array( 1 );
		u[0] = status_request;
		mesh.first().send( u );
	}
	*/

	function sendLetterUpdate( t : SyncType, l : Letter  ) {
		//trace(mesh.numNodes);
		if( mesh.numNodes > 0 ) {
			var v = new DataView( new ArrayBuffer( 7 ) );
			v.setUint8( 0, t );
			v.setUint16( 1, l.index );
			v.setUint16( 3, Std.int( l.x ) );
			v.setUint16( 5, Std.int( l.y ) );
			mesh.send( v );
		}
	}

}
