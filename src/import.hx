
import Om.console;
import om.Json;
import om.Nil;
import om.System;
import om.Time;

#if js
import haxe.Timer.delay;
import om.Promise;
#if owl_server
import js.Node.process;
import js.node.Fs;
import Sys.print;
import Sys.println;
using om.Path;
#elseif owl_client
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
