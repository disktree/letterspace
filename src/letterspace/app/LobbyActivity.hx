package letterspace.app;

import letterspace.game.*;

class LobbyActivity extends Activity {

	var input : InputElement;

	public function new() {
		super();
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
			var user : String = input.value;
			if( user.length > 0 ) {
				input.disabled = true;
				App.storage.set( 'user', user );
				Activity.set( new LoginActivity( user ) );
			}
		}
	}

}
