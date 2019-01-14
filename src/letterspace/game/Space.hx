package letterspace.game;

import h2d.Graphics;
import h2d.Interactive;
import h2d.Object;
import h2d.Tile;
import h2d.col.Point;
import h2d.filter.DropShadow;
import hxd.Event;
import hxd.Key;
import hxd.Res;

typedef TileKey = {
	var c : String;
	var f : String;
}

class Space extends hxd.App {

	var onInit : Space->Void;

	public static function create( level : Level ) : Promise<Space> {
		return new Promise( (resolve,reject) -> {
			new Space( level.width, level.height, space -> {

				var theme = Theme.get( level.theme );

				space.background.render( level.width, level.height, theme.background );

				for( l in level.letters ) {
					var font = (l.font != null) ? l.font : level.letter.font;
					var scale = (l.scale != null) ? l.scale : (level.letter.scale != null) ? level.letter.scale : 1;
					var key = '${l.char}:$font:$scale';
					var tile : Tile, tile_shadow : Tile;
					if( space.tiles.exists( key ) ) {
						//trace("ALREADY HAVE "+key );
						var tiles = space.tiles.get( key );
						tile = tiles[0];
						tile_shadow = tiles[1];
					} else {
						//trace("NEW TILE "+key  );
						var c = Tilemap.get( l.char );
						tile = Res.load( 'letter/$font/$c.png' ).toTile();
						if( scale != 1 ) tile.scaleToSize( Std.int( tile.width*scale ), Std.int( tile.height*scale ) );
						tile_shadow = Res.load( 'letter/$font/shadow/$c.png' ).toTile();
						if( scale != 1 ) tile_shadow.scaleToSize( Std.int( tile_shadow.width*scale ), Std.int( tile_shadow.height*scale ) );
						space.tiles.set( key, [tile,tile_shadow] );
					}
					var num = (l.num != null) ? l.num : (level.letter.num != null) ? level.letter.num : 1;
					for( i in 0...num ) {
						var letter = new Letter( space.letterContainer, space.letters.length, l.char, theme.letter, tile, tile_shadow );
						space.letters.push( letter );
						if( l.pos != null ) letter.setPosition( l.pos[0], l.pos[1] ) else {
							letter.setPosition(
								Std.int( Math.random() * (space.width-letter.width) ),
								Std.int( Math.random() * (space.height-letter.height) )
							);
						}
					}
				}

				/*
				if( theme.letter.shadow != null ) {
					var sh = theme.letter.shadow;
					//var f = new h2d.filter.DropShadow( sh.distance, sh.angle, sh.color, sh.alpha, sh.radius, sh.gain, 1, true );
					//space.letterContainer.filter = f;
				}
				*/

				space.scrollbarH.beginFill( theme.background.grid.color, 0.8 );
				space.scrollbarH.drawRect( 0, 0, 100, 4 );
				space.scrollbarH.endFill();

				space.scrollbarV.beginFill( theme.background.grid.color, 0.8 );
				space.scrollbarV.drawRect( 0, 0, 4, 100 );
				space.scrollbarV.endFill();

				resolve( space );
			});
		});
	}

	public dynamic function onDragStart( l : Letter ) {}
	public dynamic function onDrag( l : Letter ) {}
	public dynamic function onDragStop( l : Letter ) {}

	public dynamic function onUpdate() {}

	public final width : Int;
	public final height : Int;

	public var time(default,null) : Float;
	public var dragged(default,null) = false;
	public var letters(default,null) = new Array<Letter>();

	public var container(default,null) : Object;
	public var background(default,null) : Background;

	var letterContainer : Object;
	var scrollbarH : Graphics;
	var scrollbarV : Graphics;

	var interactive : Interactive;

	var tiles = new Map<String,Array<Tile>>();

	var viewport = new Point();
	var dragOffset = new Point();

	var pointedLetter : Letter;
	var draggedLetter : Letter;
	var draggedLetterOffset = new Point();
	var dragBorderSize = 2;
	var dragBorderFactor = 0.1;

	var wheelScrollSpeed = 0.075;

	function new( width : Int, height : Int, onInit : Space->Void ) {
		super();
		this.width = width;
		this.height = height;
		this.onInit = onInit;
	}

