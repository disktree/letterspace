package letterspace;

import letterspace.game.Level;
import letterspace.game.Space;
import letterspace.net.Mesh;
import om.Timer;
import om.Tween;

class Game extends hxd.App {

	var time : Float;
	var mesh : Mesh;
	var level : Level;
	var space : Space;

	public function new( mesh : Mesh ) {
		super();
		this.mesh = mesh;
		this.level = {
			width: 1920, height: 1080,
			theme: {
				background: {
					color: 0x303030,
					grid: {
						color: 0x202020,
						size: 10
					}
				}
			}
		};
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
			trace( "onNodeMessage", msg.type+' '+node );
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

		space = new Space( s2d, level.width, level.height, level.theme );
		//space.setScale(2);
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
