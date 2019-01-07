package letterspace.game;

class Menu {

	public var element(default,null) : Element;

	var user : Element;
	var users : Element;

	public function new( userName : String ) {

		element = document.createDivElement();
		element.classList.add( 'menu' );
		document.body.appendChild( element );

		user = document.createDivElement();
		user.classList.add( 'user' );
		user.textContent = userName;
		element.appendChild( user );

		users = document.createDivElement();
		users.classList.add( 'users' );
		element.appendChild( users );
	}

	public function addUser( user : String ) {
		var e = document.createDivElement();
		e.classList.add( 'user' );
		e.setAttribute( 'data-name', user );
		e.textContent = user;
		//e.style.color = '#'+StringTools.hex( color );
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
}
