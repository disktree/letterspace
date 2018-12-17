package letterspace.game;

import h2d.Graphics;
import h2d.Interactive;
import h2d.Object;
import h2d.Tile;
import h2d.col.Point;
import hxd.Event;
import hxd.Res;

class Space extends Object {

	public dynamic function onDragStart( l : Letter ) {}
	public dynamic function onDrag( l : Letter ) {}
	public dynamic function onDragStop( l : Letter ) {}

	public var width(default,null) : Int;
    public var height(default,null) : Int;

	var background : Background;
	var letterContainer : Object;
	var interaction : Interactive;
	var tiles : Map<String,Tile>;
	var letters : Array<Letter>;

	var draggedLetter : Letter;

	public function new( parent, width : Int, height : Int ) {

		super( parent );
		this.width = width;
        this.height = height;

		background = new Background( this, width, height, 0x3f3f3f, { color: 0x303030, size: 10 } );

		letterContainer = new Object( this );
		//letterContainer.filter = new h2d.filter.Bloom(2,1,10);
		//letterContainer.filter = new h2d.filter.DropShadow();

		tiles = new Map<String,Tile>();
		var chars = letterspace.macro.Build.getLetters();
		for( c in chars ) {
			tiles.set( c, Res.load('letter/$c.png').toTile() );
		}

		letters = [];
		var i = 0;
		for( c in tiles.keys() ) {
			var l = new Letter( i, c, tiles.get( c ) );
			letterContainer.addChild( l );
			letters.push( l );
			i++;
		}

		for( l in letters ) {
			l.setPosition(
				Math.random() * (width-l.size.xMax),
				Math.random() * (height-l.size.yMax)
			);
		}

		interaction = new h2d.Interactive( width, height, this );
		interaction.onPush = onMousePush;
		interaction.onMove = onMouseMove;
		interaction.onRelease = onMouseRelease;
	}

	public function update( time : Float ) {
	}

	public inline function getLetter( i : Int ) : Letter {
		return letters[i];
	}

	public function getLetterPositions() : Array<Array<Int>> {
		return [for(l in letters)[Std.int(l.x),Std.int(l.y)]];
	}

	public function setLetterPositions( positions : Array<Array<Int>> ) {
		for( i in 0...letters.length ) {
			var p = positions[i];
			var l = letters[i];
			l.setPosition( p[0], p[1] );
		}
	}

	public inline function setLetterPosition( i : Int, x : Int, y : Int ) {
		letters[i].setPosition( x, y );
	}

	function getLetterAt( p : Point ) : Letter {
		for( l in letters ) if( l.getBounds().contains( p ) ) return l;
		return null;
	}

	function bringToFront( l : Letter ) {
		l.remove();
		letterContainer.addChild( l );
	}

	function onMousePush( e : Event ) {
		var p = new Point( e.relX, e.relY );
		var l = getLetterAt( p );
		if( l != null ) {
			bringToFront( l );
			l.startDrag( p );
			draggedLetter = l;
			onDragStart( l );
		}
	}

	function onMouseMove( e : Event ) {
		if( draggedLetter != null ) {
			var p = new Point( e.relX, e.relY );
			draggedLetter.doDrag( p );
			onDrag( draggedLetter );
		}
	}

	function onMouseRelease( e : Event ) {
		if( draggedLetter != null ) {
			var p = new Point( e.relX, e.relY );
			draggedLetter.stopDrag( p );
			onDragStop( draggedLetter );
			draggedLetter = null;
		}
	}

}
