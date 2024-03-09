package commands;

typedef ReqJson = {name:String, assets:Array<{name:String, url:String, label:String}>};

class Install {
	public static function install(version:String) {
		if(version == null) Print.error("please provide a version!");
		// handle nightlies elsewhere
		if(version == "nightly") {nightly(); Sys.exit(0);}
		if(version == 'hashlink') {hashlink(); Sys.exit(0);};

        // check if it exists already
        if(Const.versions.length > 0 && Const.versions.contains(version)) {
            Print.info('version <g><bo>$version</> already exists!');
            Sys.exit(0);
        }

		var gh = 'https://api.github.com/repos/HaxeFoundation/haxe/releases';
		var link = '';

		var versionExists = false;
		var req:Array<ReqJson>;
		var releaseNumer:Int = null;

        // we make request to github api and get all releases
        // we also make sure to check if the version exists
        // if not we exit
		var http = new Http(gh);
		http.addHeader("User-Agent", "haxe-manager");
		http.onData = function(data:String) {
			req = Json.parse(data);
			for (releases in req) {
				if (releases.name == version) {
					versionExists = true;
					releaseNumer = req.indexOf(releases);
				}
			}

			if (!versionExists) {
				Print.error("please enter a valid version!");
				Sys.exit(0);
			}

			var assets_url = req[releaseNumer].assets;
			for (assets in assets_url) {
				if (assets.name == 'haxe-$version-${Const.os_def}.${Const.dw_fmt}')
					link = assets.url;
			}
		}
		http.onError = function(msg:String) {
			throw msg;
		}
		http.request();

		// now to download the archive file
		Print.info('Installing haxe <y><bo>$version</>', false);
		var stampb = Timer.stamp();
		var output = download(link); // get the data

		// extract
		var folderOfVersion = '';
		if (Const.dw_fmt == "tar.gz") {
            // using format we extract
            var tgz = new format.tgz.Reader(output);
			var data = tgz.read();

			for (d in data) {
				if (d.fileName.endsWith("/")) {
					if (folderOfVersion == '')
						folderOfVersion = d.fileName.split("/")[0];
					FileSystem.createDirectory(Path.join([Const.hxm_location, d.fileName])); // if it is a folder we make that folder
				} else
					File.saveBytes(Path.join([Const.hxm_location, d.fileName]), d.data);
			}
		} else if (Const.dw_fmt == "zip") {
			var zip = new format.zip.Reader(output);
			var data = zip.read();
			for (d in data) {
				if (d.fileName.endsWith("/")) {
					if (folderOfVersion == '')
						folderOfVersion = d.fileName.split("/")[0];
					FileSystem.createDirectory(Path.join([Const.hxm_location, d.fileName]));
				} else
					File.saveBytes(Path.join([Const.hxm_location, d.fileName]), d.data);
			}
		}

        // we save the version to a list for checking later
		Const.versions += '$version~$folderOfVersion\n';
		File.saveContent(Path.join([Const.hxm_location, 'versions']), Const.versions);

		var stampe = Timer.stamp();

		Print.print(@:privateAccess Print.clearLine + '\r', false);
		Print.info('Installed haxe <g><bo>$version</> <b><bo>(took ${Std.int(stampe - stampb)}s)</>');
	}

	// nightly builds!
	static function nightly() {
		var url = 'https://build.haxe.org/builds/haxe';
		if(Const.os == "Linux") url = url+'/linux64/'+'haxe_latest.tar.gz';
		else if(Const.os == "Mac") url = url+'/mac/'+'haxe_latest.tar.gz';
		else if(Const.os == "Windows") url = url+'/windows64/'+'haxe_latest.zip';
		trace(url);

		Print.info('Installing haxe <y><bo>nightly</>', false);
		var stampb = Timer.stamp();
		var out:BytesInput;
		var http = new Http(url);
		http.onBytes = function(data) {
			out = new BytesInput(data);
		}
		http.request();

		// extract
		var folderOfVersion = '';
		if (Const.dw_fmt == "tar.gz") {
            // using format we extract
            var tgz = new format.tgz.Reader(out);
			var data = tgz.read();

			for (d in data) {
				if (d.fileName.endsWith("/")) {
					if (folderOfVersion == '')
						folderOfVersion = d.fileName.split("/")[0];
					FileSystem.createDirectory(Path.join([Const.hxm_location, d.fileName])); // if it is a folder we make that folder
				} else
					File.saveBytes(Path.join([Const.hxm_location, d.fileName]), d.data);
			}
		} else if (Const.dw_fmt == "zip") {
			var zip = new format.zip.Reader(out);
			var data = zip.read();
			for (d in data) {
				if (d.fileName.endsWith("/")) {
					if (folderOfVersion == '')
						folderOfVersion = d.fileName.split("/")[0];
					FileSystem.createDirectory(Path.join([Const.hxm_location, d.fileName]));
				} else
					File.saveBytes(Path.join([Const.hxm_location, d.fileName]), d.data);
			}
		}

		Const.versions += 'nightly~$folderOfVersion\n';
		File.saveContent(Path.join([Const.hxm_location, 'versions']), Const.versions);

		var stampe = Timer.stamp();
		Print.print(@:privateAccess Print.clearLine + '\r', false);
		Print.info('Installed haxe <g><bo>nightly</> <b><bo>(took ${Std.int(stampe - stampb)}s)</>');
	}

