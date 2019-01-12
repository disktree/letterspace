package letterspace.game;

class Menu {

	//var user : Element;
	var users : Element;

	public function new( parent : Element, user : Node ) {

		var element = document.createDivElement();
		element.classList.add( 'menu' );
		parent.appendChild( element );

		//this.user = createUserElement( user );
		//element.appendChild( this.user );

		this.users = document.createDivElement();
		this.users.classList.add( 'users' );
		element.appendChild( this.users );

		addUser( user );
	}

	public function addUser( user : Node ) {
		var e = createUserElement( user );
		users.appendChild( e );
	}

	public function removeUser( user : Node ) {
		var e = users.querySelector( '[data-id="${user.id}"]' );
		if( e == null ) {
			console.warn( 'user [$user] does not exist' );
		} else {
			e.remove();
		}
	}

	public function setDragStart( user : Node, letter : Letter ) {
		var e = users.querySelector( '[data-id="${user.id}"]' );
		e.classList.add( 'dragged' );
		//e.textContent += ':'+letter.char;
		flipColors( e );
	}

	public function setDragStop( user : Node ) {
		var e = users.querySelector( '[data-id="${user.id}"]' );
		e.classList.remove( 'dragged' );
		flipColors( e );
	}

	static function createUserElement( user : Node ) : Element {
		var e = document.createDivElement();
		e.classList.add( 'user' );
		e.setAttribute( 'data-id', user.id );
		e.textContent = user.name;
		//e.style.backgroundColor = '#'+StringTools.hex( user.color, 6 );
		e.style.color = getColorString( user.color );
		return e;
	}

	static function flipColors( e : Element ) {
		var c = e.style.color;
		e.style.color = e.style.background;
		e.style.background = c;
	}

	static inline function getColorString( color : Int ) : String {
		return '#'+StringTools.hex( color, 6 );
	}
}

/*
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
*/
