package commands;

class Use {
    public static function use(version:String) {
		if(version == null) Print.error("please provide a version!");
    }
}