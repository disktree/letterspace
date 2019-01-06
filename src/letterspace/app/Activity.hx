package letterspace.app;

class Activity {

	public final id : String;
	public final element : Element;

	public function new( ?id : String ) {
		if( id == null ) {
            var cname = Type.getClassName( Type.getClass( this ) );
			cname = cname.substr( cname.lastIndexOf( '.' ) + 1 );
			cname = cname.substr( 0, cname.length - 'Activity'.length );
			id = cname.toLowerCase();
		}
		this.id = id;
		this.element = document.createDivElement();
		this.element.id = this.id;
		this.element.classList.add( 'activity' );
	}

	function onStart() {}
	function onStop() {}

	public static var container(default,null) : Element;

	static var stack : Array<Activity>;

	public static function boot<T>( activity : Activity, ?container : Element ) {
		Activity.container = (container == null) ? document.body : container;
		stack = [];
		stack.push( activity );
		Activity.container.appendChild( activity.element );
		activity.onStart();
	}

	static function set<T:Activity>( activity : T ) : T {
		if( stack.length > 0 ) {
			var cur = stack.pop();
			cur.onStop();
			cur.element.remove();
		}
		stack.push( activity );
		container.appendChild( activity.element );
		activity.onStart();
		return activity;
	}

	static function push<T:Activity>( activity : T ) : T {
		if( stack.length > 0 ) {
			var cur = stack[stack.length-1];
			cur.onStop();
			cur.element.remove();
		}
		stack.push( activity );
		container.appendChild( activity.element );
		activity.onStart();
		return activity;
	}
}
