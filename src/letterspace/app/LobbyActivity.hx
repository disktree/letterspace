package letterspace.app;

import letterspace.game.*;

class LobbyActivity extends Activity {

	var input : InputElement;

	public function new() {

		super();

		var meta = document.createDivElement();
		meta.classList.add( 'meta' );
		element.appendChild( meta );

		var fork = document.createAnchorElement();
		fork.title = 'FORK';
		fork.href = 'https://github.com/disktree/letterspace';
		fork.classList.add( 'ic-fork' );
		meta.appendChild( fork );

		var flask = document.createDivElement();
		flask.title = 'EXPERIMENTAL';
		flask.classList.add( 'ic-flask' );
		meta.appendChild( flask );

		/*
		var github = document.createDivElement();
		github.classList.add( 'ic-github' );
		meta.appendChild( github );

		var question = document.createDivElement();
		question.classList.add( 'ic-question' );
		meta.appendChild( question );
		*/

		var version = document.createDivElement();
		version.classList.add( 'version' );
		version.textContent = 'v'+App.VERSION;
		version.title = 'v'+App.VERSION;
		meta.appendChild( version );

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

		var cog = document.createDivElement();
		cog.classList.add( 'ic-cog' );
		element.appendChild( cog );
		cog.onclick = function(){
			Activity.push( new CreditsActivity() );
		}
		*/

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

		//trace( input.pattern );
	}

	override function onStart() {

		input.value = App.storage.get( 'user' );
		input.focus();

		window.addEventListener( 'keydown', handleKeyDown, false );

		/*
		App.server.lobby().then( function(r){
			//trace(r.length+' users online');
			trace(r);
		});
		*/
	}

	override function onStop() {
		window.removeEventListener( 'keydown', handleKeyDown );
	}

	function joinMesh( mesh : String, user : String ) {
		App.storage.set( 'user', user );
		user = StringTools.htmlEscape( user );
		Activity.set( new JoinActivity( mesh, user ) );
	}

	function handleKeyDown(e) {
		switch e.keyCode {
		case 13:
			var username : String = input.value;
			if( username.length >= 2 ) {
				input.disabled = true;
				joinMesh( 'freespace', username );
			}
		}
	}

}
