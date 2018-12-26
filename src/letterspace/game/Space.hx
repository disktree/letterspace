package letterspace.game;

import h2d.Bitmap;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Object;
import h2d.Scene;
import h2d.Tile;
import h2d.col.Point;
import h2d.filter.*;
import h3d.Engine;
import hxd.Event;
import hxd.Key;
import hxd.Res;
import om.Timer;
import om.ease.*;
import om.loop.GameLoop as Loop;
import owl.Mesh;

class Space implements h3d.IDrawable {

	public dynamic function onDragStart( l : Letter ) {}
	public dynamic function onDrag( l : Letter ) {}
	public dynamic function onDragStop( l : Letter ) {}

	public var width(default,null) : Int;
	public var height(default,null) : Int;

	public var letters(default,null) = new Array<Letter>();

	var engine : Engine;
	var scene : Scene;
	var events : hxd.SceneEvents;
	var loop : Loop;

	var tiles : Map<String,Tile>;

	var container : Object;
	var background : Graphics;
	var letterContainer : Object;

	//var scrollbarX : Graphics;
	//var scrollbarY : Graphics;

	var interactive : Interactive;

	var pointer : Point;
	var pointerMove : Point;

	var dragged : Bool;
	var dragOffset : Point;

	var draggedLetter : Letter;
	var draggedLetterOffset : Point;

	var viewportX : Float;
	var viewportY : Float;

	var zoom = 1.0;
	var zoomMin : Float;
	var zoomMax : Float;

	public static function create( onReady : Space->Void ) {
		var engine = new Engine();
		engine.onReady = function(){
			onReady( new Space( engine ) );
		}
		engine.init();
	}

	function new( engine : Engine ) {
		this.engine = engine;
	}

	public function init( width : Int, height : Int, tiles : Map<String,Tile> ) {

		this.width = width;
		this.height = height;
		this.tiles = tiles;

		pointer = new Point();
		pointerMove = new Point();

		viewportX = viewportY = 0;

		dragged = false;
		dragOffset = new Point();

		draggedLetterOffset = new Point();

		//var canvas = document.getElementById( 'webgl' );
		//canvas.style.filter = 'grayscale(100%)';

		scene = new Scene();

		events = new hxd.SceneEvents();
		events.addScene( scene );

		container = new Object( scene );

		background = new Graphics( container );
		background.beginFill( 0x050505 );
		background.drawRect( 0, 0, width, height );
		background.endFill();

		zoom = 1.0;

		/*
		var pattern = Res.grid.pattern_24.toTile();
		trace(pattern.width);
		pattern.scaleToSize( 30, 30 );
		//var bmpd = new hxd.BitmapData( width, height );
		var nx = Std.int( width/20 );
		var ny = Std.int( height/20 );
		for( ix in 0...nx ) {
			for( iy in 0...ny ) {
				background.beginTileFill(ix*pattern.width, iy*pattern.height,1,1,pattern);
        		background.drawRect( ix*pattern.width, iy*pattern.height, pattern.width, pattern.height);
			}
		}
		*/

		var d = 10;
		var bmp = new hxd.BitmapData( d, d );
		bmp.line( 0, 0, d, 0, 0xff101010 );
		bmp.line( 0, 0, 0, d, 0xff101010 );
		var tile = Tile.fromBitmap( bmp );
		var nx = Std.int( width/10 );
		var ny = Std.int( height/10 );
		for( ix in 0...nx ) {
			for( iy in 0...ny ) {
				background.beginTileFill(ix*tile.width, iy*tile.height,1,1,tile);
        		background.drawRect( ix*tile.width, iy*tile.height, tile.width, tile.height);
			}
		}

		letterContainer = new Object( container );
		letterContainer.filter = new DropShadow( 2, 0.785, 0x000000, 0.3, 4, 2, 1, true );

		/*
		scrollbarH = new Graphics( scene );
		scrollbarH.beginFill( 0xff0000, 0.5 );
	//	scrollbarH.drawRect( 0, 0, window.innerWidth*(window.innerWidth/width), 10 );
		scrollbarH.endFill();
		*/

		var centerDings = new Graphics( container );
		centerDings.beginFill( 0x0000ff, 0.6 );
		centerDings.drawRect( width/2-1, 0, 2, height );
		centerDings.endFill();
		centerDings.beginFill( 0xff0000, 0.6 );
		centerDings.drawRect( 0, height/2-1, width, 2 );
		centerDings.endFill();

		setViewportPos();

		window.onresize = function(){
			zoomMin = Math.max( window.innerWidth / width, window.innerHeight / height );
			if( zoom < zoomMin ) zoom = zoomMin;
			container.scaleX = container.scaleY = zoom;
	//		setOffset( container.x, container.y );
			//scene.setFixedSize( window.innerWidth, window.innerHeight );
			//zoom = Math.max( window.innerWidth / width, window.innerHeight / height );
			//container.scaleX = container.scaleY = zoom;
			//scene.checkResize();
			//scene.width = 23;
			//engine.resize( window.innerWidth, window.innerHeight );
		}

		/*
		//engine.autoResize = false;
		//scene.setFixedSize( window.innerWidth, window.innerHeight );
		engine.onResized = function() {
			engine.resize( 23, 234 );
			//scene.setFixedSize( window.innerWidth, window.innerHeight );
			scene.checkResize();
			//zoom = Math.max( window.innerWidth / width, window.innerHeight / height );
			//container.scaleX = container.scaleY = zoom;
		}
		*/

		/*
		var win = hxd.Window.getInstance();
		win.addResizeEvent( function(){
			trace( "resii "+win.width,win.height );
		} );
		*/

		interactive = new Interactive( width, height, scene );
		interactive.cursor = Default;
		interactive.onPush = onMousePush;
		interactive.onMove = onMouseMove;
		interactive.onRelease = onMouseRelease;
		interactive.onOut = onMouseOut;
		interactive.onWheel = onMouseWheel;
		interactive.onKeyDown = function(e){
			//trace(e.keyCode);
			//interactive.cursor = Move;
			switch e.keyCode {
			case Key.LEFT: moveViewportX(0.01);
			case Key.RIGHT: moveViewportX(-0.01);
			case Key.UP: moveViewportY(0.01);
			case Key.DOWN: moveViewportY(-0.01);
			case Key.C: //if( draggedLetter == null ) centerOffset();
			}
		}

		Key.initialize();

		loop = new Loop( 60,
			function(dt) {
				events.checkEvents();
				update( dt );
				scene.setElapsedTime(dt);
			},
			function(dt) render( engine )
		).start();
	}

