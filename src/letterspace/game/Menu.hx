package letterspace.game;

class Menu {

	var user : Element;
	var users : Element;

	public function new( parent : Element, user : User ) {

		var element = document.createDivElement();
		element.classList.add( 'menu' );
		parent.appendChild( element );

		this.user = createUserElement( user );
		element.appendChild( this.user );

		this.users = document.createDivElement();
		this.users.classList.add( 'users' );
		element.appendChild( this.users );
	}

	public function addUser( user : User ) {
		var e = createUserElement( user );
		users.appendChild( e );
	}

	public function removeUser( user : String ) {
		var e = users.querySelector( '[data-name="$user"]' );
		if( e == null ) {
			console.warn( 'user [$user] does not exist' );
		} else {
			e.remove();
		}
	}

	function createUserElement( user : User ) : Element {
		var e = document.createDivElement();
		e.classList.add( 'user' );
		e.setAttribute( 'data-name', user.name );
		e.textContent = user.name;
		e.style.backgroundColor = '#'+StringTools.hex( user.color, 6 );
		return e;
	}
}
