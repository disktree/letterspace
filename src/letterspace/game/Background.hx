package letterspace.game;

import h2d.Graphics;
import h2d.Object;
import h2d.Tile;
import hxd.BitmapData;

class Background extends Graphics {

	public function new( parent : Object, width : Int, height : Int, theme : letterspace.game.Level.BackgroundTheme ) {

		super( parent );

		var bmp = new BitmapData( theme.grid.size, theme.grid.size );
		bmp.fill( 0, 0, theme.grid.size, theme.grid.size, theme.color );
		bmp.line( 0, 0, theme.grid.size, 0, theme.grid.color );
		bmp.line( 0, 0, 0, theme.grid.size, theme.grid.color );

		var tile = Tile.fromBitmap( bmp );
		var nx = Std.int( width / theme.grid.size );
		var ny = Std.int( height / theme.grid.size );
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
