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

		var srcDir = 'src/tiles';
		var dstDir = 'res/letter';

		var tilesets = FileSystem.readDirectory( srcDir ).filter( f -> {
			return !f.startsWith('_') && f.hasExtension('svg') && !f.withoutExtension().endsWith('-shadow');
		}).map( f -> return f.withoutExtension() );

		function export( svg : String, png : String, id : String ) : Bool {

			if( !force && FileSystem.exists( png ) && FileSystem.stat( svg ).mtime.getTime() < FileSystem.stat( png ).mtime.getTime() ) {
				//trace("NOT CHANGED "+id);
				return true;
			}

			var args = ['--without-gui',svg,'--export-png',png,'--export-id=$id','--export-dpi=$dpi'];
			var inkscape = new sys.io.Process( 'inkscape', args );
			var code = inkscape.exitCode();
			inkscape.close();
			return code == 0;
		}

		for( name in tilesets ) {

			var svg = '$srcDir/$name.svg';
			//var svgModTime = FileSystem.stat( svg ).mtime;
			var dir = '$dstDir/$name';
			if( !FileSystem.exists( dir ) ) FileSystem.createDirectory( dir );

			var svg_shadow = '$srcDir/$name-shadow.svg';
			//var hasShadow = FileSystem.exists( svg_shadow );
			var dir_shadow = '$dstDir/$name/shadow';
			if( !FileSystem.exists( dir_shadow ) ) FileSystem.createDirectory( dir_shadow );

			var characters = new Array<String>();
			tilesetMap.set( name, characters );

			for( k=>v in letterspace.game.Tilemap.CHARACTERS ) {
				if( !export( svg, '$dir/$v.png', v ) )
					throw 'failed to export $name:$k';
				if( !export( svg_shadow, '$dir_shadow/$v.png', v ) )
					throw 'failed to export shadow $name:$k';
				characters.push( k );

				/*
				if( hasShadow ) {
					if( !export( svg_shadow, '$dir_shadow/$v.png', v ) )
						throw 'failed to export shadow $name:$k';
				}
				*/

				/*
				var png = '$dir/$v.png';
				if( !force && FileSystem.exists( png ) && svgModTime.getTime() < FileSystem.stat( png ).mtime.getTime() ) {
					//trace("NOT CHANGED "+k);
					characters.push( k );
					continue;
				}
				*/

				/*
				if( export( svg, '$dir/$v.png', v ) ) {

					//characters.push( k );
					//var srcFileShadow = 'src/tiles/$name-shadow.svg';

					if( hasShadow ) {
						var png_shadow = '$dir/shadow/$v.png';
						export( svg_shadow, png_shadow, v, dpi )
					}


				} else {
					throw 'failed to export $name:$k';
					//Sys.println( 'failed to export $name:$k' );
					//return;
				}

				if( hasShadow ) {
					//var png_shadow = '$dir/shadow/$v.png';
					//trace(svg_shadow, png_shadow);
					//export( svg_shadow, png_shadow, v, dpi )
				}
				*/


				/*
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
				*/
			}
		}
	}

	#end

}
