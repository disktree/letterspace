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

class Space implements h3d.IDrawable {

	public dynamic function onDragStart( l : Letter ) {}
	public dynamic function onDrag( l : Letter ) {}
	public dynamic function onDragStop( l : Letter ) {}

	public var width(default,null) : Int;
	public var height(default,null) : Int;

	public var letters(default,null) = new Array<Letter>();

	public var time(default,null) : Float;

	public var zoomAble = true;

	final engine : Engine;

	var scene : Scene;
	var events : hxd.SceneEvents;
	var loop : Loop;

	var user : User;
	var tiles : Map<String,Tile>;

	var container : Object;
	var background : Background;
	var letterContainer : Object;
	var scrollbarH : Graphics;
	var scrollbarV : Graphics;

	var interactive : Interactive;

	var viewportX = 0.0;
	var viewportY = 0.0;

	var zoom = 1.0;
	var zoomMin = 0.5;
	var zoomMax = 1.5;

	var pointer = new Point();
	var pointerMove = new Point();

	var dragged = false;
	var dragOffset = new Point();
	var dragThrowFactor = 1.0;
	var dragThrowTween : Tween;

	var draggedLetter : Letter;
	var draggedLetterOffset = new Point();

	var dragBorderSize = 50;
	var dragBorderFactor = 0.1;

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

	public function init( level : Level, user : User ) {

		this.width = level.width;
		this.height = level.height;
		this.user = user;

		//var canvas = document.getElementById( 'webgl' );
		//canvas.style.filter = 'grayscale(100%)';

		scene = new Scene();

		container = new Object( scene );

		background = new Background( container, width, height, level.background, { dx : 20, dy : 20, color: 0xff1070E0 } );

		letterContainer = new Object( container );
		letterContainer.filter = new DropShadow( 2, 0.785, 0x000000, 0.3, 6, 2, 1, true );

		tiles = new Map();
		for( c in level.chars ) {
			if( !tiles.exists( c ) ) {
				var t = Res.load( 'letter/'+level.font+'/$c.png' ).toTile();
				//t.scaleToSize( Std.int( t.width/4 ), Std.int( t.height/4 ) ); //TODO scale param
				tiles.set( c, t );
			}
		}
		var i = 0;
		for( c in level.chars ) {
			var l = new Letter( i, c, tiles.get(c) );
			letters.push( l );
			letterContainer.addChild( l );
			i++;
		}

		scrollbarH = new Graphics( scene );
		scrollbarH.beginFill( 0xffffff, 0.8 );
		//scrollbarH.drawRect( 0, 0, window.innerWidth*(window.innerWidth/width), 10 );
		scrollbarH.drawRect( 0, 0, 100, 4 );
		scrollbarH.endFill();

		scrollbarV = new Graphics( scene );
		scrollbarV.beginFill( 0xffffff, 0.8 );
		scrollbarV.drawRect( 0, 0, 4, 100 );
		scrollbarV.endFill();
		
		/*
		var centerDings = new Graphics( container );
		centerDings.beginFill( 0x0000ff, 0.6 );
		centerDings.drawRect( width/2-1, 0, 2, height );
		centerDings.endFill();
		centerDings.beginFill( 0xff0000, 0.6 );
		centerDings.drawRect( 0, height/2-1, width, 2 );
		centerDings.endFill();
		*/

		events = new hxd.SceneEvents();
		events.addScene( scene );

		/*
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
		*/
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

		dragThrowTween = new Tween( container ).easing( Exponential.Out )
			.onUpdate( () -> @:privateAccess container.posChanged = true );

		interactive = new Interactive( width, height, scene );
		interactive.cursor = Default;
		interactive.onPush = onMousePush;
		interactive.onMove = onMouseMove;
		interactive.onRelease = onMouseRelease;
		interactive.onOut = onMouseOut;
		interactive.onWheel = onMouseWheel;
		interactive.onKeyDown = function(e){
			switch e.keyCode {
			case Key.LEFT: moveViewportX(0.01);
			case Key.RIGHT: moveViewportX(-0.01);
			case Key.UP: moveViewportY(0.01);
			case Key.DOWN: moveViewportY(-0.01);
			case Key.C: if( draggedLetter == null ) setViewportPos();
			case Key.Z: setZoom(1);
			}
		}

		Key.initialize();

		time = 0;
		loop = new Loop( 60,
			function(dt) {
				events.checkEvents();
				update( dt );
				scene.setElapsedTime(dt);
			},
			function(dt) {
				var _delta = dt * 1000;
				time += _delta;
				//time = Time.now();
				//trace(time,_delta);
				Timer.step( time*1000 );
				Tween.step( _delta );
				render( engine );
			}
		).start();


		window.onresize = onWindowResize;
		onWindowResize();

		//scene.setFixedSize( this.width, this.height );
		//var canvas : CanvasElement = cast document.getElementById( 'webgl' );
		//canvas.width = this.width;
		//canvas.height = this.height;

		setViewportPos();
	}