	public function addLetter( c : String ) : Letter {
		//var l = new Letter( letters.numChildren, c, tiles.get( c ) );
		var l = new Letter( letters.length, c, tiles.get( c ) );
		letters.push( l );
		letterContainer.addChild( l );
		//l.x = Math.random() * (width - l.width);
		//l.y = Math.random() * (height - l.height);
		return l;
	}

	function update( dt : Float ) {

		if( dragged ) {

			interactive.cursor = Move;

			var tx = pointer.x - dragOffset.x;
			var ty = pointer.y - dragOffset.y;

			if( tx > 0 ) tx = 0 else {
				var m = - (width * zoom - window.innerWidth);
				if( tx < m ) tx = m;
			}
			if( ty > 0 ) ty = 0 else {
				var m = - (height * zoom - window.innerHeight);
				if( ty < m ) ty = m;
			}

			container.x = tx;
			container.y = ty;

			//if( ty > 0 ) ty = 0;

			//setOffset( tx, ty );

			//scrollbarH.x = (width/2) / window.innerWidth * Math.abs(container.x);
			//var mx = (width/2);
			//var cx = (window.innerWidth/2) - ((window.innerWidth/10)/2);
			//var px = 0.75; //(((window.innerWidth) + Math.abs(container.x))) / (width/2);
			//scrollbarH.x = cx * px;

			//var screenW = window.innerWidth;
			//var scrollbarW = screenW * (screenW/width);
			//var mpx = pointer.x;

			//var px = (width-screenW)/100 + Mathh.abs(container.x);
			//trace( (width-screenW));

			/*
			var px = 1 - (Math.abs( container.x ) / screenW);
			trace(px);
			//scrollbarH.x = ((screenW/2)-(scrollbarW/2)) * px;
			scrollbarH.x = (screenW) * px;
			*/

			//container.setPosition( tx, ty );
			/*
			var tx = pointer.x - dragOffset.x;
			var ty = pointer.y - dragOffset.y;

			if( tx > 0 ) tx = 0 else {
				var m = window.innerWidth - width;
				if( tx < m ) tx = m;
			}
			if( ty > 0 ) ty = 0 else {
				var m = window.innerHeight - height;
				if( ty < m ) ty = m;
			}

			container.setPosition( tx, ty );
			*/

		} else if( draggedLetter != null ) {

			interactive.cursor = Move;

			//var tx = pointer.x - draggedLetterOffset.x - container.x;
			//var ty = pointer.y - draggedLetterOffset.y - container.y;
			var tx = pointer.x/zoom - draggedLetterOffset.x;
			var ty = pointer.y/zoom - draggedLetterOffset.y;
			tx += Math.abs(container.x)/zoom;
			ty += Math.abs(container.y)/zoom;

			if( tx < 0 ) tx = 0 else {
				var m = width - draggedLetter.width;
				if( tx > m ) tx = m;
			}
			if( ty < 0 ) ty = 0 else {
				var m = height - draggedLetter.height;
				if( ty > m ) ty = m;
			}

			draggedLetter.setPosition( tx, ty );

			onDrag( draggedLetter );

		} else {
			interactive.cursor = Default;
		}
	}

