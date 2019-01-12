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
					var scale = (l.scale != null) ? l.scale : level.letter.scale;
					//var key = { c : l.char, f : font };
					//trace(key,space.tiles.exists( key ));
					var tile : Tile;
					if( space.tiles.exists( l.char ) ) {
					//if( space.tiles.exists( key ) ) {
						//trace("ALREADY HAVE "+l.char );
						tile = space.tiles.get( l.char );
					} else {
						var c = Tilemap.get( l.char );
						tile = Res.load( 'letter/$font/$c.png' ).toTile();
						tile.scaleToSize( Std.int( tile.width*scale ), Std.int( tile.height*scale ) );
						space.tiles.set( l.char, tile );
						//space.tiles.set( key, tile ); 
					}
					var letter = new Letter( space.letterContainer, space.letters.length, l.char, tile, theme.letter.color );
					letter.onDragStart = space.onDragLetterStart;
					letter.onDragStop = space.onDragLetterStop;
					space.letters.push( letter );
				}

				if( theme.letter.shadow != null ) {
					var sh = theme.letter.shadow;
					var f = new h2d.filter.DropShadow( sh.distance, sh.angle, sh.color, sh.alpha, sh.radius, sh.gain, 1, true );
					//space.letterContainer.filter = f;
				}

				space.scrollbarH.beginFill( theme.background.grid.color, 1.0 );
				space.scrollbarH.drawRect( 0, 0, 100, 4 );
				space.scrollbarH.endFill();

				space.scrollbarV.beginFill( theme.background.grid.color, 1.0 );
				space.scrollbarV.drawRect( 0, 0, 4, 100 );
				space.scrollbarV.endFill();

				resolve( space );
			});
		});
	}

	public dynamic function onDragStart( l : Letter ) {}
	public dynamic function onDrag( l : Letter ) {}
	public dynamic function onDragStop( l : Letter ) {}

	public final width : Int;
	public final height : Int;

	public var time(default,null) : Float;
	public var dragged(default,null) = false;
	public var letters(default,null) = new Array<Letter>();

	var container : Object;
	var background : Background;
	var letterContainer : Object;
	var scrollbarH : Graphics;
	var scrollbarV : Graphics;

	var interactive : Interactive;

	var tiles = new Map<String,Tile>();

	var viewport = new Point();
	var dragOffset = new Point();

	var draggedLetter : Letter;
	var draggedLetterOffset = new Point();
	var dragBorderSize = 30;
	var dragBorderFactor = 0.3;

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

		interactive = new h2d.Interactive( width, height, background );
		interactive.cursor = Default;
		interactive.onPush = onMousePush;
		interactive.onMove = onMouseMove;
		interactive.onRelease = onMouseRelease;
		interactive.onWheel = onMouseWheel;

		var win = hxd.Window.getInstance();
		win.addEventTarget( onEvent );
		/*
		win.addResizeEvent( function(){
			trace("rr");
		});
		*/

		window.onresize = function(){
			s2d.checkResize();
			@:privateAccess hxd.Window.getInstance().checkResize(); //HACK
			if( width < s2d.width ) {
				container.x = (s2d.width - width) / 2;
			}
			if( height < s2d.height ) {
				container.y = (s2d.height - height) / 2;
			}
		}

		/*
		if( width < s2d.width ) {
			container.x = (s2d.width - width) / 2;
		}
		if( height < s2d.height ) {
			container.y = (s2d.height - height) / 2;
		}
		*/

		/*
		var sw = window.innerWidth / width;
		var sh = window.innerHeight / height;
		trace(sw,sh);
		if( sw > 1 || sh > 1 ) {
			var s = Math.max( sw, sh );
			trace(s);
			container.scaleX = container.scaleY = s;
		}
		*/

		//setViewportPos();

		onInit( this );
	}

	public function start() {
		time = 0;
	}

	/*
	public override inline function render( e : h3d.Engine ) {
		if( !App.hidden ) super.render(e);
		//super.render(e);
	}
	*/

	public function setViewportX( v : Float ) {
		viewport.x = Math.min( Math.max( v, -1 ), 1 );
		container.x = Std.int( (1+viewport.x) * ((-width/2 + s2d.width/2)) );
		scrollbarH.x = Std.int( (viewport.x/2 + 0.5) * ((s2d.width-100)) );
	}

	public function setViewportY( v : Float ) {
		viewport.y = Math.min( Math.max( v, -1 ), 1 );
		container.y = Std.int( (1+viewport.y) * (-height/2 + s2d.height/2) );
		scrollbarV.y = Std.int( (viewport.y/2 + 0.5) * (s2d.height-100) );
	}

	public inline function setViewportPos( x = 0.0, y = 0.0 ) {
		setViewportX( x );
		setViewportY( y );
	}

	public inline function moveViewportX( v : Float )
		setViewportX( viewport.x + v );

	public inline function moveViewportY( v : Float )
		setViewportY( viewport.y + v );

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

	/*
	public override function dispose() {
		super.dispose();
		var win = hxd.Window.getInstance();
		win.removeEventTarget( onEvent );
		//engine.end();
		//engine.dispose();
		//engine = null;
	}
	*/

	override function update( dt : Float ) {

		if( dragged ) {
			/*
			if( s2d.width < width ) {
				var tx = hxd.Math.clamp( s2d.mouseX - dragOffset.x, - width + s2d.width, 0 );
				container.x = tx;
			}
			if( s2d.height < height ) {
				var ty = hxd.Math.clamp( s2d.mouseY - dragOffset.y, - height + s2d.height, 0 );
				container.y = ty;
			}
			*/
			var tx = s2d.mouseX - dragOffset.x;
			var vx = -(tx/((width-s2d.width)/2) + 1);
			setViewportX( vx );

			var ty = s2d.mouseY - dragOffset.y;
			var vy = -(ty/((height-s2d.height)/2) + 1);
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
		dragged = true;
		dragOffset.set( e.relX, e.relY );
		interactive.cursor = Move;
		/*
		interactive.startDrag( function(e){
			//trace(e);
			//container.x = e.relX - dragOffsetX;
			//container.y = e.relY - dragOffsetY;
		} );
		*/
	}

	function onMouseMove( e : Event ) {
		if( dragged ) {
			//trace( e );
			//container.x = e.relX - background.x - dragOffsetX;
			//container.y = e.relY - background.y - dragOffsetY;
		}
	}

	function onMouseRelease( e : Event ) {
		dragged = false;
		interactive.cursor = Default;
		//interactive.stopDrag();
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

	function onDragLetterStart( l : Letter ) {
		draggedLetter = l;
		draggedLetterOffset.set( s2d.mouseX - l.x - container.x, s2d.mouseY - l.y - container.y );
		onDragStart( l );
	}

	function onDragLetterStop( l : Letter ) {
		draggedLetter = null;
		onDragStop( l );
	}
}
