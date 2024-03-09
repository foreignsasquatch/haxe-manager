class Print {
	static var underline = "\x1b[4m";
	static var italic = "\x1b[3m";
	static var bold = "\x1b[1m";
	static var blinking = "\x1b[5m";

	static var redFg = "\x1b[31m";
	static var redBg = "\x1b[41m";
	static var yellowFg = "\x1b[33m";
	static var yellowBg = "\x1b[43m";
	static var blueFg = "\x1b[34m";
	static var blueBg = "\x1b[44m";
	static var whiteFg = "\x1b[97m";
	static var blackFg = "\x1b[30m";
	static var greenFg = "\x1b[32m";
	static var greenBg = "\x1b[42m";

	static var clear = "\x1b[0m";
	static var clearLine = '\x1b[2K';
	static var n = "\n";

    static var formatShortHands:Map<String, String> = ["i" => italic, "u" => underline, "bo" => bold, "bi" => blinking, "r" => redFg, "y" => yellowFg, "b" => blackFg, "bl" => blueFg, "w" => whiteFg,
    "g" => greenFg, "gb" => greenBg, "rb" => redBg, "yb" => yellowBg, "bb" => blueBg];


    // HELPERS
    public static function info(msg:String, next:Bool = true) {
        print('<bb><bo><w>INFO</> $msg', next);
    }

    public static function error(msg:String, next:Bool = true) {
        print('<rb><bo><w>ERROR</> $msg', next);
    }
    
	public static function print(msg:String, next:Bool = true) {
		var fmt = msg.split("</>"); // check all the format ends

		// we print section by section because... yes.
		for (i in 0...fmt.length) {
			Sys.print(formatString(fmt[i]));
			if (i == fmt.length - 1 && next)
				Sys.print("\n");
		}
	}

	static function formatString(fmt:String):String {
		for (k => v in formatShortHands) {
			if (fmt.contains("<" + '$k>'))
				fmt = fmt.replace("<" + '$k>', v);
		}
		return fmt + clear;
	}
}