	public function render( e : Engine ) {
		for( l in letters ) cast(l,Letter).adjustColor();
		scene.render( e );
	}

	function setViewportX( v = 0.0 ) {
		viewportX = Math.min( Math.max( v, -1 ), 1 );
		container.x = (1-viewportX) * (-width/2 + scene.width/2);
		//container.x = (viewportX) * (-width/2 + scene.width/2);
		//TODO scrollbarH.x = (1-v) * (width/2 + scene.width/2);
	}

	function setViewportY( v = 0.0 ) {
		viewportY = Math.min( Math.max( v, -1 ), 1 );
		container.y = (1-viewportY) * (-height/2 + scene.height/2);
	}

	inline function setViewportPos( vx = 0.0, vy = 0.0 ) {
		setViewportX( vx );
		setViewportY( vx );
	}

	function moveViewportX( v : Float ) {
		setViewportX( viewportX + v );
	}

	function moveViewportY( v : Float ) {
		setViewportY( viewportY + v );
	}

	inline function moveViewportPos( vx : Float, vy : Float ) {
		moveViewportX( vx );
		moveViewportY( vy );
	}

	/*
	function setOffsetX( ?v : Float ) {
		if( v == null ) v = container.x;
		container.x = if( v > 0 ) 0 else {
			var m = - (width  * zoom - window.innerWidth);
			container.x = (v < m) ? m : v;
		}
	}

	function setOffsetY( v : Float ) {
		container.y = if( v > 0 ) 0 else {
			var m = - (height * zoom - window.innerHeight);
			container.y = (v < m) ? m : v;
		}
	}

	inline function setOffset( x : Float, y : Float) {
		setOffsetX( x );
		setOffsetY( y );
	}

	inline function centerOffset() {
		setOffsetX( scene.width/2 - width/2 );
		setOffsetY( scene.height/2 - height/2 );
	}
	*/

	function bringToFront( l : Letter ) : Letter {
		var parent = l.parent;
		l.remove();
		parent.addChild( l );
		return l;
	}

	function onMousePush( e : Event ) {
		//pointer.set( e.relX, e.relY );
		function startDrag() {
			dragOffset = new Point( e.relX - container.x, e.relY - container.y );
			dragged = true;
		}
		if( Key.isDown( Key.SPACE ) ) startDrag() else {
			var l = getLetterAtPointer();
			if( l == null ) startDrag() else {
				draggedLetterOffset.set(
					e.relX/zoom - l.x + Math.abs(container.x/zoom),
					e.relY/zoom - l.y + Math.abs(container.y/zoom) );
				draggedLetter = bringToFront( l.startDrag() );
				onDragStart( draggedLetter );
			}
		}
	}

	function onMouseMove( e : Event ) {
		pointerMove.set( e.relX - pointer.x, e.relY - pointer.y );
		pointer.set( e.relX, e.relY );
	}

	function onMouseRelease( e : Event ) {
		if( dragged ) {
			dragged = false;
		} else if( draggedLetter != null ) {
			draggedLetter.stopDrag();
			onDragStop( draggedLetter );
			draggedLetter = null;
		}
	}

	function onMouseOut( e : Event ) {
		//trace("onMouseOut "+e);
	}

	function onMouseWheel( e : Event ) {
		//trace(e,Key.isDown(Key.CTRL) );
		if( Key.isDown( Key.CTRL ) ) {
			if( e.wheelDelta < 0 ) {
			} else {
			}
			/*
			var zoomMin = Math.max( window.innerWidth / width, window.innerHeight / height );
			if( zoom < zoomMin ) zoom = zoomMin;
			container.scaleX = container.scaleY = zoom;
			setOffsetX( container.x );
			setOffsetY( container.y );
			*/
		} else if( Key.isDown( Key.SHIFT ) ) {
			var v = 0.05;
			if( e.wheelDelta > 0 ) v = -v;
			moveViewportX(  v );
		} else {
			var v = 0.05;
			if( e.wheelDelta > 0 ) v = -v;
			moveViewportY(  v );
		}
	}

	function getLetterAt( p : Point ) : Letter {
		for( l in letters ) if( l.getBounds().contains( p ) ) return cast l;
		return null;
	}

	inline function getLetterAtPointer() return getLetterAt( pointer );

}
