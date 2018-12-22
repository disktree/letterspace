package letterspace;

import haxe.io.Bytes;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Object;
import h2d.Tile;
import hxd.Event;
import hxd.Key;
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

	var pointerX = 0.0;
	var pointerY = 0.0;
	var pointerMoveX = 0.0;
	var pointerMoveY = 0.0;

	var dragged = false;
	var dragOffsetX = 0.0;
	var dragOffsetY = 0.0;
	var dragBorderSize = 100;
	var dragBorderFactor = 0.5;

	var draggedLetter : Letter;
	var draggedLetterOffsetX : Float;
	var draggedLetterOffsetY : Float;

	//var offsetTween : Tween;
	//var dragThrowFactor = 0.75;

	var zoom = 1.0;
	var zoomFactor = 0.02;
	//var minZoom : Float;
	var maxZoom = 4;

	var menu : Menu;

	public function new( mesh : Mesh, width : Int, height : Int ) {
		super();
		this.mesh = mesh;
		this.width = width;
        this.height = height;
		//minZoom = Math.max( window.innerWidth / width, window.innerHeight / height );
	}

	override function init() {

		time = 0;

		container = new Object( s2d );

		background = new Background( container, width, height, 0xFF202020, 0xFF050505, 10 );

		var chars = letterspace.macro.Build.getLetterChars( 'letter/fff' );
		tiles = new Map<String,Tile>();
		for( c in chars ) {
			var t = Res.load('letter/fff/$c.png').toTile();
			//t = t.center();
			tiles.set( c, t );
		}

		letters = [];
		letterContainer = new Object( container );
		letterContainer.filter = new h2d.filter.DropShadow( 2, 0.785, 0x000000, 0.3, 4, 2, 1, true );
		//container.filter = new h2d.filter.DropShadow( 2, 0.785, 0x000000, 0.3, 4, 2, 1, true );

		letterContainer.visible = false;
		var i = 0;
		for( n in 0...100 ) {
			for( c in tiles.keys() ) {
				var l = new Letter( i, c, tiles.get( c ) );
				letterContainer.addChild( l );
				letters.push( l );
				i++;
			}
		}

		interactive = new Interactive( width, height, s2d );
		//interactive = new Interactive( window.innerWidth, window.innerHeight, s2d );
		interactive.cursor = Default;
		interactive.onPush = onMousePush;
		interactive.onMove = onMouseMove;
		interactive.onRelease = onMouseRelease;
		interactive.onOut = onMouseOut;
		interactive.onWheel = onMouseWheel;
		//interactive.onClick = function(e) trace(e);
		//interactive.onFocusLost = function(e)trace(e);
		interactive.onKeyDown = function(e){
			switch e.keyCode {
			case Key.C:
				if( draggedLetter == null ) centerOffset();
			}
		}

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

		/*
		offsetTween = new Tween( container ).easing( Exponential.Out )
			.onUpdate( function(){
				@:privateAccess container.posChanged = true;
			} );
		*/

		//centerOffset();

		menu = new Menu();
	}

	override function dispose() {
		super.dispose();
	}

	override function onResize() {
		//minZoom = Math.max( window.innerWidth / width, window.innerHeight / height );
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
			setOffsetX( pointerX - dragOffsetX );
			setOffsetY( pointerY - dragOffsetY );
		} else if( draggedLetter != null ) {

			//var tx = (pointerX - draggedLetterOffset.x);
			//var ty = (pointerY - draggedLetterOffset.y);

			//WORKS
			/*
			var tx = (pointerX/zoom);
			var ty = (pointerY/zoom);
			tx += Math.abs(container.x)/zoom;
			ty += Math.abs(container.y)/zoom;
			*/

			var tx = (pointerX/zoom) - draggedLetterOffsetX;
			var ty = (pointerY/zoom) - draggedLetterOffsetY;
			tx += Math.abs(container.x)/zoom;
			ty += Math.abs(container.y)/zoom;

			if( tx < 0 ) tx = 0 else {
				var m = width - draggedLetter.size.width;
				if( tx > m ) tx = m;
			}
			if( ty < 0 ) ty = 0 else {
				var m = height - draggedLetter.size.height;
				if( ty > m ) ty = m;
			}

			var sx = getScreenX( tx );
			var sy = getScreenY( ty );

			if( sx < dragBorderSize ) {
				if( container.x < 0 ) {
					var d = dragBorderSize - sx;
					var v = d * dragBorderFactor;
					setOffsetX( container.x + v );
				}
			} else {
				var sw = s2d.width;
				var sr = sx + draggedLetter.width;
				if( sr > sw - dragBorderSize ) {
					if( container.x + width > sw ) {
						var d = dragBorderSize - (sw-sr);
						var v = d * dragBorderFactor;
						setOffsetX( container.x - v );
					}
				}
			}

			if( sy < dragBorderSize ) {
				if( container.y < 0 ) {
					var d = dragBorderSize - sy;
					var v = d * dragBorderFactor;
					setOffsetY( container.y + v );
				}
			} else {
				var sh = s2d.height;
				var sb = sy + draggedLetter.height;
				if( sb > sh - dragBorderSize ) {
					if( container.y + height > sh ) {
						var d = dragBorderSize - (sh-sb);
						var v = d * dragBorderFactor;
						setOffsetY( container.y - v );
					}
				}
			}

			draggedLetter.setPosition( tx, ty );

			sendLetterUpdate( drag, draggedLetter );
		}
	}

	function getLetterAt( p : Point ) : Letter {
		for( l in letters ) if( l.getBounds().contains( p ) ) return l;
		return null;
	}

	inline function getLetterAtPointer() : Letter {
		return getLetterAt( new Point( pointerX, pointerY ) );
	}

	function setOffsetX( v : Float ) {
		container.x = if( v > 0 ) 0 else {
			var m = - (width*zoom - window.innerWidth);
			container.x = (v < m) ? m : v;
		}
	}

	function setOffsetY( v : Float ) {
		container.y = if( v > 0 ) 0 else {
			var m = - (height*zoom - window.innerHeight);
			container.y = (v < m) ? m : v;
		}
	}

	function centerOffset() {
		setOffsetX( Std.int( s2d.width/2 - width/2 ) );
		setOffsetY( Std.int( s2d.height/2 - height/2 ) );
	}

	inline function getScreenX( v : Float ) : Float {
		return v - Math.abs( container.x / zoom );
	}

	inline function getScreenY( v : Float ) : Float {
		return v - Math.abs( container.y / zoom );
	}

	function onMousePush( e : Event ) {
		var l : Letter;
		if( Key.isDown( Key.SPACE ) || (l = getLetterAtPointer()) == null ) {
			dragOffsetX = e.relX - container.x;
			dragOffsetY = e.relY - container.y;
			dragged = true;
		} else {
			draggedLetterOffsetX = e.relX/zoom - l.x + Math.abs(container.x/zoom) ;
			draggedLetterOffsetY = e.relY/zoom - l.y + Math.abs(container.y/zoom) ;
			draggedLetter = l.startDrag();
			sendLetterUpdate( start, draggedLetter );
		}
	}

	function onMouseMove( e : Event ) {
		pointerMoveX = e.relX - pointerX;
		pointerMoveY = e.relY - pointerY;
		pointerX = e.relX;
		pointerY = e.relY;
	}

	function onMouseRelease( e : Event ) {
		if( dragged ) {
			dragged = false;
			/*
			var tx = Std.int( Math.max( Math.min( container.x + pointerMoveX * dragThrowFactor * 10, 0 ), s2d.width- width ) );
			var ty = Std.int( Math.max( Math.min( container.y + pointerMoveY * dragThrowFactor * 10, 0 ), s2d.height - height ) );
			var ax = Math.abs( pointerMoveX );
			var ay = Math.abs( pointerMoveY );
			var duration = ((ax > ay) ? ax : ay) * dragThrowFactor * 10;
			offsetTween.stop().to( { x : tx, y : ty  }, duration ).start();
			*/
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
		if( e.wheelDelta > 0 ) {
			var minZoom = Math.max( window.innerWidth / width, window.innerHeight / height );
			zoom -= zoomFactor;
			if( zoom < minZoom ) zoom = minZoom;
			//var dx = width -  (width * zoom );
			//trace(container.getSize());
			//var size = container.getSize();
			container.scaleX = container.scaleY = zoom;
			//var nsize = container.getSize();

			//var min = window.innerWidth / (width + container.x);
			//trace(min);
			//if( zoom < min ) zoom = min;
			//minZoom = Math.max( window.innerWidth / width, window.innerHeight / height );
			//if( zoom < minZoom ) zoom = minZoom;
		} else {
			zoom += zoomFactor;
			if( zoom > maxZoom ) zoom = maxZoom;
			container.scaleX = container.scaleY = zoom;
		}
		//container.scaleX = container.scaleY = zoom;
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
