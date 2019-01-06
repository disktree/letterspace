package letterspace.macro;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import om.color.GimpPalette;
import sys.FileSystem;
import sys.io.File;

using om.Path;
using om.StringTools;

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

	/*
	static function colorPalette( name : String ) {
		var fields = Context.getBuildFields();
		var path = 'src/style/color/$name.gpl';
		trace(path);
		var palette = GimpPalette.parse( File.getContent( path ) );
		for( c in palette.colors ) {
			trace(c);
		}
		return fields;
	}
	*/

	static function exportLetterTiles( name : String, dpi = 96 ) {

		var srcFile = 'src/tiles/$name.svg';
		var srcModTime = FileSystem.stat( srcFile ).mtime;
		var dstDir = 'res/letter/$name';
		var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

		if( !FileSystem.exists( dstDir ) ) FileSystem.createDirectory( dstDir );

		for( c in chars.split('') ) {
			var dstFile = '$dstDir/$c.png';
			if( FileSystem.exists( dstFile ) && srcModTime.getTime() < FileSystem.stat( dstFile ).mtime.getTime() ) {
				//trace("NOT CHHANGED "+c);
			} else {
				var args = ['--without-gui',srcFile,'--export-png',dstFile,'--export-id=$c','--export-dpi=$dpi'];
				var export = new sys.io.Process( 'inkscape', args );
				var code = export.exitCode();
				switch code {
				case 0: //trace( export.stdout.readAll() );
				default: Sys.println( export.stderr.readAll().toString().trim() );
				}
				export.close();
			}
		}
	}

	#end

}
