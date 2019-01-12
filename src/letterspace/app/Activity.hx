package letterspace.app;

class Activity {

	public final id : String;
	public final element : Element;
	//public var state(default,null) : State;

	public function new( ?id : String, ?element : Element ) {
		if( id == null ) {
            var cn = Type.getClassName( Type.getClass( this ) );
			cn = cn.substr( cn.lastIndexOf( '.' ) + 1 );
			cn = cn.substr( 0, cn.length - 'Activity'.length );
			id = cn.toLowerCase();
		}
		this.id = id;
		this.element = (element == null) ? document.createDivElement() : element;
		this.element.id = this.id;
		this.element.classList.add( 'activity' );
	}

	function onCreate<T:Activity>() : Promise<T> {
		return Promise.resolve( cast this );
	}

	function onStart() {}

	//function onResume() {}

	//function onPause() {}

	function onStop() {}

	function onDestroy() {}

	/*
	function onDestroy<T>() : Promise<T> {
		return Promise.resolve();
	}
	*/

	public static var container(default,null) : Element;

	static var stack : Array<Activity>;

	public static function init<T:Activity>( activity : Activity, ?container : Element ) : Promise<T> {

		//if( stack !=  null ) //TODO reset?

		Activity.container = (container == null) ? document.body : container;
		stack = [];

		console.group( 'init: '+activity.id );

		Activity.container.appendChild( activity.element );

		return activity.onCreate().then( function(_){

			stack.push( activity );
			activity.onStart();

			console.groupEnd();

			return cast activity;
		});
	}

	public static function set<T:Activity>( activity : T ) : Promise<T> {

		console.group( 'set: '+activity.id );

		container.appendChild( activity.element );

		return activity.onCreate().then( function(_) {

			if( stack.length > 0 ) {
				var cur = stack.pop();
				cur.onStop();
				cur.element.remove();
				cur.onDestroy();
			}
			stack.push( activity );

			activity.onStart();

			console.groupEnd();

			return cast activity;
		});
	}

	public static function push<T:Activity>( activity : T ) : Promise<T> {

		console.group( 'push: '+activity.id );

		container.appendChild( activity.element );

		return activity.onCreate().then( function(_){
			if( stack.length > 0 ) {
				var cur = stack[stack.length-1];
				cur.onStop();
				cur.element.remove();
			}
			stack.push( activity );
			activity.onStart();

			console.groupEnd();

			return cast activity;
		});
	}

	public static function pop() {

		if( stack.length < 2 )
			return;


		var cur = stack.pop();
		var pre = stack[stack.length-1];

		console.group( 'pop: '+cur.id );

		cur.onStop();

		container.appendChild( pre.element );
		pre.onStart();

		cur.element.remove();
		cur.onDestroy();

		console.groupEnd();
	}

	/*
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
	*/

	/*
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
	*/
}
