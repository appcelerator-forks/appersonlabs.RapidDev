var join = require('path').join,
	fs = require('fs'),
	path = require('path'),
	WebSocketServer = require('ws').Server,
	network = require('os').networkInterfaces(),
	chokidar = require('chokidar'),
	semver = require('semver'),
	op = require('openport'),
	mime = require('mime'),
	hashdir = require('hashsome/lib/hashdir.js'),
	connectedDevices = 0,
	hashMap = {},
	currentHash = '',
	projectDir,
	iOSHardImages = [
		'Default.png',
		'Default@2x.png',
		'Default-Landscape.png',
		'Default-Landscape@2x.png',
		'Default-Portrait.png',
		'Default-Portrait@2x.png',
		'Default-LandscapeLeft.png',
		'Default-LandscapeLeft@2x.png',
		'Default-LandscapeRight.png',
		'Default-LandscapeRight@2x.png',
		'Default-PortraitUpsideDown.png',
		'Default-PortraitUpsideDown@2x.png'
	],
	androidHardImages = [

	],
	wss,
	thisAppID,
	thisConfig;

exports.cliVersion = '>=3.2.0';
exports.version = '1.0';

exports.init = init;

/**
 * [init description]
 * @param  {[type]} logger [description]
 * @param  {[type]} config [description]
 * @param  {[type]} cli    [description]
 */
function init(logger, config, cli) {
	// Use the module hash here and save on device, use to check if a reload is needed for modules
	// cli.addHook('build.pre.construct', function(build, finished) {
	// 	console.log(build);
	// });

	// including "rapidev" because even we misspell this sometimes :(
	if (process.argv.indexOf('--rapiddev') !== -1 || process.argv.indexOf('--rapidev') !== -1) {
		thisConfig = config;
		cli.addHook('build.pre.compile', preCompileHook);
	}
}

/**
 * [preCompileHook description]
 * @param  {Object} build - An object containing details about the build
 * @param  {Function} finished - the finished callback to let the CLI know we are ready to continue
 */
function preCompileHook(build, finished) {
	thisAppID = build.tiapp.id;
	build.modulesNativeHash = 'rapiddev';

	// Inject the module now...
	build.nativeLibModules.push({
		id: 'com.appersonlabs.rapiddev',
		platform: ['iphone'],
		deployType: ['development'],
		modulePath: path.join(__dirname, '..', '..', '..', 'module', 'modules', 'iphone', 'com.appersonlabs.rapiddev', '0.1'),
		version: '0.1',
		manifest: {
			version: '0.1',
			apiversion: '2',
			description: '',
			author: 'Matt Apperson',
			license: 'Specify your license',
			copyright: 'Copyright (c) 2013 by Apperson Labs LLC',
			name: 'rapid',
			moduleid: 'com.appersonlabs.rapiddev',
			guid: '6c572bf6-dabd-4878-87ec-eca01bad8000',
			platform: 'iphone',
			minsdk: '3.1.3.GA'
		},
		native: true,
		libName: 'libcom.appersonlabs.rapiddev.a',
		libFile: path.join(__dirname, '..', '..', '..', 'module', 'modules', 'iphone', 'com.appersonlabs.rapiddev', '0.1', 'libcom.appersonlabs.rapiddev.a')
	});

	build.includeAllTiModules = true
	build.tiapp.properties['rapiddevBuildTimeNew'] = {
		type: 'string',
		value: Date.now()
	};
	if (build.target !== 'simulator' && build.target !== 'emulator') {
		build.tiapp.properties['rapiddevURL'] = {
			type: 'string',
			value: getIp()
		};
	}

	if (semver.satisfies(build.tiapp['sdk-version'].replace('.v', '+build').replace('.GA', ''), '>=3.2.0')) {

		op.find({
			ports: [8033],
			count: 1
		}, function(err, ports) {
			if (err) {
				throw "[RapidDev - server] Port 8033 is not avaliable for use by RapidDev, server will not start...";
			}

			wss = new WebSocketServer({
				port: 8033
			});
			wss.broadcast = broadcast;

			wss.on('connection', deviceConnectedViaNetwork);

			var config = {
				ignored: thisConfig.cli.ignoreFiles,
				//persistent: true
				ignoreInitial: true
			};
			projectDir = build.projectDir;
			hashdir(join(projectDir, 'Resources'), function(err, results) {
				currentHash = results.hash;

				chokidar.watch(join(projectDir, 'Resources'), config).on('all', onFilesystemChange);

				console.log('--------------------------------------------------------------------');
				console.log("______            _     _______           ");
				console.log("| ___ \\          (_)   | |  _  \\          ");
				console.log("| |_/ /__ _ _ __  _  __| | | | |_____   __");
				console.log("|    // _` | '_ \\| |/ _` | | | / _ \\ \\ / /");
				console.log("| |\\ \\ (_| | |_) | | (_| | |/ /  __/\\ V / ");
				console.log("\\_| \\_\\__,_| .__/|_|\\__,_|___/ \\___| \\_/  ");
				console.log("           | |                            ");
				console.log("           |_|                            ");
				console.log("Developed by Apperson Labs, LLC\n\n");
				console.log('- Started on IP address: ' + getIp());
				console.log('- Watching', join(build.projectDir, 'Resources'), 'for changes');
				console.log('--------------------------------------------------------------------');

				finished(null, build);
			});

		});
	} else {
		throw "[RapidDev - server] This version of the Titanium SDK is not supported by RapidDev";
	}
}

