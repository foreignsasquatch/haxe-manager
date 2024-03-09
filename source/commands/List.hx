package commands;

class List {
    public static function list() {
        Print.print("<u>versions</>:");
        var lines = Const.versions.split('\n');
        for(l in lines) {
            if(l == '') return;
            var spl = l.split('~');
            Print.print('<b>-</> ${spl[0]}');
        }
    }
}