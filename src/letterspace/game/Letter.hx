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

	var letter : Bitmap;
	var shadow : Bitmap;

	var colorDefault : Int;

	public function new( parent, index : Int, char : String, theme : Theme.Letter, tile : Tile, tile_shadow : Tile ) {

		super( parent );
		this.index = index;
		this.char = char;

		shadow = new Bitmap( tile_shadow, this );
		shadow.smooth = true;
		shadow.alpha = 0.8;

		//var letter_bg = new Bitmap( tile, this );
		//letter_bg.smooth = true;

		letter = new Bitmap( tile, this );
		letter.smooth = true;

		//var bright = -5;
		//letter.adjustColor({ lightness : bright / 100 });

		size = letter.getSize();
		width = Std.int( size.width );
		height = Std.int( size.height );

		var shadow_size = shadow.getSize();
		shadow.x -= (shadow_size.width - size.width) / 2;
		shadow.y -= (shadow_size.height - size.height) / 2;

		this.color = theme.color;
		this.colorDefault = color;

		outline = new Outline( theme.outline.thick, theme.outline.color, 0.3, true );
		outline.enable = false;
		filter = outline;

		//shadow = new h2d.filter.DropShadow( 4, 0.785, 0x000000, 0.3, 6, 2, 1, true );
		//shadow.enable = false;
		//filter = shadow;
	}

	inline function get_color() return letter.color.toColor();
	inline function set_color(v) {
		letter.color = Vector.fromColor( v );
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
		letter.color = v;
		bringToFront();
		outline.enable = false;
		//shadow.enable = true;
		shadow.alpha = 1;
		return this;
	}

	public function stopDrag() : Letter {
		lastUser = user;
		user = null;
		//scale(1);
		color = colorDefault;
		outline.enable = false;
		//shadow.enable = false;
		shadow.alpha = 0.8;
		return this;
	}

}