	public inline function iterator()
		return letters.iterator();

	public function render( e : Engine ) {
		scene.render( e );
		//monitor.end();
	}

	public function setViewportX( v = 0.0 ) {
		viewportX = Math.min( Math.max( v, -1 ), 1 );
		container.x = (1+viewportX) * ((-width*zoom/2 + scene.width/2));
		scrollbarH.x = (viewportX/2 + 0.5) * ((scene.width-100));
	}

	public function setViewportY( v = 0.0 ) {
		viewportY = Math.min( Math.max( v, -1 ), 1 );
		container.y = (1+viewportY) * (-height*zoom/2 + scene.height/2);
		scrollbarV.y = (viewportY/2 + 0.5) * (scene.height-100);
	}

	public inline function setViewportPos( vx = 0.0, vy = 0.0 ) {
		setViewportX( vx );
		setViewportY( vy );
	}

	public inline function moveViewportX( v : Float )
		setViewportX( viewportX + v );

	public inline function moveViewportY( v : Float )
		setViewportY( viewportY + v );

	public inline function moveViewportPos( vx : Float, vy : Float ) {
		moveViewportX( vx );
		moveViewportY( vy );
	}

	public function setZoom( v : Float ) {
		//TODO
	//	if( zoomAble ) {
			v = Math.min( Math.max( v, zoomMin ), zoomMax );
			zoom = v;
			container.scaleX = container.scaleY = zoom;
		//	setViewportPos( viewportX, viewportY );
	//	}
	}

	public inline function zoomIn( amount : Float )
		setZoom( zoom + amount );

	public inline function zoomOut( amount : Float )
		setZoom( zoom - amount );

	public function getLetterAt( p : Point ) : Letter {
		for( l in letters ) if( l.getBounds().contains( p ) ) return cast l;
		return null;
	}

	public inline function getLetterAtPointer() : Letter
		return getLetterAt( pointer );

	public function bringToFront( l : Letter ) : Letter {
		var parent = l.parent;
		l.remove();
		parent.addChild( l );
		return l;
	}

	public function searchWord( letter : Letter, kx = 0.2, ky = 0.2 ) : Array<Letter> {
		//TODO
		var dx = letter.width * kx;
		var dy = letter.height * ky;
		dx = Math.max( Math.min( dx, 20 ), 10 );
		dy = Math.max( Math.min( dy, 20 ), 10 );
		var matched = [for(l in letters) if(l != letter && Math.abs(l.y - letter.y) < dy) l];
		if( matched.length == 0 )
			return matched;
		function searchLeft( letter : Letter, found : Array<Letter> ) {
			var i = 0;
			while( i < matched.length ) {
				var l = matched[i];
				if( l.x < letter.x ) {
					if( l.x + l.width + dx > letter.x && letter.x > l.x + l.width - dx ) {
						found.unshift( l );
						matched.splice( i, 1 );
						searchLeft( l, found );
						break;
					}
				}
				i++;
			}
			return found;
		}
		function searchRight( letter : Letter, found : Array<Letter> ) {
			var i = 0;
			while( i < matched.length ) {
				var l = matched[i];
				if( l.x > letter.x ) {
					if( l.x - letter.width - dx < letter.x && letter.x + letter.width < l.x + dx ) {
						found.push( l );
						matched.splice( i, 1 );
						searchRight( l, found );
						break;
					}
				}
				i++;
			}
			return found;
		}
		var matchedLeft = searchLeft( letter, [] );
		var matchedRight = searchRight( letter, [] );
		if( matchedLeft.length == 0 && matchedRight.length == 0 )
			return [];
		var word = new Array<Letter>();
		word = word.concat( matchedLeft );
		word.push( letter );
		word = word.concat( matchedRight );
		return word;
	}

