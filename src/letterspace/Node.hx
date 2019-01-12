package letterspace;

class Node extends owl.Node {

	#if owl_client

	public final name : String;
	public final color : Int;

	public function new( id : String, creds : Dynamic ) {
		super( id, creds );
		this.name = creds.name;
		this.color = creds.color;
	}

	#end
}
