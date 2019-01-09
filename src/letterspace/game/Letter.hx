package letterspace.game;

import h2d.Bitmap;
import h2d.Object;
import h2d.Tile;
import h2d.col.Bounds;
import h2d.filter.*;
import h3d.Vector;

class Letter extends Object {

	public var index(default,null) : Int;
	public var char(default,null) : String;

	public var size(default,null) : Bounds;
	public var width(default,null) : Int;
	public var height(default,null) : Int;

	public var color(get,set) : Int;
	public var outline(default,null) : Outline;

	public var user(default,null) : User;
	public var lastUser(default,null) : User;

	var bmp : Bitmap;
	var colorDefault : Int;

	var shadow : DropShadow;

	public function new( index : Int, char : String, tile : Tile, color : Int ) {

		super();
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

	public function startDrag( user : User ) : Letter {
		this.user = user;
		var v = Vector.fromColor( user.color );
		v.a = 1;
		bmp.color = v;
		bringToFront();
		return this;
	}

	public function stopDrag() : Letter {
		lastUser = user;
		user = null;
		color = colorDefault;
		outline.enable = false;
		return this;
	}

}
