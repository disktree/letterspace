package letterspace;

import haxe.io.Bytes;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Object;
import h2d.Tile;
import hxd.Event;
import hxd.Res;
import h2d.col.Point;
import js.html.ArrayBuffer;
import js.html.DataView;
import js.html.DivElement;
import js.html.Uint8Array;
import js.html.Uint16Array;
import om.Timer;
import om.Tween;
import om.ease.*;
import owl.Mesh;

@:enum abstract SyncType(Int) from Int to Int {
	var status_req = 0;
	var status_res = 1;
	var start = 2;
	var drag = 3;
	var stop = 4;
}

class Space extends hxd.App {

	public var width(default,null) : Int;
    public var height(default,null) : Int;

	var time : Float;
	var mesh : Mesh;
	var tiles : Map<String,Tile>;
	var letters : Array<Letter>;
	var container : Object;
	var background : Background;
	var letterContainer : Object;
	var interactive : Interactive;
	var draggedLetter : Letter;
	var draggedLetterOffset : Point;

	var dragged = false;
	//var dragOffset : Point;
	var dragOffsetX : Int;
	var dragOffsetY : Int;
	var borderDragSize = 100;
	var borderDragFactor = 4;

	//var pointerPos : Point;
	var pointerX = 0;
	var pointerY = 0;
	var pointerMoveX = 0;
	var pointerMoveY = 0;

	var offsetTween : Tween;
	var dragThrowFactor = 0.75;

	var menu : Menu;

	public function new( mesh : Mesh, width : Int, height : Int ) {
		super();
		this.mesh = mesh;
		this.width = width;
        this.height = height;
	}

