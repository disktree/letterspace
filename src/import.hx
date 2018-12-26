
import Om.console;
import om.Json;
import om.StringTools;
import om.Time;

#if js
import om.Promise;
#if nodejs
#else
import om.Browser;
import om.Browser.document;
import om.Browser.navigator;
import om.Browser.window;
import om.Storage;
import om.Tween;
import js.html.Element;
import js.html.FormElement;
import js.html.DivElement;
import js.html.InputElement;
#end
#end
