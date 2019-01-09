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
		//bmp.alpha = 0.9;
		//alpha = 0.4;

		outline = new Outline( 1, 0x000000, 0.1, true );
		//outline.autoBounds = false;
		outline.enable = false;
		//outline.smooth = false;
		//this.filter = outline;
		bmp.filter = outline;
		//this.filter = outline;

		//shadow = new DropShadow( 4, 0.785, 0x000000, 0.3, 10, 2.0, 1, true );
		//shadow.enable = false;
		//this.filter = shadow;

		//var group = new h2d.filter.Group([outline,shadow]);
		//group.enable = false;
		//bmp.filter = group;

		//var interactive = new h2d.Interactive( this.width, this.height, this );
		//interactive.onPush = function(e) trace(e);
		//interactive.onOver = function(e) trace(e);
		//interactive.onClick = function(e) trace(e);
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

	/*
	public function adjustColor() {
		//bmp.color.set(0,0,1,1);
		//bmp.color.set(1,0,0,0.2);
		//trace(bmp.color);
		//hueValue += 0.1;
		//if( hueValue >= 180 ) hueValue = -180;
		//bmp.adjustColor( { hue: hueValue* Math.PI / 180 } );
	}
	*/

	public function startDrag( user : User ) : Letter {
		this.user = user;
		//bmp.setScale( 1.2 );
		//color = 0xffffffff;
		//bmp.alpha = 1;
		//trace(user.color);
		var v = Vector.fromColor( user.color );
		v.a = 1;
		bmp.color = v;

		//color = user.color;
		//outline.color = user.color;
		//outline.enable = true;
		//shadow.enable = true;
		bringToFront();

		/*
		bringToFront();
		filter = new DropShadow( 6, 0.785, 0x000000, 0.3, 20, 2, 1, true );
		//filter = new h2d.filter.Outline( 2, 0x000000, 0.4, true );
		//filter = new h2d.filter.Glow( 0xFFFFFF, 100, 5 );
		//filter = new h2d.filter.Bloom(6,1,12);
		*/
		//trace(colorMatrix);
		//bmp.adjustColor( { hue: 90 * Math.PI / 180 } );
		//trace(colorMatrix);
		return this;
	}

	public function stopDrag() : Letter {
		lastUser = user;
		user = null;
		//bmp.setScale( 1 );
		color = colorDefault;
		//bmp.alpha = 0.9;
		outline.enable = false;
		//shadow.enable = false;
		//bmp.adjustColor( {hue:0} );
		return this;
	}

}
