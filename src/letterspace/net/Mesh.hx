package letterspace.net;

class Mesh extends owl.Mesh {

	#if owl_server

	public override function addNode( node : owl.Node, ?info : Dynamic ) : owl.Node {
		for( n in nodes ) {
			var _info = infos.get( n.id );
			if( _info.user == info.user ) {
				var i = 0;
				while( true ) {
					var newUser = info.user + i;
					if( _info.user != newUser ) {
						info.user = newUser;
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
