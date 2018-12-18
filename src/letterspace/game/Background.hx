package letterspace.game;

import h2d.Graphics;
import h2d.Object;

typedef Style = {
    color : Int,
	grid : {
		color : Int,
		size : Int
		//?thick : Int,
		//?alpha : Float,
	}
}

class Background extends Graphics {


	public function new( parent, width : Int, height : Int, style : Style ) {

		super( parent );

		beginFill( style.color );
		drawRect( 0, 0, width, height );
		endFill();

		var nx = Std.int( width/style.grid.size );
		var ny = Std.int( height/style.grid.size );
		var px = 0;
		var py = 0;

		this.lineStyle( 1, style.grid.color, 1.0 );

		for( i in 0...ny ) {
			moveTo( 0, py );
			lineTo( width, py );
			py += style.grid.size;
		}
		for( i in 0...nx ) {
			moveTo( px, 0 );
			lineTo( px, height );
			px += style.grid.size;
		}
	}
}

/*
class Background extends Graphics {

	public function new( parent, width : Int, height : Int, color : Int, gridStyle : GridStyle ) {

		super( parent );

		beginFill( color );
		drawRect( 0, 0, width, height );
		endFill();

		this.

		var nx = Std.int( width/gridStyle.size );
		var ny = Std.int( height/gridStyle.size );
		var px = 0;
		var py = 0;

		this.lineStyle( 1, gridStyle.color, 1.0 );

		for( i in 0...ny ) {
			moveTo( 0, py );
			lineTo( width, py );
			py += gridStyle.size;
		}
		for( i in 0...nx ) {
			moveTo( px, 0 );
			lineTo( px, height );
			px += gridStyle.size;
		}
	}
}
*/
