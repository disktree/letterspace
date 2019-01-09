package letterspace.net;

class Mesh extends owl.Mesh {

	#if owl_server

	static var USERCOLOR = [
		0xff0000,
		0xFF6F00,
		0x0D47A1,
		0x006064,
		0xBF360C,
		0x311B92,
		0x1B5E20,
		0x1A237E,
		0x01579B,
	];

	public override function addNode( node : owl.Node, ?info : Dynamic ) : owl.Node {
		//trace("ADD NODE "+Lambda.count(nodes));
		info.color = USERCOLOR[Lambda.count( nodes )];
		for( n in nodes ) {
			var _info = infos.get( n.id );
			if( _info.name == info.name ) {
				var i = 0;
				while( true ) {
					var nname = info.name + i;
					if( _info.name != nname ) {
						info.name = nname;
						break;
					}
					i++;
				}
			}
		}
		return super.addNode( node, info );
	}

	#end
}
