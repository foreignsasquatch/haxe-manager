import commands.Use;
import commands.Install;
import commands.Link;
import commands.List;

function main() {
    setup();

    if(Const.args.length < 2) help();
    if(isCommand("setup")) Link.linkHXM();
    if(isCommand("install")) Install.install(Const.args[1]);
    if(isCommand("remove")) Install.remove(Const.args[1]);
    if(isCommand("list")) List.list();
    if(isCommand("use")) Use.use(Const.args[1]);
}

function setup() {
    Const.os = Sys.systemName();
    Const.args = Sys.args();
    Const.cwd = Sys.getCwd();

    // os_def - the os name for download
    // dw_fmt - download format (linux/osx - tar.gz and win - zip)
    // HOME - home folder 
    if(Const.os == "Linux") {
        Const.os_def = "linux64";
        Const.dw_fmt = "tar.gz";
        Const.HOME = Sys.environment()['HOME'];
    } else if(Const.os == "Mac") {
        Const.os_def = "osx";
        Const.dw_fmt = "tar.gz";
        Const.HOME = Sys.environment()['HOME'];
    } else if(Const.os == "Windows") {
        Const.os_def = "win64";
        Const.dw_fmt = "zip";
        Const.HOME = Sys.environment()['USERPROFILE'];
    } else {
        Print.error("your os is not supported :(");
    }

    // creates the follow:
    // $HOME/.haxe-manager
    // |- versions
    Const.hxm_location = '${Const.HOME}/.haxe-manager';
    if(!FileSystem.exists(Const.hxm_location)) {
        FileSystem.createDirectory(Const.hxm_location);
    }

    if(!FileSystem.exists(Path.join([Const.hxm_location, 'versions']))) {
        File.saveContent(Path.join([Const.hxm_location, 'versions']), "");
    } else {
        Const.versions = File.getContent(Path.join([Const.hxm_location, 'versions']));
    }
}

function isCommand(cmd:String) {
    return Const.args[0] == cmd;
}

// Help Command - Lists all commands
function help() {
    Print.print("<yb><b>haxe-manager</>");
    Print.print("\n<u><w>commands</>:");
    Print.print("<bo>setup</>                <b>setup haxe-manager</>");
    Print.print("<bo>install</> [version]    <b>installs version</> ");
    Print.print("<bo>remove</>  [version]    <b>remove version</> ");
    Print.print("<bo>use</>     [version]    <b>selects version</> ");
    Print.print("<bo>list</>                 <b>lists available haxe versions</> ");
    Print.print("<bo>current</>              <b>prints current version used</> ");
    Print.print("\n<u>usage</>:");
    Print.print("> <b><g>haxe-manager</> install 4.3.5");
}