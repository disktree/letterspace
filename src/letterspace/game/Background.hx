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

		var gradient_sx = Std.int( Math.min( width/3, 512 ) );
		var gradient_sy = Std.int( Math.min( height/3, 512 ) );
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

		//var interactive = new h2d.Interactive( width, height, this );
		//interactive.onPush = e -> trace(e);
	}

	/*
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
	}
	*/
}
