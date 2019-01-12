package letterspace.game;

import h2d.Bitmap;
import h2d.Interactive;
import h2d.Object;
import h2d.Tile;
import h2d.col.Bounds;
import h2d.filter.*;
import h3d.Vector;
import hxd.Key;

class Letter extends Object {

	public dynamic function onDragStart( l : Letter ) {}
	public dynamic function onDragStop( l : Letter ) {}

	public var index(default,null) : Int;
	public var char(default,null) : String;

	public var size(default,null) : Bounds;
	public var width(default,null) : Int;
	public var height(default,null) : Int;

	public var color(get,set) : Int;
	public var outline(default,null) : Outline;

	public var user(default,null) : Node;
	public var lastUser(default,null) : Node;

	var bmp : Bitmap;
	var colorDefault : Int;
	var interactive : Interactive;

	var shadow : DropShadow;

	public function new( parent, index : Int, char : String, tile : Tile, color : Int ) {

		super( parent );
		this.index = index;
		this.char = char;

		bmp = new Bitmap( tile, this );

		size = bmp.getSize();
		width = Std.int( size.width );
		height = Std.int( size.height );

		this.color = color;
		this.colorDefault = color;

		outline = new Outline( 1, 0x000000, 0.1, true );
		outline.enable = false;
		bmp.filter = outline;

		shadow = new h2d.filter.DropShadow( 4, 0.785, 0x000000, 0.3, 6, 2, 1, true );
		shadow.enable = false;
		filter = shadow;

		/*
		var scene = getScene();
		var dragged = false;
		*/

		interactive = new Interactive( width, height, this );
		interactive.onPush = function(e) {
			if( !Key.isDown( Key.SPACE ) ) {
				//outline.enable = true;
				//bringToFront();
				if( user == null ) {
					interactive.cursor = Move;
					onDragStart( this );
				}
			}
		}
		interactive.onRelease = function(e) {
			//this.color = colorDefault;
			interactive.cursor = Default;
			onDragStop( this );
		}
	}

	inline function get_color() return bmp.color.toColor();
	inline function set_color(v) {
		bmp.color = Vector.fromColor( v );
		return v;
	}

	public function bringToFront() : Letter {
		var _parent = parent;
		remove();
		_parent.addChild( this );
		return this;
	}

	public function startDrag( user : Node ) : Letter {
		this.user = user;
		//scale(1.05);
		var v = Vector.fromColor( user.color );
		v.a = 1;
		bmp.color = v;
		bringToFront();
		//outline.enable = true;
		//shadow.enable = true;
		return this;
	}

	public function stopDrag() : Letter {
		lastUser = user;
		user = null;
		//scale(1);
		color = colorDefault;
		//outline.enable = false;
		//shadow.enable = false;
		return this;
	}

}
