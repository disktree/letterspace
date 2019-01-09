package letterspace.app;

import letterspace.game.*;

class LobbyActivity extends Activity {

	var input : InputElement;

	public function new() {

		super();

		var version = document.createDivElement();
		version.classList.add( 'version' );
		version.textContent = 'V'+App.VERSION;
		element.appendChild( version );

		input = document.createInputElement();
		input.type = 'text';
		input.name = 'username';
		input.placeholder = 'USERNAME';
		input.title = 'USERNAME';
		element.appendChild( input );
	}

	override function onStart() {
		input.value = App.storage.get( 'user' );
		input.focus();
		window.addEventListener( 'keydown', handleKeyDown, false );
	}

	override function onStop() {
		window.removeEventListener( 'keydown', handleKeyDown );
	}

	function handleKeyDown(e) {
		switch e.keyCode {
		case 13:
			var username : String = input.value;
			if( username.length >= 3 ) {
				trace( username );
				input.disabled = true;
				App.storage.set( 'user', username );
				Activity.set( new JoinActivity( 'letterspace', username ) );
			}
		}
	}

}
