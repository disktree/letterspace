package letterspace.game;

import js.html.ArrayBuffer;
import js.html.DataView;
import js.html.Uint8Array;
import letterspace.Server;

enum abstract SyncType(Int) from Int to Int {
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

	public function new( mesh : Mesh, user : String, level : Level ) {

		this.mesh = mesh;
		this.user = user;

		menu = new Menu();
		menu.addUser( user );

		/*
		space = new Space( level.width, level.height );
		space.onReady = function() {
			if( mesh.numNodes == 0 ) {
				for( l in space ) {
					l.setPosition(
						Math.random() * (space.width-l.width),
						Math.random() * (space.height-l.height)
					);
				}
			} else {
				for( n in mesh ) {
					menu.addUser( cast(n,letterspace.net.Node).user );
				}
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
		*/

		Space.create( function(space){

			trace( 'SPACE READY' );

			this.space = space;

			//var chars = letterspace.macro.Build.getTilesetCharacters( 'helvetica' );
			var chars = letterspace.macro.Build.getTilesetCharacters( 'fff' );
			var tiles = new Map<String,h2d.Tile>();
			for( c in chars ) {
				var t = hxd.Res.load('letter/fff/$c.png').toTile();
				//t = t.center();
				tiles.set( c, t );
			}

			space.init( 4000, 2000, tiles );

			var i = 0;
			for( n in 0...10 ) {
				for( c in tiles.keys() ) {
					space.addLetter( c );
					//var l = space.addLetter( c );
					//l.x = Math.random() * space.width;
					//l.y = Math.random() * space.height;
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

			mesh.onNodeJoin = function(n:Node){
				trace('NODE JOINED '+n.user);
				menu.addUser( n.user );
			}
			mesh.onNodeLeave = function(n:Node){
				trace('NODE LEFT '+n.user);
				menu.removeUser( n.user );
			}
			mesh.onNodeData = function(n:Node,buf:ArrayBuffer){
				trace('NODE DATA '+n.user);
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
					case start: l.startDrag();
					case stop: l.stopDrag();
					case _:
					}
					l.setPosition( x, y );
				}
			}

			if( mesh.numNodes == 0 ) {
				trace(" I AM LONLEY ");

				for( l in space.letters ) {
					l.setPosition(
						Math.random() * (space.width-l.width),
						Math.random() * (space.height-l.height)
					);
				}


			} else {
				for( n in mesh ) {
					menu.addUser( cast(n,letterspace.Node).user );
				}
				///request status from a node
				var u = new Uint8Array( 1 );
				u[0] = status_req;
				mesh.first().send( u );
			}
		});
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

	var element : Element;
	var users : Element;

	public function new() {

		var element = document.createDivElement();
		element.id = 'menu';
		document.body.appendChild( element );

		users = document.createDivElement();
		element.appendChild( users );

		//var numNodes = document.createDivElement();
		//numNodes.textContent = '666';
		//element.appendChild( numNodes );
	}

	public function addUser( name : String ) {
		var e = document.createDivElement();
		e.setAttribute( 'data-name', name );
		e.textContent = name;
		users.appendChild( e );
	}

	public function removeUser( name : String ) {
		var e = users.querySelector( '[data-name="$name"]' );
		e.remove();
	}
}