	override function init() {

		container = new Object( s2d );

		background = new Background( container );

		scrollbarH = new Graphics( s2d );
		scrollbarV = new Graphics( s2d );

		#if dev
		var centerDings = new Graphics( container );
		centerDings.beginFill( 0x0000ff, 0.3 );
		centerDings.drawRect( width/2-1, 0, 2, height );
		centerDings.endFill();
		centerDings.beginFill( 0x0000ff, 0.3 );
		centerDings.drawRect( 0, height/2-1, width, 2 );
		centerDings.endFill();
		#end

		letterContainer = new Object( container );

		interactive = new h2d.Interactive( width, height, s2d );
		interactive.cursor = Default;
		interactive.onPush = onMousePush;
		interactive.onMove = onMouseMove;
		interactive.onRelease = onMouseRelease;
		interactive.onWheel = onMouseWheel;
		interactive.onFocusLost = onBlur;
		//interactive.onOut = e -> trace(e);
		//interactive.onFocusLost = e -> trace(e);

		var win = hxd.Window.getInstance();
		win.addEventTarget( onEvent );
		/*
		win.addResizeEvent( function(){
			s2d.checkResize();
			@:privateAccess hxd.Window.getInstance().checkResize(); //HACK
		});
		*/

		window.onresize = function(){

			s2d.checkResize();
			@:privateAccess hxd.Window.getInstance().checkResize(); //HACK
			//@:privateAccess container.posChanged = true

			scrollbarH.scaleX = Math.max( window.innerWidth / width, 0.2 );
			scrollbarV.scaleY = Math.max( window.innerHeight / height, 0.2 );
			setViewportPos( viewport.x, viewport.y );
		}

		onInit( this );
	}

	public function start() {
		scrollbarH.scaleX = Math.max( window.innerWidth / width, 0.2 );
		scrollbarV.scaleY = Math.max( window.innerHeight / height, 0.2 );
		setViewportPos();
		time = 0;
	}

	/*
	public override inline function render( e : h3d.Engine ) {
		if( !App.hidden ) super.render(e);
	}
	*/

	public function setViewportX( v : Float ) {
		viewport.x = Math.min( Math.max( v, -1 ), 1 );
		var w = window.innerWidth;
		container.x = Std.int( (1+viewport.x) * ((w-width)/2) );
		scrollbarH.x = Std.int( (viewport.x/2 + 0.5) * (w-(100*scrollbarH.scaleX)) );
	}

	public function setViewportY( v : Float ) {
		viewport.y = Math.min( Math.max( v, -1 ), 1 );
		var h = window.innerHeight;
		container.y = Std.int( (1+viewport.y) * ((h-height)/2) );
		scrollbarV.y = Std.int( (viewport.y/2 + 0.5) * (h-(100*scrollbarV.scaleY)) );
	}

	public inline function setViewportPos( x = 0.0, y = 0.0 ) {
		setViewportX( x );
		setViewportY( y );
	}

	public inline function moveViewportX( v : Float )
		setViewportX( viewport.x + v );

	public inline function moveViewportY( v : Float )
		setViewportY( viewport.y + v );

	public inline function moveViewport( x : Float, y : Float ) {
		moveViewportX( x );
		moveViewportY( y );
	}

	public function getLetterAt( p : Point ) : Letter {
		var i = letterContainer.numChildren;
		while( i > 0 ) {
			var l = @:privateAccess letterContainer.children[--i];
			if( l.getBounds().contains( p ) ) return cast l;
		}
		return null;
	}

	public inline function getLetterAtPointer() : Letter
		return getLetterAt( new Point( s2d.mouseX, s2d.mouseY ) );

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

	public override function dispose() {
		super.dispose();
		var win = hxd.Window.getInstance();
		win.removeEventTarget( onEvent );
		//engine.end();
		//engine.dispose();
		//engine = null;
	}

