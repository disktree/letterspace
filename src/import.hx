
import Om.console;
import om.Json;
import om.Time;

//using om.ArrayTools;

#if js
import haxe.Timer.delay;
import om.Promise;
#if nodejs
#else
import om.Browser;
import om.Browser.document;
import om.Browser.navigator;
import om.Browser.window;
import om.FetchTools.*;
import om.Storage;
import om.Tween;
import js.html.ArrayBuffer;
import js.html.CanvasElement;
import js.html.DataView;
import js.html.Element;
import js.html.FormElement;
import js.html.DivElement;
import js.html.InputElement;
import js.html.Uint8Array;
#end
#end
