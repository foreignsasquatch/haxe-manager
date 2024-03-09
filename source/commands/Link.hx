package commands;

class Link {
    // Makes `haxe-manager` command available everywhere
    public static function linkHXM() {
        var bashScript = '#!/bin/bash
        haxelib run haxe-manager $@';
    
        var cmdScript = '@echo off\r\n haxelib run haxe-manager %*';
        
        if(Const.os == "Linux" || Const.os == "Mac") {
            if(FileSystem.exists("/usr/local/bin/haxe-manager")) {
                Print.error("<g><bo>haxe-manager is already setup!</>");
                return;
            }
    
            var tmpCwd = '/usr/local/bin';
            Sys.setCwd(tmpCwd);
            File.saveContent('/usr/local/bin/haxe-manager', bashScript);
            Sys.command('chmod', ['+x', 'haxe-manager']);
            Print.info("<g><bo>haxe-manager has been setup!</>");
        } else {
            var haxePath = Sys.getEnv("HAXEPATH");
            if(FileSystem.exists(Path.join([haxePath, "haxe-manager.cmd"]))) {
                Print.error("<g><bo>haxe-manager is already setup!</>");
                return;
            }
            File.saveContent(Path.join([haxePath, "haxe-manager.cmd"]),cmdScript);
            Print.info("<g><bo>haxe-manager has been setup!</>");
        }
    }
}