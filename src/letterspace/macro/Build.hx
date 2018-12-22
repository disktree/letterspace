package letterspace.macro;

#if macro
import sys.FileSystem;
using om.Path;
#end

class Build {

	macro public static function getLetterChars( dir : String ) : ExprOf<Array<String>> {
		var a = new Array<String>();
		for( f in FileSystem.readDirectory( 'res/$dir' ) ) {
			if( f.extension() == 'png' )
				a.push( f.withoutExtension() );
		}
		a.sort( function(a,b) return (a>b)?1:(a<b)?-1:0 );
		return macro $v{a};
	}
}
