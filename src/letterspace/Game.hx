package letterspace;

import js.html.ArrayBuffer;
import js.html.DataView;
import js.html.Uint8Array;
import owl.Mesh;

@:enum abstract SyncType(Int) from Int to Int {
	var status_req = 0;
	var status_res = 1;
	var start = 2;
	var drag = 3;
	var stop = 4;
}

class Game {

	var mesh : Mesh;
	var user : String;
	var space : Space;
	var menu : Menu;

	public function new( mesh : Mesh, user : String ) {

		this.mesh = mesh;
		this.user = user;

		hxd.Res.initEmbed();

		menu = new Menu();

		space = new Space( 6000, 6000 );
		space.onReady = function() {
			if( mesh.numNodes == 0 ) {
				for( l in space ) {
					l.setPosition(
						Math.random() * (space.width-l.width),
						Math.random() * (space.height-l.height)
					);
				}
			} else {
				///request status from a node
				var u = new Uint8Array( 1 );
				u[0] = status_req;
				mesh.first().send( u );
			}
		}
		space.onDragStart = function(l) {
			sendLetterUpdate( start, l );
		}
		space.onDrag = function(l) {
			sendLetterUpdate( drag, l );
		}
		space.onDragStop = function(l) {
			sendLetterUpdate( stop, l );
		}

		mesh.onNodeJoin = function(n:letterspace.Node){
			trace('NODE JOINED '+n.user);
		}
		mesh.onNodeLeave = function(n:letterspace.Node){
			trace('NODE LEFT '+n.id);
		}
		mesh.onNodeData = function(n:letterspace.Node,buf:ArrayBuffer){
			trace('NODE DATA '+n.user);
			var v = new DataView( buf );
			var t : SyncType = v.getUint8(0);
			switch t {
			case status_req:
				var res = new DataView( new ArrayBuffer( 1 + space.letters.length * 4 ) );
				res.setUint8( 0, status_res );
				var i = 1;
				for( l in space ) {
					res.setUint16( i, Std.int( l.x ) );
					res.setUint16( i+2, Std.int( l.y ) );
					i += 4;
				}
				n.send( res );
			case status_res:
				var i = 1;
				for( l in space ) {
					l.setPosition( v.getUint16( i ), v.getUint16( i+2 ) );
					i += 4;
				}
				//letterContainer.visible = true;
			case _:
				var l = space.letters[v.getUint16(1)];
				var x = v.getUint16(3);
				var y = v.getUint16(5);
				switch t {
				case start: l.startDrag();
				case stop: l.stopDrag();
				case _:
				}
				l.setPosition( x, y );
			}
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


private class Menu {

	public function new() {

		var element = document.createDivElement();
		element.id = 'menu';
		document.body.appendChild( element );

		var numNodes = document.createDivElement();
		numNodes.textContent = '666';
		element.appendChild( numNodes );
	}
}
