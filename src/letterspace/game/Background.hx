package letterspace.game;

import h2d.Graphics;
import h2d.Object;
import h2d.Tile;
import hxd.BitmapData;

typedef Grid = {
	var dx : Int;
	var dy : Int;
	var color : Int;
}

/*
typedef Params = {
	var background : Int;
	var grid : Grid;
}
*/

class Background extends Graphics {

	public function new( parent : Object, width : Int, height : Int, color : Int, grid : Grid ) {

		super( parent );

		var bmp = new BitmapData( grid.dx, grid.dy );
		bmp.fill( 0, 0, grid.dx, grid.dy, color );
		bmp.line( 0, 0, grid.dx, 0, grid.color );
		bmp.line( 0, 0, 0, grid.dy, grid.color );

		var tile = Tile.fromBitmap( bmp );
		var nx = Std.int( width/grid.dx );
		var ny = Std.int( height/grid.dy );
		for( ix in 0...nx ) {
			for( iy in 0...ny ) {
				beginTileFill( ix*tile.width, iy*tile.height, 1, 1, tile );
        		drawRect( ix*tile.width, iy*tile.height, tile.width, tile.height );
			}
		}

		/*
		var grid = new Bitmap( Tile.fromColor( 0x0000ff, 600, 600 ), container );
		var gridShader = new h2d.shader.GridShader(0xff00ff00);
		grid.addShader( gridShader );
		*/
	}
}
