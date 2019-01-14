package letterspace.app;

import letterspace.game.*;

class LobbyActivity extends Activity {

	var input : InputElement;

	public function new() {

		super();

		var meta = document.createDivElement();
		meta.classList.add( 'meta' );
		element.appendChild( meta );

		/*
		var flask = document.createDivElement();
		flask.title = 'EXPERIMENTAL';
		flask.classList.add( 'ic-flask' );
		meta.appendChild( flask );
		*/

		var version = document.createDivElement();
		version.classList.add( 'version' );
		version.textContent = 'R'+App.REV+'/V'+App.VERSION;
		#if dev
		version.textContent += '-DEV';
		#end
		meta.appendChild( version );

		var fork = document.createAnchorElement();
		fork.title = 'FORK';
		fork.href = 'https://github.com/disktree/letterspace';
		fork.classList.add( 'ic-fork' );
		meta.appendChild( fork );

		//TODO see: https://github.com/isaacs/github/issues/99
		//var issue = document.createAnchorElement();
		//issue.href = 'https://github.com/disktree/letterspace/issues/new?title=foo&body=bar';
		//issue.textContent = 'ISSUE';
		//element.appendChild( issue );

		input = document.createInputElement();
		input.type = 'text';
		input.name = 'username';
		//input.pattern = '[a-zA-Z!@#$%^*_|]{0,3}';
		input.placeholder = 'USERNAME';
		input.title = 'USERNAME';
		input.autocomplete = 'off';
		input.size = 16;
		input.maxLength = 16;
		element.appendChild( input );
	}

	override function onStart() {

		input.value = App.storage.get( 'user' );
		//if( input.value.length > 0 ) input.select() else input.focus();
		input.focus();

		window.addEventListener( 'keydown', handleKeyDown, false );
		window.addEventListener( 'focus', handleWindowFocus, false );
		//window.addEventListener( 'blur', handleWindowBlur, false );

		/*
		App.server.lobby().then( function(r){
			//trace(r.length+' users online');
			trace(r);
		});
		*/
	}

	override function onStop() {
		window.removeEventListener( 'keydown', handleKeyDown );
		window.removeEventListener( 'focus', handleWindowFocus );
		//window.removeEventListener( 'blur', handleWindowBlur );
	}

	function joinMesh( mesh : String, user : String ) {
		App.storage.set( 'user', user );
		user = StringTools.htmlEscape( user );
		Activity.set( new JoinActivity( mesh, user ) );
	}

	function handleWindowFocus(e) {
		//trace(e);
		//e.preventDefault();
		//e.stopPropagation();
		delay( input.focus, 0 );
	}

	/*
	function handleWindowBlur(e) {
		//trace(e);
	}
	*/

	function handleKeyDown(e) {
		switch e.keyCode {
		case 13:
			var user : String = input.value;
			if( user.length >= 2 ) {
				input.disabled = true;
				joinMesh( 'freespace', user );
			}
		}
	}

}