	override function update( dt : Float ) {

		time += dt;

		if( dragged ) {

			var tx = s2d.mouseX - dragOffset.x;
			var vx = -(tx/((width-window.innerWidth)/2) + 1);
			setViewportX( vx );

			var ty = s2d.mouseY - dragOffset.y;
			var vy = -(ty/((height-window.innerHeight)/2) + 1);
			setViewportY( vy );

		} else if( draggedLetter != null ) {

			var tx = s2d.mouseX - draggedLetterOffset.x - container.x;
			if( tx < 0 ) tx = 0 else {
				var m = width - draggedLetter.width;
				if( tx > m ) tx = m;
			};
			var ty = s2d.mouseY - draggedLetterOffset.y - container.y;
			if( ty < 0 ) ty = 0 else {
				var m = height - draggedLetter.height;
				if( ty > m ) ty = m;
			};

			draggedLetter.setPosition( tx, ty );

			onDrag( draggedLetter );

			var sx = getScreenX( tx );
			var sy = getScreenY( ty );
			if( sx < dragBorderSize ) {
				if( container.x < 0 ) {
					var d = dragBorderSize - sx;
					var v = d * dragBorderFactor;
					var p = v / s2d.width;
					moveViewportX( -p );
				}
			} else {
				var sr = sx + draggedLetter.width;
				if( sr > s2d.width - dragBorderSize ) {
					if( container.x + width > s2d.width ) {
						var d = dragBorderSize - (s2d.width-sr);
						var v = d * dragBorderFactor;
						var p = v/s2d.width;
						moveViewportX( p );
					}
				}
			}
			if( sy < dragBorderSize ) {
				if( container.y < 0 ) {
					var d = dragBorderSize - sy;
					var v = d * dragBorderFactor;
					var p = v/s2d.height;
					moveViewportY( -p );
				}
			} else {
				var sb = sy + draggedLetter.height;
				if( sb > s2d.height - dragBorderSize ) {
					if( container.y + height > s2d.height ) {
						var d = dragBorderSize - (s2d.height-sb);
						var v = d * dragBorderFactor;
						var p = v/s2d.height;
						moveViewportY( p );
					}
				}
			}
		}

		onUpdate();
	}

	inline function getScreenX( v : Float ) : Float
		return v - Math.abs( container.x );

	inline function getScreenY( v : Float ) : Float
		return v - Math.abs( container.y );

	function onEvent( e : Event ) {
		switch e.kind {
		case EKeyDown:
			switch e.keyCode {
			case Key.LEFT: moveViewportX(-width/(width*1000)*10);
			case Key.RIGHT: moveViewportX(width/(width*1000)*10);
			case Key.UP: moveViewportY(-height/(height*1000)*10);
			case Key.DOWN: moveViewportY(height/(height*1000)*10);
			case Key.C: if( draggedLetter == null ) setViewportPos();
			case Key.PGUP: setViewportY(-1);
			case Key.PGDOWN: setViewportY(1);
			case Key.HOME: setViewportPos();
			case Key.END: //TODO exit
			default:
			}
		default:
		}
	}

	function onMousePush( e : Event ) {
		var l = getLetterAtPointer();
		//if( pointedLetter == null || Key.isDown( Key.SPACE ) ) {
		if( l == null || Key.isDown( Key.SPACE ) ) {
			dragged = true;
			dragOffset.set( e.relX - container.x, e.relY - container.y );
			interactive.cursor = Move;
		} else {
			draggedLetter = l;
			pointedLetter = null;
			draggedLetterOffset.set( s2d.mouseX - draggedLetter.x - container.x, s2d.mouseY - draggedLetter.y - container.y );
			onDragStart( draggedLetter );
		}
	}

	function onMouseMove( e : Event ) {
		//pointer.set( e.relX, e.relY );
		if( !dragged && draggedLetter == null ) {
			if( pointedLetter != null ) {
				//pointedLetter.color =
				pointedLetter.outline.enable = false;
			}
			var l = getLetterAtPointer();
			if( l != null ) {
				pointedLetter = l;
				pointedLetter.outline.enable = true;
			}
		}
	}

	function onMouseRelease( e : Event ) {
		if( dragged ) {
			dragged = false;
			dragOffset.set( 0, 0 );
			interactive.cursor = Default;
		} else if( draggedLetter != null ) {
			draggedLetter.stopDrag();
			onDragStop( draggedLetter );
			draggedLetter = null;
		}
	}

	function onMouseWheel( e : Event ) {
		if( Key.isDown( Key.CTRL ) ) {
			//TODO zoom
		} else if( Key.isDown( Key.SHIFT ) ) {
			moveViewportX( (e.wheelDelta > 0) ? wheelScrollSpeed : -wheelScrollSpeed );
		} else {
			moveViewportY( (e.wheelDelta > 0) ? wheelScrollSpeed : -wheelScrollSpeed );
		}
	}

	function onBlur( e : Event ) {
		if( pointedLetter != null ) {
			pointedLetter.outline.enable = false;
			pointedLetter = null;
		}
	}
}
