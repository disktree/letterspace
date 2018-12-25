package letterspace.game;

import h2d.Bitmap;
import h2d.Tile;
import h2d.col.Bounds;
import h2d.filter.*;

class Letter extends Bitmap {

	public var index(default,null) : Int;
	public var char(default,null) : String;
	public var width(default,null) : Int;
	public var height(default,null) : Int;

	public function new( index : Int, char : String, tile : Tile ) {
		super( tile );
		this.index = index;
		this.char = char;
		var size = getSize();
		width = Std.int( size.width );
		height = Std.int( size.height );
	}

	public function bringToFront() : Letter {
		var _parent = parent;
		remove();
		_parent.addChild( this );
		return this;
	}

	public function startDrag() : Letter {
		bringToFront();
		setScale( 1.05 );
		filter = new DropShadow( 6, 0.785, 0x000000, 0.3, 20, 2, 1, true );
		//filter = new h2d.filter.Outline( 2, 0x000000, 0.4, true );
		//filter = new h2d.filter.Glow( 0xFFFFFF, 100, 5 );
		//filter = new h2d.filter.Bloom(6,1,12);
		adjustColor( { hue: 90 * Math.PI / 180 } );
		return this;
	}

	public function stopDrag() : Letter {
		setScale( 1 );
		filter = null;
		adjustColor( {hue:0} );
		return this;
	}

}