	override function init() {

		time = 0;

		container = new Object( s2d );

		background = new Background( container, width, height, 0xFF202020, 0xFF050505, 10 );

		var chars = letterspace.macro.Build.getLetterChars( 'letter' );
		tiles = new Map<String,Tile>();
		for( c in chars ) {
			var t = Res.load('letter/$c.png').toTile();
			//t = t.center();
			tiles.set( c, t );
		}

		letters = [];
		letterContainer = new Object( container );
		letterContainer.filter = new h2d.filter.DropShadow( 2, 0.785, 0x000000, 0.3, 4, 2, 1, true );
		//container.filter = new h2d.filter.DropShadow( 2, 0.785, 0x000000, 0.3, 4, 2, 1, true );

		letterContainer.visible = false;
		var i = 0;
		for( n in 0...10 ) {
			for( c in tiles.keys() ) {
				var l = new Letter( i, c, tiles.get( c ) );
				letterContainer.addChild( l );
				letters.push( l );
				i++;
			}
		}

		//interactive = new Interactive( width, height, s2d );
		interactive = new Interactive( width, height, s2d );
		//interactive = new Interactive( window.innerWidth, window.innerHeight, s2d );
		interactive.cursor = Default;
		interactive.onPush = onMousePush;
		interactive.onMove = onMouseMove;
		interactive.onRelease = onMouseRelease;
		interactive.onOut = onMouseOut;
		interactive.onWheel = onMouseWheel;
		//interactive.onFocusLost = function(e)trace(e);

		mesh.onNodeJoin = function(n){
			trace('NODE JOINED '+n.id);
		}
		mesh.onNodeLeave = function(n){
			trace('NODE LEFT '+n.id);
		}
		mesh.onNodeData = function(n,buf:ArrayBuffer){
			trace('NODE DATA '+n.id);
			var v = new DataView( buf );
			var t : SyncType = v.getUint8(0);
			switch t {
			case status_req:
				var res = new DataView( new ArrayBuffer( 1 + letters.length * 4 ) );
				res.setUint8( 0, status_res );
				var i = 1;
				for( l in letters ) {
					res.setUint16( i, Std.int( l.x ) );
					res.setUint16( i+2, Std.int( l.y ) );
					i += 4;
				}
				mesh.send( res );
			case status_res:
				var i = 1;
				for( l in letters ) {
					l.setPosition( v.getUint16( i ), v.getUint16( i+2 ) );
					i += 4;
				}
				letterContainer.visible = true;
			case _:
				var l = letters[v.getUint16(1)];
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

		//trace(mesh.age);
		if( mesh.numNodes == 0 ) {
			for( l in letters ) {
				l.setPosition(
					Math.random() * (width-l.size.xMax),
					Math.random() * (height-l.size.yMax)
				);
			}
			letterContainer.visible = true;
		} else {
			///request status from a node
			///var n = mesh.first();
			var u = new Uint8Array( 1 );
			u[0] = status_req;
			mesh.first().send( u );
		}

		//engine.backgroundColor = 0xFF3D00;
		//s2d.setFixedSize( window.innerWidth, window.innerHeight );
		//engine.autoResize = false;

		offsetTween = new Tween( container ).easing( Exponential.Out )
			.onUpdate( function(){
				@:privateAccess container.posChanged = true;
			} );

		//centerOffset();

		menu = new Menu();

		window.onbeforeunload = function(e) {
			App.saveState();
			return null;
		}
	}

	override function dispose() {
		super.dispose();
	}

	override function onResize() {
		//interactive.width = window.innerWidth;
		//interactive.height = window.innerHeight;
		//s2d.setFixedSize( window.innerWidth, window.innerHeight );
		//var win = hxd.Window.getInstance();
		//trace(engine.width,win.width);
		//maxX = win.width;
		//maxY = win.height;
	}

	override function update( dt : Float ) {

		time += dt;
		Timer.step( time*1000 );
		Tween.step( dt*1000 );

		if( dragged ) {
			setOffsetX( Std.int( pointerX - dragOffsetX ) );
			setOffsetY( Std.int( pointerY - dragOffsetY ) );
		} else if( draggedLetter != null ) {

			var tx = Std.int( pointerX - draggedLetterOffset.x );
			var ty = Std.int( pointerY - draggedLetterOffset.y );

			var sx = getScreenX( tx );
			var sy = getScreenY( ty );

			if( sx < borderDragSize ) {
				if( container.x < 0 ) {
					var offset = Std.int( (borderDragSize-sx) / borderDragFactor );
					setOffsetX( Std.int( container.x + offset ) );
					var sp = getScreenX( tx - offset );
					if( sp < 0 ) offset -= Std.int( Math.abs( sp ) );
                    tx -= offset;
                    draggedLetterOffset.x += offset;
				}
			} else {
				//var sw = window.innerWidth / window.devicePixelRatio;
				var sw = s2d.width;
				if( sx > sw - borderDragSize ) {
					if( container.x + width > sw ) {
						var offset = Std.int( (borderDragSize-(sw-sx)) / borderDragFactor );
						setOffsetX( Std.int( container.x - offset ) );
						var sp = getScreenX( tx + offset );
						var mp = Std.int( sw - draggedLetter.size.x );
						if( sp > mp ) offset -= sp-mp;
						tx += offset;
						draggedLetterOffset.x -= offset;
					}
				}
			}

			if( sy < borderDragSize ) {
				if( container.y < 0 ) {
					var offset = Std.int( (borderDragSize-sy) / borderDragFactor );
					setOffsetY( Std.int( container.y + offset ) );
					var sp = getScreenY( ty - offset );
					if( sp < 0 ) offset -= Std.int( Math.abs( sp ) );
                    ty -= offset;
                    draggedLetterOffset.y += offset;
				}
			} else {
				var sh = s2d.height;
				if( sy > sh - borderDragSize ) {
					if( container.y + height > sh ) {
						var offset = Std.int( (borderDragSize-(sh-sy)) / borderDragFactor );
						setOffsetY( Std.int( container.y - offset ) );
						var sp = getScreenY( ty + offset );
						var mp = Std.int( sh - draggedLetter.size.y );
						if( sp > mp ) offset -= sp-mp;
						ty += offset;
						draggedLetterOffset.y -= offset;
					}
				}
			}

			if( tx < 0 ) tx = 0 else {
				var m = Std.int( width - draggedLetter.size.width );
				if( tx > m ) tx = m;
			}
			if( ty < 0 ) ty = 0 else {
				var m = Std.int( height - draggedLetter.size.height );
				if( ty > m ) ty = m;
			}

			draggedLetter.setPosition( tx, ty );

			sendLetterUpdate( drag, draggedLetter );
		}
	}

	inline function getScreenX( v : Int )
		return Std.int( v - Math.abs( container.x ) );

	inline function getScreenY( v : Int )
		return Std.int( v - Math.abs( container.y ) );

	function setOffsetX( v : Int ) {
		container.x = if( v > 0 ) 0 else {
			var m = - (width - window.innerWidth);
			container.x = (v < m) ? m : v;
		}
	}

	function setOffsetY( v : Int ) {
		container.y = if( v > 0 ) 0 else {
			var m = - (height - window.innerHeight);
			container.y = (v < m) ? m : v;
		}
	}

	function centerOffset() {
		setOffsetX( Std.int( s2d.width/2 - width/2 ) );
		setOffsetY( Std.int( s2d.height/2 - height/2 ) );
	}

	function getLetterAt( p : Point ) : Letter {
		for( l in letters ) if( l.getBounds().contains( p ) ) return l;
		return null;
	}

	function onMousePush( e : Event ) {
		var p = new Point( e.relX, e.relY );
		var l = getLetterAt( p );
		if( l != null ) {
			draggedLetterOffset = p.sub( new Point( l.x, l.y ) );
			draggedLetter = l;
			//draggedLetter = l.bringToFront();
			draggedLetter.startDrag();
			sendLetterUpdate( start, draggedLetter );
		} else {
			offsetTween.stop();
			dragged = true;
			dragOffsetX = Std.int( p.x - container.x );
			dragOffsetY = Std.int( p.y - container.y );
		}
	}

	function onMouseMove( e : Event ) {
		pointerMoveX = Std.int( e.relX - pointerX );
		pointerMoveY = Std.int( e.relY - pointerY );
		pointerX = Std.int( e.relX );
		pointerY = Std.int( e.relY );
		/*
		if( draggedLetter != null ) {
			var tx = e.relX - dragOffset.x;
			var ty = e.relY - dragOffset.y;
			draggedLetter.setPosition( tx, ty );
			sendLetterUpdate( drag, draggedLetter );
		}
		*/
	}

	function onMouseRelease( e : Event ) {
		if( dragged ) {
			dragged = false;
			var tx = Std.int( Math.max( Math.min( container.x + pointerMoveX * dragThrowFactor * 10, 0 ), s2d.width- width ) );
			var ty = Std.int( Math.max( Math.min( container.y + pointerMoveY * dragThrowFactor * 10, 0 ), s2d.height - height ) );
			var ax = Math.abs( pointerMoveX );
			var ay = Math.abs( pointerMoveY );
			var duration = ((ax > ay) ? ax : ay) * dragThrowFactor * 10;
			offsetTween.stop().to( { x : tx, y : ty  }, duration ).start();
		} else if( draggedLetter != null ) {
			draggedLetter.stopDrag();
			sendLetterUpdate( stop, draggedLetter );
			draggedLetter = null;
		}
	}

	function onMouseOut( e : Event ) {
		//trace("onMouseOut "+e);
		if( dragged ) {
			//dragged = false;
		} else if( draggedLetter != null ) {
			//draggedLetter = null;
			//stopLetterDrag
		}
	}

	function onMouseWheel( e : Event ) {
		//trace(e);
		if( e.wheelDelta > 0 ) {
			//container.scaleX += 0.1;
			//container.scaleY += 0.1;
		} else {
			//container.scaleX -= 0.1;
			//container.scaleY -= 0.1;
		}
		/*
		if( e. ) {
			setOffsetX( Std.int( container.x - e.deltaY ) );
		} else {
			setOffsetY( Std.int( container.y - e.deltaY ) );
		}
		*/
	}

	function sendLetterUpdate( t : SyncType, l : Letter ) {
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

/*
private class Background extends Bitmap {

	public function new( parent, width : Int, height : Int, backgroundColor : Int, gridColor : Int, gridSize : Int ) {

		var bmp = new hxd.BitmapData( width, height );
		//bmp.clear( 0xFF202020 );
		//bmp.line( 20, 10, 100, 100, 0xFF0000ff );
		//bmp.fill( 100, 0, 100, 200, 0xFF0000ff);

		var nx = Std.int( width/gridSize );
		var ny = Std.int( height/gridSize );
		var px = 0;
		var py = 0;

		for( i in 0...ny ) {
			//moveTo( 0, py );
			//lineTo( width, py );
			bmp.line( 0, py, width, py, 0xFF0000ff );
			py += gridSize;
		}

		var tile = h2d.Tile.fromBitmap( bmp );

		super( tile, parent );
	}
}
*/

private class Background extends Graphics {

	public function new( parent, width : Int, height : Int, backgroundColor : Int, gridColor : Int, gridSize : Int ) {

		super( parent );

		beginFill( backgroundColor );
		drawRect( 0, 0, width, height );
		endFill();

		/*

		var nx = Std.int( width/gridSize );
		var ny = Std.int( height/gridSize );
		var px = 0;
		var py = 0;

		this.lineStyle( 1, gridColor, 1.0 );

		for( i in 0...ny ) {
			moveTo( 0, py );
			lineTo( width, py );
			py += gridSize;
		}
		for( i in 0...nx ) {
			moveTo( px, 0 );
			lineTo( px, height );
			px += gridSize;
		}
		*/
	}
}

private class Menu {

	public function new() {

		var element = document.createDivElement();
		element.id = 'menu';
		//element.textContent = 'LETTERSPACE';
		document.body.appendChild( element );

		var numNodes = document.createDivElement();
		numNodes.textContent = '666';
		element.appendChild( numNodes );
	}
}
