package letterspace.net;

class Mesh extends om.rtc.mesh.Mesh<Node> {

    override function createNode( id : String ) : Node  {
        var node = new letterspace.net.Node( id );
        return node;
    }
}
