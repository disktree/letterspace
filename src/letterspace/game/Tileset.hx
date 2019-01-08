package letterspace.game;

#if !macro
@:build(letterspace.macro.Build.tiles())
#end
class Tileset {

	public static var CHARACTERS(default,null) : Map<String,String> = [
		"a" => "a",
		"b" => "b",
		"c" => "c",
		"d" => "d",
		"e" => "e",
		"f" => "f",
		"g" => "g",
		"h" => "h",
		"i" => "i",
		"j" => "j",
		"k" => "k",
		"l" => "l",
		"m" => "m",
		"n" => "n",
		"o" => "o",
		"p" => "p",
		"q" => "q",
		"r" => "r",
		"s" => "s",
		"t" => "t",
		"u" => "u",
		"v" => "v",
		"w" => "w",
		"x" => "x",
		"y" => "y",
		"z" => "z",

		"A" => "A",
		"B" => "B",
		"C" => "C",
		"D" => "D",
		"E" => "E",
		"F" => "F",
		"G" => "G",
		"H" => "H",
		"I" => "I",
		"J" => "J",
		"K" => "K",
		"L" => "L",
		"M" => "M",
		"N" => "N",
		"O" => "O",
		"P" => "P",
		"Q" => "Q",
		"R" => "R",
		"S" => "S",
		"T" => "T",
		"U" => "U",
		"V" => "V",
		"W" => "W",
		"X" => "X",
		"Y" => "Y",
		"Z" => "Z",

		"1" => "1",
		"2" => "2",
		"3" => "3",
		"4" => "4",
		"5" => "5",
		"6" => "6",
		"7" => "7",
		"8" => "8",
		"9" => "9",
		"0" => "0",

		"!" => "callsign",
		'"' => "quote",
		"§" => "micro",
		"$" => "dollar",
		"%" => "percent",
		"&" => "ampersand",
		"/" => "forwardslash",
		"(" => "parenthesis_open",
		")" => "parenthesis_close",
		"=" => "equal",
		"?" => "questionmark",

		"<" => "lesser",
		">" => "greater",

		"," => "comma",
		";" => "semicolon",
		":" => "colon",
		"." => "period",
		"-" => "hyphen",
		"_" => "underscore",
		"+" => "plus",
		"~" => "tilde",
		"*" => "asterisk",
		"#" => "hash",
		"'" => "singlequote",

		"@" => "ampersat",
		"€" => "euro",
	];

	#if !macro
	/*
	static var MAP : Map<String,Array<String>> = [
		"helvetica" => ["a","A"]
	];
	*/
	#end

}
