package letterspace.net;

class Node extends owl.Node {

	public var user(default,null) : String;

	public function new( id : String, user : String ) {
		super( id );
		this.user = user;
	}
}
