package letterspace.game;

import h2d.Graphics;

private typedef GridStyle = {
    color : Int,
    ?size : Int,
    ?thick : Int,
    ?alpha : Float,
}

class Background extends Graphics {

	public function new( parent, width : Int, height : Int, color : Int, gridStyle : GridStyle ) {

		super( parent );

		beginFill( color );
		drawRect( 0, 0, width, height );
		endFill();

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
