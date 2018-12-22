package letterspace;

import h2d.Bitmap;
import h2d.Object;
import h2d.Tile;
import h2d.col.Bounds;
import h2d.col.Point;
import om.Tween;
import om.ease.*;

//class Letter extends Object {
class Letter extends Bitmap {

	public var index(default,null) : Int;
	public var char(default,null) : String;
	public var size(default,null) : Bounds;

	public function new( index : Int, char : String, tile : Tile ) {
		super( tile );
		this.index = index;
		this.char = char;
		size = getSize();
		//this.cursor;
		//this.filter = new h2d.filter.DropShadow( 2, 0.785, 0, 0.3, 10, 2, 1, true );
		//filter = new h2d.filter.DropShadow( 2, 0.785, 0x000000, 0.3, 4, 2, 1, true );
	}

	public function bringToFront() : Letter {
		var _parent = parent;
		remove();
		_parent.addChild( this );
		return this;
	}

	public function startDrag() {
		bringToFront();
		this.setScale( 1.05 );
		//this.filter = new h2d.filter.Outline( 2, 0x000000, 0.4, true );
		this.filter = new h2d.filter.DropShadow( 6, 0.785, 0x000000, 0.3, 20, 2, 1, true );
		this.adjustColor( { hue: 90 * Math.PI / 180 } );
		//filter = new h2d.filter.Glow( 0xFFFFFF, 100, 5 );
		//filter = new h2d.filter.Bloom(6,1,12);
		//this.filter = new h2d.filter.Glow();
	}

	public function stopDrag() {
		this.setScale( 1 );
		this.filter = null;
		this.adjustColor( {hue:0} );
	}

}
