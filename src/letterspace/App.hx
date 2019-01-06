package letterspace;

import letterspace.Server;
import letterspace.app.Activity;

class App  {

	//public static var isMobile(default,null) = om.System.isMobile();
	public static var storage(default,null) : Storage;
	public static var server(default,null) : Server;

	static function main() {

		console.info( 'LETTERSPACE' );

		var host = '192.168.0.10';
		var port = 1377;

		var params = new js.html.URLSearchParams( window.location.search );
		if( params.has( 'host' ) ) host = params.get( 'host' );
		if( params.has( 'port' ) ) port = Std.parseInt( params.get( 'port' ) );

		storage = new Storage( 'letterspace_' );
		server = new Server( host, port );

		hxd.Res.initEmbed( { compressSounds: true } );

		Activity.boot( new letterspace.app.BootActivity() );

		/*
		//var svg_src = hxd.Res.loader.load( 'letter/fff_plain.svg' ).entry.getText();
		var svg_src = hxd.Res.loader.load( 'letter/test.svg' ).entry.getText();
		//trace(svg_src);
		//document.body.innerHTML = svg_src;

		//var image = new js.html.Image();
  		//image.src = 'data:image/svg+xml;base64,' + window.btoa(svg_src);
		//document.body.innerHTML = '';
		//document.body.appendChild(image);

		var parser = new js.html.DOMParser();
		var doc = parser.parseFromString( svg_src, IMAGE_SVG_XML );
		var A_path = doc.getElementById( 'helvetica_A' );
		trace(A_path);

		var svg_n = document.createElementNS("http://www.w3.org/2000/svg","svg");
		//svg_n.setAttribute('width', '600');
		//svg_n.setAttribute('height', '600');
		svg_n.setAttribute('viewBox', "0 0 100 100");
		svg_n.appendChild( A_path );
		//document.body.appendChild(svg_n);

		var xml  = new js.html.XMLSerializer().serializeToString(svg_n);

		var image = new js.html.Image();
		image.src = 'data:image/svg+xml;base64,' + window.btoa(xml);
		//image.src = 'data:image/svg+xml;base64,' + window.btoa(svg_n);
		//document.body.appendChild(image);

		//trace(doc.querySelector( 'g' ));
		//trace(doc.getElementById( 'helvetica_A' ));
		//trace(doc.getElementById( 'fff_A' ));

		//var parser = new js.html.DOMParser();
		//var doc = parser.parseFromString( svg_src, IMAGE_SVG_XML );
		//trace(doc);
		*/
	}
}
