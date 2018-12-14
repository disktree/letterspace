package letterspace;

import letterspace.game.Space;
import letterspace.net.Mesh;
import om.Json;
import om.Timer;
import om.Tween;

class Game extends hxd.App {

	var time : Float;
	var mesh : Mesh;
	var space : Space;

	public function new( mesh : Mesh ) {
		super();
		this.mesh = mesh;
	}

	override function init() {

		time = 0;

		mesh.onNodeConnect = function(node){
			trace( 'node connected: '+node );
		}
		mesh.onNodeDisconnect = function(node){
			trace( 'node disconnected: '+node );
        }
		mesh.onNodeMessage = function(node,msg){
			//trace( 'node message: '+node+' '+msg.type );
			switch msg.type {
			case 'join':
				node.sendMessage( { type: 'status', data: space.getLetterPositions() } );
			case 'status':
				var d : Array<Array<Int>> = msg.data;
				space.setLetterPositions( d );
			case 'dragstart':
				var d : { i : Int, p : Array<Int> } = msg.data;
				space.setLetterPosition( d.i, d.p[0], d.p[1] );
			case 'drag':
				var d : { i : Int, p : Array<Int> } = msg.data;
				space.setLetterPosition( d.i, d.p[0], d.p[1] );
			case 'dragstop':
				var d : { i : Int, p : Array<Int> } = msg.data;
				space.setLetterPosition( d.i, d.p[0], d.p[1] );
			default:
				trace( '??????????? '+msg );
			}
		}

		space = new Space( s2d, 600, 600 );
		space.onDragStart = function( l ) {
			//trace("onDragStart "+l.char);
			broadcast( 'dragstart', { i : l.index, p : [Std.int(l.x),Std.int(l.y)] } );
		}
		space.onDrag = function( l ) {
			//trace("onDrag "+l.char);
			broadcast( 'drag', { i : l.index, p : [Std.int(l.x),Std.int(l.y)] } );
		}
		space.onDragStop = function( l ) {
			//trace("onDragStop "+l.char);
			broadcast( 'dragstop', { i : l.index, p : [Std.int(l.x),Std.int(l.y)] } );
		}

		//var win = hxd.Window.getInstance();
		//win.addEventTarget( onEvent );
	}

	override function update( dt : Float ) {
		time += dt;
		Timer.step( time*1000 );
		Tween.step( dt*1000 );
		space.update( time );
	}

	override function onResize() {
		//var win = hxd.Window.getInstance();
	}

	inline function broadcast<T>( type : String, data : T ) {
		mesh.broadcast( Json.stringify( { type: type, data: data } ) );
	}

}
