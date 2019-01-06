package letterspace.app;

class ErrorActivity extends Activity {

	var info : String;

	public function new( info : String ) {
		super();
		this.info = info;
	}

	override function onStart() {
		var e = document.createDivElement();
		e.classList.add( 'info' );
		e.textContent = info;
		element.appendChild( e );
	}

}
