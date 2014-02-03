#!/usr/bin/env node

/*jslint node: true */
'use strict';

var program = require('commander'),
    path = require('path'),
    spawn = require('child_process').spawn,
    pkginfo  = require('pkginfo');

pkginfo(module, 'name', 'version');

program
  .version(module.exports.version, '-v, --version')
  .description('RapidDev CLI')
  .usage('COMMAND [OPTIONS]');

program.command('install')
    .description('install a titanium cli  plugin that adds the --rapiddev flag to iOS compiles')
    .action(function() {
        console.log('Installing titanium stuff...');

        console.log('--- Installing Plugin(s) ---');
        exec('ti', ['config', '-a', 'paths.hooks', path.join( __dirname , 'plugin','rapiddev','hooks')], null, function(logs) {
            console.log(logs);
            console.info("Titanium CLI hook installed. Installing module...");

            console.log('--- Installing Module(s) ---');
            exec('ti', ['config', '-a', 'paths.modules', path.join( __dirname , 'module')], null, function(output) {
                console.log(output);
                console.info("//// NOTICE! ////");
                console.info("RapidDev installed. Now use the command `--rapiddev` on any ios builds to build the app and start the server.\nDo this on the first app if installing on more then one device/simulator and start the rest from another terminal.");
                console.info("/////////////////\n\n");
            });
        });
});

program.parse(process.argv);
// Display help on an invalid command
if (program.args.length === 0 || typeof program.args[program.args.length -1] === 'string'){
    program.help();
}


function exec(cmd, args, opts, callback) {

  if (process.platform === 'win32') {
    args = ['/c', cmd].concat(args);
    cmd = process.env.comspec;
  }

  opts = opts || {};

  if (!opts.stdio && !opts.capture) {
    opts.stdio = 'inherit';
  }

  var s = spawn(cmd, args, opts);
  var output;

  if (opts.stdio !== 'inherit') {
    s.stderr.pipe(process.stderr);
  }

  if (opts.capture) {
    output = '';
    s.stdout.on('data', function(data) {
      output += data.toString();
    });

  } else {

    if (opts.stdio !== 'inherit') {
      s.stdout.pipe(process.stdout);
    }

    output = null;
  }

  s.on("exit", function() {
    callback(output);
  });

  return s;
}