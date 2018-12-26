package letterspace;

//import letterspace.game.Game;
//import letterspace.net.Mesh;
//import letterspace.net.Server;
import letterspace.Server;

class App  {

	static final HOST = '192.168.0.10';
	//static final HOST = '195.201.41.121';
	static final PORT = 1377;
	static final MESH = 'letterspace';

	static var storage : Storage;
	static var server : Server;
	//static var game : Game;

	public static function saveState() {
		window.fetch( 'http://$HOST:$PORT/letterspace' );
	}

	@:keep
	@:expose("login")
	static function _login() {
		var form = cast document.querySelector( 'form.login' );
		var input : InputElement = untyped form.elements.item(0);
		var user : String = input.value;
		if( user.length > 0 ) {

			form.remove();
			input.disabled = true;
			storage.set( 'user', user );

			doLogin( user );

		} else {
			input.value = 'Invalid';
		}
		return false;
	}

	static function doLogin( user : String ) {

		server = new Server( HOST, PORT );
		server.connect().then( function(s){

			console.info( 'SERVER CONNECTED '+server.id );

			server.onDisconnect = function(){
				console.warn( 'SERVER DISCONNECTED' );
				//..
			}

			server.join( 'letterspace', { user : user } ).then( function(mesh:Mesh){

				console.info('MESH JOINED '+mesh.numNodes );
				for( n in mesh ) trace(n);

				var game = new letterspace.game.Game( mesh, user, { width: 6000, height: 6000 } );

				window.onbeforeunload = function(e) {
					//App.saveState();
					return null;
				}
			});

		}).catchError( function(e){
			trace(e);
			//input.classList.add( 'error' );
			//input.value = 'SERVER OFFLINE';
		});
	}

	static function main() {

		console.info( 'LETTERSPACE' );

		if( !navigator.onLine ) {
			console.warn( 'NOT ONLINE' );
			return;
		}

		storage = new Storage( 'letterspace_' );

		var form = cast document.querySelector( 'form.login' );
		var input : InputElement = form.elements.item(0);
		input.value = storage.get( 'user' );
		input.focus();
		//form.remove();

		hxd.Res.initEmbed();

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

		/*
		letterspace.game.Space.create( function(space){

			trace( 'SPACE READY' );
			//trace( letterspace.game.Letter.TILESET );
			//trace( hxd.Res. );

			//Letter.TILESET.get('helvetica');
			//letterspace.game.Letter.loadTileset('helvetica');

			//var LETTER_TILESETS = letterspace.macro.Build.getLetterTilesets();
			//trace(LETTER_TILESETS);

			//var tilesets = LEtter.
			//var chars = letterspace.macro.Build.getLetterChars( 'helvetica' );
			var chars = letterspace.macro.Build.getTilesetCharacters( 'helvetica' );
			//var chars = letterspace.game.Letter.tileset.get( 'helvetica' );
			//trace(chars);

			var tiles = new Map<String,h2d.Tile>();
			for( c in chars ) {
				var t = hxd.Res.load('letter/helvetica/$c.png').toTile();
				//t = t.center();
				tiles.set( c, t );
			}

			space.init( 4000, 2000, tiles );

			var i = 0;
			for( n in 0...10 ) {
				for( c in tiles.keys() ) {
					space.addLetter( c );
					//var l = space.addLetter( c );
					//l.x = Math.random() * space.width;
					//l.y = Math.random() * space.height;
				}
			}
		});
		*/

	}
}
