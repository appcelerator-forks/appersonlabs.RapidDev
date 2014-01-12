#!/usr/bin/env node

var program = require('commander'),
    fs = require('fs'),
    path = require('path'),
    pkginfo  = require('pkginfo'),
    exec = require('execSync').exec;

pkginfo(module, 'name', 'version');

program
  .version(module.exports.version, '-v, --version')
  .description('TiShadow CLI')
  .usage('COMMAND [OPTIONS]');

program.command('install')
    .description('install a titanium cli  plugin that adds the --rapiddev flag to iOS compiles')
    .action(function() {
        console.log('Installing titanium stuff...');
        var ret = exec('ti config -a paths.hooks ' + path.join( __dirname , 'plugin','rapiddev','hooks'));
        console.log(ret.stdout);

        console.info("Titanium CLI hook installed. Installing module...");

        var ret2 = exec('ti config -a paths.modules ' + path.join( __dirname , 'module'));
        console.log(ret2.stdout);

        console.info("//// NOTICE! ////");
        console.info("RapidDev installed. Now use the command `--rapiddev` on any ios builds to build the app and start the server.\nDo this on the first app if installing on more then one device/simulator and start the rest from another terminal.");
        console.info("/////////////////\n\n");
});

program.parse(process.argv);
    // Display help on an invalid command
    if (program.args.length === 0 || typeof program.args[program.args.length -1] === 'string'){
    program.help();
}
