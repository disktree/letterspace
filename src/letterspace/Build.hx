package letterspace;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using om.Path;
using om.StringTools;

#end

class Build {

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

	static function tiles() : Array<Field> {
		var fields = Context.getBuildFields();
		var mapExpr = new Array<Expr>();
		for( k=>v in tilesetMap ) {
			mapExpr.push( macro $v{k} => $v{v} );
		}
		fields.push({
			name : 'MAP',
			access: [APublic,AStatic],
			kind: FVar( macro:Map<String,Array<String>>, macro $a{mapExpr} ),
			pos: Context.currentPos()
		});
		return fields;
	}

	static var tilesetMap : Map<String,Array<String>> = [];

	static function exportLetterTiles( dpi = 144, force = false ) {

		var tilesets = FileSystem.readDirectory( 'src/tiles' ).filter( f -> {
			return if( f.startsWith('_') || !f.hasExtension('svg') ) false else true;
		}).map( f -> return f.withoutExtension() );

		for( name in tilesets ) {

			var srcFile = 'src/tiles/$name.svg';
			var dstDir = 'res/letter/$name';
			var srcModTime = FileSystem.stat( srcFile ).mtime;

			var characters = new Array<String>();
			tilesetMap.set( name, characters );

			if( !FileSystem.exists( dstDir ) ) FileSystem.createDirectory( dstDir );

			for( k=>v in letterspace.game.Tilemap.CHARACTERS ) {
				var dstFile = '$dstDir/$v.png';
				if( !force && FileSystem.exists( dstFile ) && srcModTime.getTime() < FileSystem.stat( dstFile ).mtime.getTime() ) {
					//trace("NOT CHANGED "+k);
					characters.push(k);
				} else {
					var args = ['--without-gui',srcFile,'--export-png',dstFile,'--export-id=$v','--export-dpi=$dpi'];
					var export = new sys.io.Process( 'inkscape', args );
					var code = export.exitCode();
					switch code {
					case 0:
						characters.push(k);
					default:
						Sys.println( export.stderr.readAll().toString().trim() );
					}
					export.close();
				}
			}
		}
	}

	#end

}
