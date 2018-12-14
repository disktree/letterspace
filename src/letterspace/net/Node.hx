package letterspace.net;

import js.html.rtc.DataChannel;

class Node extends om.rtc.mesh.Node {

    /** Custom channel for letterspace game data */
    public var dataChannel(default,null) : DataChannel;

}
