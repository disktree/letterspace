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
	public var width(default,null) : Int;
	public var height(default,null) : Int;

	var bmp : Bitmap;

	public function new( index : Int, char : String, tile : Tile ) {

		//super( tile );
		super();
		this.index = index;
		this.char = char;

		bmp = new Bitmap( tile, this );

		//var shader = new SineDeformShader();
		//shader.speed = 1;
		//shader.amplitude = .1;
		//shader.frequency = .5;
		//shader.texture = bmp.tile.getTexture();
		//bmp.addShader( shader );

		var size = bmp.getSize();
		width = Std.int( size.width );
		height = Std.int( size.height );

		bmp.color = Vector.fromColor( 0xffe0e0e0 );
		bmp.alpha = 0.99;
		//filter = new DropShadow( 2, 0.785, 0x000000, 0.3, 4, 2, 1, true );
		//bmp.filter = new DropShadow( 2, 0.785, 0x000000, 0.3, 4, 2, 1, true );
		//smooth = true;
		//blendMode = Screen;
		//new h2d.Mask(10, 20, bmp );
	//	rgba(224, 224, 224, 1)
	}

	/*
	public function bringToFront() : Letter {
		var _parent = parent;
		remove();
		_parent.addChild( this );
		return this;
	}
	*/

	public function adjustColor() {
		//bmp.color.set(0,0,1,1);
		//bmp.color.set(1,0,0,0.2);
		//trace(bmp.color);
		//hueValue += 0.1;
		//if( hueValue >= 180 ) hueValue = -180;
		//bmp.adjustColor( { hue: hueValue* Math.PI / 180 } );

	}

	public function startDrag() : Letter {
		//setScale( 1.1 );

		//0.8784
		//trace(h3d.Vector.fromColor( 0xffe0e0e0 ));
		//trace(h3d.Vector.fromColor( 0xffe0e0e0 ));
		//trace(h3d.Vector.fromColor( 0xffffffff ));

		//bmp.color.set(0.8784,0.8784,0.8784,1);
		//bmp.color = h3d.Vector.fromColor( 0xffff0000 );
		bmp.alpha = 1;
		bmp.color = h3d.Vector.fromColor( 0xffffffff );

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
		bmp.alpha = 0.99;
		bmp.color = Vector.fromColor( 0xffe0e0e0 );
		//setScale( 1 );
		/*
		filter = null;
		*/
		//var shader = new MyEffect();
		bmp.adjustColor( {hue:0} );
		return this;
	}

	/*
	public static function loadTileset( name : String ) : Map<String,Tile> {
		var chars =
		var tiles = new Map<String,h2d.Tile>();
		for( c in chars ) {
			var t = hxd.Res.load('letter/helvetica/$c.png').toTile();
			//t = t.center();
			tiles.set( c, t );
		}
		return tiles;
	}
	*/

}

/*
private class Tileset {

	public function new() {}
}
*/
