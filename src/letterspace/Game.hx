package letterspace;

import hxd.Event;
import hxd.Res;
import h2d.Tile;
import letterspace.net.Mesh;
import om.Json;
import om.Timer;
import om.Tween;

class Game extends hxd.App {

	public static var W = 600;
	public static var H = 600;

	public static var mouseX = 0.0;
	public static var mouseY = 0.0;

	var time = 0.0;

	var mesh : Mesh;
	var meshUpdateTimer : Timer;
	var meshUpdateDataQueue : Array<Array<Int>>;

	var letters : Array<Letter>;
	var draggedLetter : Letter;
	var lastDraggedLetterIndex : Int;

	public function new( mesh : Mesh ) {
		super();
		this.mesh = mesh;
	}

	override function init() {

		mesh.onNodeConnect = function(node){
			trace( 'node connected: '+node );
		}
		mesh.onNodeDisconnect = function(node){
			trace( 'node disconnected: '+node );
        }
		mesh.onNodeMessage = function(node,msg){
			//trace( 'node message: '+node+' '+msg );
			switch msg.type {
			case 'join':
				node.sendMessage( { type: 'status', data: getMeshStatusData() } );
			case 'status':
				//trace("status >>>>>>>>>>>>>>>>>>>>");
				var d : { letters: Array<Array<Int>> } = msg.data;
				for( i in 0...d.letters.length ) {
                    var pos = d.letters[i];
                    var l = letters[i];
                    //space.letters[i].setPosition( pos[0], pos[1] );
                    l.x = pos[0];
                    l.y = pos[1];
                }
			case 'dragstart':
				var d : { i : Int, pos: {x:Int,y:Int}} = msg.data;
				var l = letters[d.i];
				bringToFront( l );
				l.x = d.pos.x;
				l.y = d.pos.y;
                //letter.startMove( data.pos.x, data.pos.y );
			case 'drag':
				var d : { i : Int, positions: Array<Array<Int>> } = msg.data;
                var l = letters[d.i];
				l.movePositions( d.positions );
			case 'dragend':
                var d : { i : Int, pos: {x:Int,y:Int}} = msg.data;
                var l = letters[d.i];
				l.x = d.pos.x;
				l.y = d.pos.y;
                //TODO letter.stopMove( data.pos.x, data.pos.y );
			default:
				trace( '??????????? '+msg );
			}
		}

		meshUpdateDataQueue = [];
		meshUpdateTimer = new Timer( 68 );
		meshUpdateTimer.onUpdate( updateMesh );
		meshUpdateTimer.start();
		//meshUpdateTimer.run = updateMesh;

		onResize();

		var chars = Build.getLetters();

		//var tiles = new Map<String,Tile>();
		//for( c in chars ) {

		letters = [];
		for( i in 0...chars.length ) {
			var c = chars[i];
			var l = new Letter( i, c, s2d );
			l.onDragStart = onLetterDragStart;
			letters.push( l );
		}
		var px = 0, py = 0;
		for( l in letters ) {
			l.moveTo( px, py );
			if( (px += l.width+2) >= W-100 ) {
				px = 0;
				py += 100;
			}
		}

		var win = hxd.Window.getInstance();
		win.addEventTarget( onEvent );
	}

	override function update( dt : Float ) {

		time += dt;
		Timer.step( time*1000 );
		Tween.step( dt*1000 );

		mouseX = s2d.mouseX;
		mouseY = s2d.mouseY;
		//for( l in letters ) l.update();
		if( draggedLetter != null ) {
			draggedLetter.update();
			//...
			var px = Std.int( draggedLetter.x );
            var py = Std.int( draggedLetter.y );
			meshUpdateDataQueue.push( [px,py] );
		}
	}

	override function onResize() {
		var win = hxd.Window.getInstance();
		W = win.width;
		H = win.height;
	}

	function onEvent( e : Event ) {
		//trace( e );
		switch e.kind {
		case ERelease:
			if( draggedLetter != null ) {
				draggedLetter.stopDrag();
				broadcast( 'dragend', { i: draggedLetter.index, pos: { x: draggedLetter.x, y: draggedLetter.y } } );
				draggedLetter = null;
			}
		default:
		}
	}

	function bringToFront( letter : Letter ) {
		letter.remove();
		s2d.addChild( letter );
	}

	function onLetterDragStart( l : Letter ) {
		bringToFront( l );
		lastDraggedLetterIndex = l.index;
		draggedLetter = l;
		meshUpdateDataQueue = [];
		broadcast( 'dragstart', { i: l.index, pos: { x: l.x, y: l.y } } );
	}

	function getMeshStatusData() : Dynamic {
		return { letters: [ for( l in letters ) [l.x,l.y] ] }
	}

	function updateMesh() {
		///trace("updateMesh ");
        untyped window.requestIdleCallback( flushMeshDragData );
    }

	function flushMeshDragData() {
		//trace("flushMeshDragData "+meshUpdateDataQueue.length);
        if( meshUpdateDataQueue.length > 0 ) {
            broadcast( 'drag', { i: lastDraggedLetterIndex, positions: meshUpdateDataQueue } );
            meshUpdateDataQueue = [];
        }
    }

	@:access(letterspace.mesh.Node)
    function broadcast( type : String, data : Dynamic ) {
        var msg : om.rtc.mesh.Message = { type: type, data: data };
        var str = try Json.stringify( msg ) catch(e:Dynamic) {
            console.error(e);
            return;
        }
        //for( n in mesh ) n.dataChannel.send( str );
        for( n in mesh ) n.send( str );
    }

}
