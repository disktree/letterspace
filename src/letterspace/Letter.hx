package letterspace;

import hxd.Res;
import h2d.Object;
import h2d.Tile;
import om.Tween;
import om.ease.*;

class Letter extends h2d.Object {

	public dynamic function onDragStart( l : Letter ) {}

	public var index(default,null) : Int;
	public var char(default,null) : String;

	public var width(default,null) : Int;
	public var height(default,null) : Int;

	public var dragged(default,null)  = false;

	var dragOffsetX : Float;
	var dragOffsetY : Float;

	var moveTween : Tween;

	public function new( index : Int, char : String, parent : Object ) {

		super( parent );
		this.index = index;
		this.char = char;

		var tile : Tile = Res.load('letter/$char.png').toTile();
		var bmp = new h2d.Bitmap( tile, this );

		alpha = 0.8;

		var bounds = getBounds();
		width = Std.int( bounds.xMax );
		height = Std.int( bounds.yMax );

		var interaction = new h2d.Interactive( width, height, this );
		interaction.onOver = function(e:hxd.Event) {
			alpha = 1;
		}
		interaction.onOut = function(e:hxd.Event) {
		    alpha = 0.7;
		}
		//interaction.onClick = function(e:hxd.Event) {
		interaction.onPush  = function(e:hxd.Event) {
			dragOffsetX = e.relX;
			dragOffsetY = e.relY;
			dragged = true;
			onDragStart( this );
		}
		/*
		interaction.onRelease = function(e:hxd.Event) {
			dragged = false;
		}
		*/

		moveTween = new Tween( this )
			.onUpdate( function(){
				posChanged = true;
			});
	}

	public function update() {
		//if( dragged ) {
		var tx = Game.mouseX - dragOffsetX;
		if( tx < 0 ) tx = 0;
		else if( tx > Game.W - width ) tx = Game.W - width;
		var ty = Game.mouseY - dragOffsetY;
		if( ty < 0 ) ty = 0;
		else if( ty > Game.H - height ) ty = Game.H - height;
		x = tx;
		y = ty;
	}

	public function stopDrag() {
		dragged = false;
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

}
