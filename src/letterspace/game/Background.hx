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

//class Background extends Object {
class Background extends Graphics {

	public function new( parent : Object, width : Int, height : Int, theme : letterspace.game.Level.BackgroundTheme ) {

		super( parent );

		beginFill( theme.color );
		drawRect( 0, 0, width, height );
		endFill();

		var gradient_sx = Std.int( width/3 );
		var gradient_sy = Std.int( height/3 );
		var gradient_ca = theme.gradient.color;
		var gradient_cb_v = Vector.fromColor( theme.gradient.color );
		gradient_cb_v.w = 0;
		var gradient_cb = gradient_cb_v.toColor();

		function addGradientBitmap( w : Int, h : Int, dir : Int, x = 0, y = 0 ) {
			var bmp = new Bitmap( Tile.fromColor( 0, w, h ), this );
			bmp.setPosition( x, y );
			bmp.addShader( new LinearGradientShader( dir, gradient_ca, gradient_cb ) );
		}

		addGradientBitmap( width, gradient_sy, 0 );
		addGradientBitmap( gradient_sx, height, 1, width - gradient_sx );
		addGradientBitmap( width, gradient_sy, 2, 0, height - gradient_sy );
		addGradientBitmap( gradient_sx, height, 3 );

		//var gradient_t = new Bitmap( Tile.fromColor( 0, width, gradient_sy ), this );
		//gradient_t.addShader( new LinearGradientShader( 0, gradient_ca, gradient_cb ) );
		//new Bitmap( Tile.fromColor( 0, width, gradient_sy ), this ).addShader( new LinearGradientShader( 0, gradient_ca, gradient_cb ) );

		/*
		var gradient_r = new Bitmap( Tile.fromColor( 0, gradient_sx, height ), this );
		gradient_r.x = width - gradient_sx;
		var shader = new LinearGradientShader( 1, gradient_ca, gradient_cb );
		gradient_r.addShader( shader );

		var gradient_b = new Bitmap( Tile.fromColor( 0, width, gradient_sy ), this );
		gradient_b.y = height - gradient_sy;
		var shader = new LinearGradientShader( 2, gradient_ca, gradient_cb );
		gradient_b.addShader( shader );

		var gradient_l = new Bitmap( Tile.fromColor( 0, gradient_sx, height ), this );
		var shader = new LinearGradientShader( 3, gradient_ca, gradient_cb );
		gradient_l.addShader( shader );
		*/

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


		/*
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
		*/

		//var i = 0;
		//var r = (i + 1) & 1;
		//var g = ((i + 1) >> 1) & 1;
		//var b = (i + 1) >> 2;
		//trace(r,g,b);

		/*
		var gradient = new hxd.BitmapData( 600, 1 );
		for( i in 0...gradient.width ) {
			var c = gradient.width/100 * i;
			//gradient.setPixel( i, 0, 0xFF000000 | ((i << 16) * r) | ((i << 8) * g) | (((i) >> 1) * b) );
			gradient.setPixel( i, 0, Std.int(0xFF00ff00) );
		}
		var tile = Tile.fromBitmap( gradient );
		var ny = Std.int( height );
		for( iy in 0...ny ) {
			beginTileFill( 0, iy*tile.height, 1, 1, tile );
			drawRect( 0, iy*tile.height, tile.width, tile.height );
		}
		*/

		/*
		var nx = Std.int( width / theme.grid.size );
		var ny = Std.int( height / theme.grid.size );
		for( ix in 0...nx ) {
			for( iy in 0...ny ) {
				beginTileFill( ix*tile.width, iy*tile.height, 1, 1, tile );
				drawRect( ix*tile.width, iy*tile.height, tile.width, tile.height );
			}
		}
		*/


		/*
		var bmp = new Bitmap( Tile.fromColor( 0x0000ff, 600, height ), this );
		var shader = new h2d.shader.LinearGradientShader( 0xff00ff00, 0x33ffffff );
		bmp.addShader( shader );
		*/


		/*
		var grid = new Bitmap( Tile.fromColor( 0x0000ff, 600, 600 ), container );
		var gridShader = new h2d.shader.GridShader(0xff00ff00);
		grid.addShader( gridShader );
		*/
	}
}
