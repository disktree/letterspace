package letterspace.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;

using om.Path;

#end

class Build {

	/*
	macro public static function getLetterTileset( dir : String ) : ExprOf<Array<String>> {
		var a = new Array<String>();
		for( f in FileSystem.readDirectory( 'res/$dir' ) ) {
			if( f.extension() == 'png' )
				a.push( f.withoutExtension() );
		}
		a.sort( function(a,b) return (a>b)?1:(a<b)?-1:0 );
		return macro $v{a};
	}
	*/

	macro public static function getLetterChars( dir : String ) : ExprOf<Array<String>> {
		var a = new Array<String>();
		for( f in FileSystem.readDirectory( 'res/$dir' ) ) {
			if( f.extension() == 'png' )
				a.push( f.withoutExtension() );
		}
		a.sort( function(a,b) return (a>b)?1:(a<b)?-1:0 );
		return macro $v{a};
	}

	macro public static function getTilesetCharacters( name : String ) : ExprOf<Array<String>> {
		var a = new Array<String>();
		for( f in FileSystem.readDirectory( 'res/letter/$name' ) ) {
			if( f.extension() == 'png' )
				a.push( f.withoutExtension() );
		}
		a.sort( function(a,b) return (a>b)?1:(a<b)?-1:0 );
		return macro $v{a};
	}

	#if macro
	/*

	static function tiles() : Array<Field> {
		var fields = Context.getBuildFields();
		return fields;
	}

	*/

	/*
	static function exportTilesets( srcDir : String, dstDir : String ) {
		var path = 'src/tiles';
		for( f in FileSystem.readDirectory( path ) ) {
			if( f.extension() == 'svg' ) {

				 //inkscape --without-gui letters.svg --export-png A.png --export-id=A
				 //inkscape src/tiles/fff.svg --without-gui --export-id=NOPE --export-png=NOPE.png
				//trace(f);
			}
		}
	}
	*/
	#end

}
