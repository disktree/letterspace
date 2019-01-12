package letterspace.game;

import h2d.Graphics;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import h3d.Vector;
import hxd.BitmapData;

private class LinearGradientShader extends hxsl.Shader {

	static var SRC = {

		@:import h3d.shader.Base2d;

		@param var dir : Int;
		@param var colorA : Vec4;
		@param var colorB : Vec4;

		function fragment() {
			if( dir == 0 ) {
				pixelColor = mix( colorA, colorB, input.uv.y );
			} else if( dir == 1 ) {
				pixelColor = mix( colorB, colorA, input.uv.x );
			} else if( dir == 2 ) {
				pixelColor = mix( colorB, colorA, input.uv.y );
			} else if( dir == 3 ) {
				pixelColor = mix( colorA, colorB, input.uv.x );
			}
		}
	}

	public function new( dir : Int, colorA : Int, colorB : Int ) {
		super();
		this.dir = dir;
		this.colorA.setColor( colorA );
		this.colorB.setColor( colorB );
	}
}

class Background extends Object {

	var bg : Graphics;

	public function new( parent : Object ) {
		super( parent );
		bg = new Graphics( this );
	}

	public function render( width : Int, height  : Int, theme : Theme.Background ) {

		bg.beginFill( theme.color );
		bg.drawRect( 0, 0, width, height );
		bg.endFill();

		// ---

		var dx = 10;
		var dy = 10;
		var sx = theme.grid.size * dx;
		var sy = theme.grid.size * dy;
		var bmp = new BitmapData( sx, sy );

		//bmp.fill( 0, 0, sx, sy, theme.color  );

		bmp.fill( 0, 0, 2, sy, theme.grid.color  );
		bmp.fill( sy-2, 0, 2, sy, theme.grid.color  );
		for( i in 0...dx ) {
			var p = i * theme.grid.size;
			bmp.line( p, 0, p, sy, theme.grid.color );
		}

		bmp.fill( 0, 0, sx, 2, theme.grid.color  );
		bmp.fill( 0, sx-2, sx, 2, theme.grid.color  );
		for( i in 0...dy ) {
			var p = i * theme.grid.size;
			bmp.line( 0, p, sx, p, theme.grid.color );
		}

		var tile = Tile.fromBitmap( bmp );
		var grid = new Graphics( this );
		for( ix in 0...Std.int( width / sx ) ) {
			for( iy in 0...Std.int( height / sy ) ) {
				grid.beginTileFill( ix*tile.width, iy*tile.height, 1, 1, tile );
        		grid.drawRect( ix*tile.width, iy*tile.height, tile.width, tile.height );
			}
		}

		/*
		var dx = 10;
		var dy = 10;
		var sx = theme.grid.size * dx;
		var sy = theme.grid.size * dy;
		var bmp = new BitmapData( sx, sy );
		//bmp.fill( 0, 0, sx, sy, theme.color );
		for( i in 0...dx+1 ) {
			var p = i * theme.grid.size;
			bmp.line( p, 0, p, sy, theme.grid.color );
			if( i == 0 )
				bmp.line( p+1, 0, p+1, sy, theme.grid.color );
			else if( i == dx )
				bmp.line( p-1, 0, p-1, sy, theme.grid.color );
		}
		for( i in 0...dy+1 ) {
			var p = i * theme.grid.size;
			bmp.line( 0, p, sx, p, theme.grid.color );
			if( i == 0 )
				bmp.line( 0, p+1, sy, p+1, theme.grid.color );
			else if( i == dx )
				bmp.line( 0, p-1, sy, p-1, theme.grid.color );
		}
		var tile = Tile.fromBitmap( bmp );
		var grid = new Graphics( this );
		for( ix in 0...Std.int( width / sx ) ) {
			for( iy in 0...Std.int( height / sy ) ) {
				grid.beginTileFill( ix*tile.width, iy*tile.height, 1, 1, tile );
        		grid.drawRect( ix*tile.width, iy*tile.height, tile.width, tile.height );
			}
		}
		*/

		// ---

		var sx = Std.int( Math.min( width/3, 512 ) );
		var sy = Std.int( Math.min( height/3, 512 ) );
		var ca = theme.gradient.color;
		var cb_v = Vector.fromColor( theme.gradient.color );
		cb_v.w = 0;
		var gradient_cb = cb_v.toColor();

		function addGradientBitmap( w : Int, h : Int, dir : Int, x = 0, y = 0 ) {
			var bmp = new Bitmap( Tile.fromColor( 0, w, h ), this );
			bmp.setPosition( x, y );
			bmp.addShader( new LinearGradientShader( dir, ca, gradient_cb ) );
		}

		addGradientBitmap( width, sy, 0 );
		addGradientBitmap( sx, height, 1, width - sx );
		addGradientBitmap( width, sy, 2, 0, height - sy );
		addGradientBitmap( sx, height, 3 );

		/*
		var grid = new Graphics( this );
		var bmp = new BitmapData( theme.grid.size, theme.grid.size );
	//	bmp.fill( 0, 0, theme.grid.size, theme.grid.size, theme.color );
		bmp.line( 0, 0, theme.grid.size, 0, theme.grid.color );
		bmp.line( 0, 0, 0, theme.grid.size, theme.grid.color );

		var tile = Tile.fromBitmap( bmp );
		var nx = Std.int( width / theme.grid.size );
		var ny = Std.int( height / theme.grid.size );
		for( ix in 0...nx ) {
			for( iy in 0...ny ) {
				grid.beginTileFill( ix*tile.width, iy*tile.height, 1, 1, tile );
        		grid.drawRect( ix*tile.width, iy*tile.height, tile.width, tile.height );
			}
		}
		*/

		//var interactive = new h2d.Interactive( width, height, this );
		//interactive.onPush = e -> trace(e);
	}
}
