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

		//TODO see: https://github.com/isaacs/github/issues/99
		//var issue = document.createAnchorElement();
		//issue.href = 'https://github.com/disktree/letterspace/issues/new?title=foo&body=bar';
		//issue.textContent = 'ISSUE';
		//element.appendChild( issue );

		/*
		var experimental = document.createDivElement();
		experimental.classList.add( 'experimental' );
		experimental.textContent = 'This is an experimental application.';
		element.appendChild( experimental );

		var github = document.createDivElement();
		github.classList.add( 'ic-github' );
		element.appendChild( github );

		var fork = document.createDivElement();
		fork.classList.add( 'ic-fork' );
		element.appendChild( fork );
		*/

		input = document.createInputElement();
		input.type = 'text';
		input.name = 'username';
		input.placeholder = 'USERNAME';
		input.title = 'USERNAME';
		input.autocomplete = 'off';
		input.maxLength = 20;
		element.appendChild( input );
	}

	override function onStart() {

		input.value = App.storage.get( 'user' );
		input.focus();

		window.addEventListener( 'keydown', handleKeyDown, false );

		/*
		App.server.lobby().then( function(r){
			trace(r.length+' users online');
		});
		*/
	}

	override function onStop() {
		window.removeEventListener( 'keydown', handleKeyDown );
	}

	function handleKeyDown(e) {
		switch e.keyCode {
		case 13:
			var username : String = input.value;
			if( username.length >= 3 ) {
				input.disabled = true;
				App.storage.set( 'user', username );
				Activity.set( new JoinActivity( 'letterspace', username ) );
			}
		}
	}

}