/**
 * [broadcast description]
 * @param  {[type]} data [description]
 * @return {[type]}      [description]
 */
function broadcast(data, platform) {
	for (var i in this.clients) {
		if (this.clients[i].upgradeReq.url.indexOf(thisAppID) !== -1) {
			if (platform) {
				if (this.clients[i].upgradeReq.url.indexOf(platform) !== -1) {
					this.clients[i].send(data);
				}
			} else {
				this.clients[i].send(data);
			}
		}
	}
}

/**
 * [onFilesystemChange description]
 * @param  {String} ev - The event type
 * @param  {String} path - The path of the file that changes
 */
function onFilesystemChange(ev, path) {
	(function(ev, path) {
		var localPath = path.substr(path.indexOf('Resources'));
		var platform;

		hashdir(join(projectDir, 'Resources'), function(err, results) {
			currentHash = results.hash;
			if (localPath.indexOf('Resources/iphone/') !== -1) {
				if (iOSHardImages.some(function(v) {
					return localPath.indexOf(v) >= 0;
				})) {
					return;
				}
				platform = 'iphone';
				localPath = localPath.replace('Resources/iphone/', 'Resources/');
			}
			// if(localPath.indexOf('Resources/android/') !== -1) {
			// 	if (androidHardImages.some(function(v) { return localPath.indexOf(v) >= 0; })) {
			// 	    return;
			// 	}
			// 	platform = 'android';
			// 	localPath = localPath.replace('Resources/iphone/', 'Resources/');
			// }

			if (ev === ('unlink' || 'unlinkDir')) {
				wss.broadcast('remove-file' + '|' + localPath + '|' + currentHash);
			} else {
				var data = fs.readFileSync(path);
				var mimeType = mime.lookup(path);
				if (mimeType.indexOf('image') !== -1) {
					data = new Buffer(data).toString('base64');
				}

				wss.broadcast('update-file' + '|' + localPath + '|' + data + '|' + currentHash);
			}
		});
	})(ev, path);
}

/**
 * [deviceConnectedViaNetwork description]
 * @param  {Object} ws - An object passed from the ws module upon a device being connected
 */
function deviceConnectedViaNetwork(ws) {
	if (ws.upgradeReq && ws.upgradeReq.url && ws.upgradeReq.url.indexOf(thisAppID) !== -1) {
		connectedDevices++;
		var deviceHash = ws.upgradeReq.url.split('/').slice(-1)[0];

		if (!deviceHash || deviceHash === '' || deviceHash === '(null)' || deviceHash === null) {
			wss.broadcast('update-hash' + '|' + currentHash);
		} else if (deviceHash && deviceHash !== '' && deviceHash !== currentHash) {

			wss.broadcast('full-reload-error' + '|' + currentHash);
			console.log('[RapidDev - server]', 'A device that was just connected is out of sync, please re-install the app manualy.');

			return;
		}
		//projectDir;
		console.log('[RapidDev - server]', connectedDevices, 'device(s) connected');

		ws.on('error', websocketError);
		ws.on('message', websocketIncomingMessage);
		ws.on('close', websocketClose);
	}
}

/**
 * [websocketClose description]
 */
function websocketClose() {
	console.log('[RapidDev - server] A device has been disconnected.');
	connectedDevices--;
}

/**
 * [websocketIncomingMessage description]
 * @param  {String} message - A text string of whatever was sent to the server
 */
function websocketIncomingMessage(message) {
	console.log('[RapidDev - server] A device said: %s', message);
}

/**
 * [websocketError description]
 * @param  {string} reason - A human readable error message from the ws module
 * @param  {int} code - The error code from the ws module
 */
function websocketError(reason, code) {
	console.log('socket error: reason ' + reason + ', code ' + code);
}

/**
 * [getIp description]
 * @return {String} Returns the IP address of your LAN
 */
function getIp() {
	var ip = []
	for (var k in network) {
		var inter = network[k]
		for (var j in inter)
			if (inter[j].family === 'IPv4' && !inter[j].internal) {
				return inter[j].address
			}
	}
}