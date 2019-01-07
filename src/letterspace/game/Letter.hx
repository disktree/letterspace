package letterspace.game;

import h2d.Bitmap;
import h2d.Object;
import h2d.Tile;
import h2d.col.Bounds;
import h2d.filter.*;
import h3d.Vector;

//@:build(letterspace.macro.Build.tiles())
class Letter extends Object {

	/*
	public static var TILESET : Map<String,Array<String>> = [
		'clone' => letterspace.macro.Build.getTilesetCharacters('clone'),
		'fff' => letterspace.macro.Build.getTilesetCharacters('fff'),
		'helvetica' => letterspace.macro.Build.getTilesetCharacters('helvetica')
	];
	*/

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

	public function new( index : Int, char : String, tile : Tile, color : Int ) {

		super();
		this.index = index;
		this.char = char;

		bmp = new Bitmap( tile, this );

		size = bmp.getSize();
		width = Std.int( size.width );
		height = Std.int( size.height );

		this.color = color;
		//bmp.alpha = 0.9;
		//alpha = 0.4;

		outline = new Outline( 2, 0xff0000, 0.3, true );
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
		//setScale( 1.1 );
		//color = 0xffffffff;
		//bmp.alpha = 1;
		//this.color = user.color;
		outline.color = user.color;
		outline.enable = true;
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
		//setScale( 1 );
		//color = 0xffe0e0e0;
		//bmp.alpha = 0.9;
		outline.enable = false;
		//bmp.adjustColor( {hue:0} );
		return this;
	}

}