	static function hashlink() {
		var gh = 'https://api.github.com/repos/HaxeFoundation/hashlink/releases';
		var link = '';

		var versionExists = false;
		var req:Array<ReqJson>;
		var releaseNumer:Int = null;

        // we make request to github api and get all releases
        // we also make sure to check if the version exists
        // if not we exit
		var http = new Http(gh);
		http.addHeader("User-Agent", "haxe-manager");
		http.onData = function(data:String) {
			req = Json.parse(data);
			for (releases in req) {
				if (releases.name == "HashLink Nightly Build") {
					versionExists = true;
					releaseNumer = req.indexOf(releases);
				}
			}

			if (!versionExists) {
				Print.error("please enter a valid version!");
				Sys.exit(0);
			}

			var ops = '';
			if(Const.os == "Linux") ops = 'linux-amd64';
			else if(Const.os == "Mac") ops = 'darwin';
			else if(Const.os == "Windowns") ops = 'win64';
			var assets_url = req[releaseNumer].assets;
			for (assets in assets_url) {
				if(assets.label == 'hashlink-latest-$ops.${Const.dw_fmt}') {
					link = assets.url;
				}
			}
		}
		http.onError = function(msg:String) {
			throw msg;
		}
		http.request();

		// now to download the archive file
		Print.info('Installing hashlink <y><bo>nightly</>', false);
		var stampb = Timer.stamp();
		var output = download(link); // get the data

		// extract
		var folderOfVersion = '';
		if (Const.dw_fmt == "tar.gz") {
            // using format we extract
            var tgz = new format.tgz.Reader(output);
			var data = tgz.read();

			for (d in data) {
				if (d.fileName.endsWith("/")) {
					if (folderOfVersion == '')
						folderOfVersion = d.fileName.split("/")[0];
					FileSystem.createDirectory(Path.join([Const.hxm_location, d.fileName])); // if it is a folder we make that folder
				} else
					File.saveBytes(Path.join([Const.hxm_location, d.fileName]), d.data);
			}
		} else if (Const.dw_fmt == "zip") {
			var zip = new format.zip.Reader(output);
			var data = zip.read();
			for (d in data) {
				if (d.fileName.endsWith("/")) {
					if (folderOfVersion == '')
						folderOfVersion = d.fileName.split("/")[0];
					FileSystem.createDirectory(Path.join([Const.hxm_location, d.fileName]));
				} else
					File.saveBytes(Path.join([Const.hxm_location, d.fileName]), d.data);
			}
		}

        // we save the version to a list for checking later
		Const.versions += 'hashlink~$folderOfVersion\n';
		File.saveContent(Path.join([Const.hxm_location, 'versions']), Const.versions);

		var stampe = Timer.stamp();

		Print.print(@:privateAccess Print.clearLine + '\r', false);
		Print.info('Installed hashlink <g><bo>nightly</> <b><bo>(took ${Std.int(stampe - stampb)}s)</>');
	}

    // download from given url
    // used only for getting the archive from release
	static function download(s:String):BytesInput {
		var fileReq = new Http(s);
		var output:BytesInput = null;
        // this is required to get release from gh
		fileReq.addHeader("User-Agent", "haxe-manager");
		fileReq.addHeader("Accept", "application/octet-stream");
		var stat:Int = -1;

		fileReq.onStatus = function(status:Int) {
			stat = status;
		}

        fileReq.onBytes = function(data) {
            // if no redirect we download
			if (stat != 301 || stat != 302) {
				output = new BytesInput(data);
			}
		}

        fileReq.onError = function(msg:String) {
			throw msg;
		}
		fileReq.request();

        // handle redirects
		if (stat == 301 || stat == 302) {
			output = download(fileReq.responseHeaders.get("Location"));
		}

		return output;
	}

    public static function remove(version:String) {
		if(version == null) Print.error("please provide a version!");
        var location = '';
        if(Const.versions.length > 0 && Const.versions.contains(version)) {
            location = Path.join([Const.hxm_location, getlocation(version)]);
		} else {
            Print.error('version $version is not installed!');
			Sys.exit(0);
        }

        for(file in FileSystem.readDirectory(location)) {
			file = Path.join([location, file]);
			if(FileSystem.isDirectory(file)) {
				removeFolder(file);
            } else {
                FileSystem.deleteFile(file);
            }
        }

		for(file in FileSystem.readDirectory(location)) {
			removeFolder(Path.join([location, file]));
		}

		removeVersion(version);
    }

    static function getlocation(version:String):String {
        var loc = '';
        var lines = Const.versions.split('\n');
        for(l in lines) {
            var spl = l.split('~');
            if(spl[0] == version) loc = spl[1];
        }
        return loc;
    }

	static function removeVersion(version:String) {
        var lines = Const.versions.split('\n');
        for(l in lines) {
			lines.remove(l);
		}
		Const.versions = '';
		for(l in lines) Const.versions += l;
		File.saveContent(Path.join([Const.hxm_location, 'versions']), Const.versions);
	}

	public static function removeFolder(location:String) {
        for(file in FileSystem.readDirectory(location)) {
			file = Path.join([location, file]);
			if(FileSystem.isDirectory(file)) {
                for(f in FileSystem.readDirectory(file)) {
                    if(!FileSystem.isDirectory(Path.join([file,f]))) FileSystem.deleteFile(Path.join([file,f]));
					else removeFolder(Path.join([file,f]));
                }
            } else {
                FileSystem.deleteFile(file);
            }
        }
	}
}