	function update( dt : Float ) {

		pointerMove.set( scene.mouseX - pointer.x, scene.mouseY - pointer.y );
		pointer.set( scene.mouseX, scene.mouseY );

		if( dragged ) {

			interactive.cursor = Move;

			var tx = pointer.x - dragOffset.x;
			var ty = pointer.y - dragOffset.y;
			var vx = ((tx /  (width*zoom/2 - scene.width/2)) + 1) * -1;
			var vy = ((ty /  (height*zoom/2 - scene.height/2)) + 1) * -1;
			//trace(vx,vy);
			//setViewportPos( vx, vy );
			setViewportX( vx );
			setViewportY( vy );

		} else if( draggedLetter != null ) {

			interactive.cursor = Move;

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

			var sx = getScreenX( tx );
			var sy = getScreenY( ty );

			if( sx < dragBorderSize ) {
				if( container.x < 0 ) {
					var d = dragBorderSize - sx;
					var v = d * dragBorderFactor;
					var p = v / scene.width;
					moveViewportX( -p );
				}
			} else {
				var sr = sx + draggedLetter.width;
				if( sr > scene.width - dragBorderSize ) {
					if( container.x + width > scene.width ) {
						var d = dragBorderSize - (scene.width-sr);
						var v = d * dragBorderFactor;
						var p = v/scene.width;
						moveViewportX( p );
					}
				}
			}

			if( sy < dragBorderSize ) {
				if( container.y < 0 ) {
					var d = dragBorderSize - sy;
					var v = d * dragBorderFactor;
					var p = v/scene.height;
					moveViewportY( -p );
				}
			} else {
				var sb = sy + draggedLetter.height;
				if( sb > scene.height - dragBorderSize ) {
					if( container.y + height > scene.height ) {
						var d = dragBorderSize - (scene.height-sb);
						var v = d * dragBorderFactor;
						var p = v/scene.height;
						moveViewportY( p );
					}
				}
			}

		} else {
			interactive.cursor = Default;
		}
	}

	inline function getScreenX( v : Float ) : Float
		return v - Math.abs( container.x / zoom );

	inline function getScreenY( v : Float ) : Float
		return v - Math.abs( container.y / zoom );

	function onWindowResize() {
		//zoomMin = Math.max( scene.width / width, scene.height / height );
		//zoomMin = Math.max( window.innerWidth / width, window.innerHeight / height );
		//setZoom( zoom );
	}

	function onMousePush( e : Event ) {
		//pointerMove.set(0,0);
		//pointer.set( e.relX, e.relY );
		function startDrag() {
			//dragOffset = new Point( e.relX - container.x, e.relY - container.y );
			dragOffset.set( e.relX - container.x, e.relY - container.y );
			dragged = true;
		}
		if( Key.isDown( Key.SPACE ) ) startDrag() else {
			var l = getLetterAtPointer();
			if( l == null ) startDrag() else {
				if( l.user == null ) {
					draggedLetterOffset.set(
						e.relX/zoom - l.x + Math.abs(container.x/zoom),
						e.relY/zoom - l.y + Math.abs(container.y/zoom) );
					draggedLetter = bringToFront( l.startDrag( user ) );
					onDragStart( draggedLetter );
				}
			}
		}
	}

	function onMouseMove( e : Event ) {
		//pointerMove.set( e.relX - pointer.x, e.relY - pointer.y );
		//pointer.set( e.relX, e.relY );
	}

	function onMouseRelease( e : Event ) {
		if( dragged ) {
			dragged = false;
			dragOffset.set( 0, 0 );
			/*
			var tx = Std.int( Math.max( Math.min( container.x + pointerMove.x * dragThrowFactor * 10, 0 ), scene.width- width ) );
			var ty = Std.int( Math.max( Math.min( container.y + pointerMove.y * dragThrowFactor * 10, 0 ), scene.height - height ) );
			var ax = Math.abs( pointerMove.x );
			var ay = Math.abs( pointerMove.y );
			var duration = ((ax > ay) ? ax : ay) * dragThrowFactor * 100;
			dragThrowTween.stop().to( { x : tx, y : ty  }, duration ).start();
			*/
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
		if( Key.isDown( Key.CTRL ) ) {
			(e.wheelDelta < 0) ? zoomIn( 0.01 ) : zoomOut( 0.01 );
		} else if( Key.isDown( Key.SHIFT ) ) {
			var v = 0.05;
			if( e.wheelDelta < 0 ) v = -v;
			moveViewportX(  v );
		} else {
			var v = 0.05;
			if( e.wheelDelta < 0 ) v = -v;
			moveViewportY(  v );
		}
	}
}
