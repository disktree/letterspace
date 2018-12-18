package letterspace.game;

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
	public var dragged(default,null) = false;

	var dragOffset : Point;
	//var dragOffsetX : Float;
	//var dragOffsetY : Float;
	//var moveTween : Tween;

	public function new( index : Int, char : String, tile : Tile ) {
		super( tile );
		this.index = index;
		this.char = char;
		size = getSize();
		//this.filter = new h2d.filter.Bloom(2,1,10);
		//this.filter = new h2d.filter.Glow();
		//this.filter = new h2d.filter.Outline(2);
		this.filter = new h2d.filter.DropShadow( 2, 0.785, 0, 0.3, 10, 2, 1, true );

		/*
		moveTween = new Tween( this )
			.onUpdate( function(){
				posChanged = true;
			});
			*/
	}

	public function update() {
		/*
		//if( dragged ) {
		var tx = Game.mouseX - dragOffsetX;
		if( tx < 0 ) tx = 0;
		else if( tx > Game.W - width ) tx = Game.W - width;
		var ty = Game.mouseY - dragOffsetY;
		if( ty < 0 ) ty = 0;
		else if( ty > Game.H - height ) ty = Game.H - height;
		x = tx;
		y = ty;
		*/
	}

	public function startDrag( p : Point ) {
		//this.adjustColor( {} );
		dragOffset = p.sub( new Point( x, y ) );
		//this.setScale( 1.05 );
		//this.filter = new h2d.filter.Glow();
		//this.filter = new h2d.filter.DropShadow( 4, 0.785, 0, 0.3, 48, 2, 1, true );
	}

	public function doDrag( p : Point ) {
		var pos = p.sub( dragOffset );
		setPosition( pos.x, pos.y );
		//setPosition( p.x, p.y );
	}

	public function stopDrag( p : Point ) {
		//dragged = false;
		var pos = p.sub( dragOffset );
		setPosition( pos.x, pos.y );
	//	setPosition( p.x, p.y );
		dragOffset = null;
		//this.filter = null ;
	//	this.setScale( 1.0 );
		//this.filter = new h2d.filter.DropShadow( 2, 0.785, 0, 0.3, 10, 2, 1, true );
	}

	/*
	public function stopDrag() {
		//dragged = false;
	}

	public function movePositions( positions : Array<Array<Int>> ) {
        moveTween.stop().easing( Linear.None );
        var i = 0;
        function startNextTween() {
            if( i < positions.length ) {
                var pos = positions[i];
                var duration = getDistanceTo( pos[0], pos[1] );
                if( duration < 33 ) duration = 33;
                else if( duration > 200 ) duration = 200;
                moveTween.to( { x: pos[0], y:pos[1] }, duration ).start();
                i++;
            } else {
                moveTween.clearAllHandlers();
            }
        }
        moveTween.onComplete( startNextTween );
        startNextTween();
    }
	public function moveTo( tx : Int, ty : Int, ?easing : Float->Float, minDuration = 33, maxDuration = 200 ) : Tween {
		return moveTween.stop()
			.to( { x: tx, y: ty }, hxd.Math.clamp( getDistanceTo( tx, ty ), minDuration, maxDuration ) )
			.easing( (easing==null) ? Linear.None : easing )
			.start();
	}

	function getDistanceTo( x : Int, y : Int ) : Float {
        var a = this.x - x;
        var b = this.y - y;
        return Math.sqrt( a*a + b*b );
    }
	*/

}
