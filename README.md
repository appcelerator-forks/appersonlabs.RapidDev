RapidDev
========

Rapid dev is a system of a native Titanium module, a build plugin, and a NodeJS socket server for Titanium mobile to allow for real time code reloads the moment the local file system of your machine takes place.

The primary goal of this project is to allow for the above functions without any extra compile step or manual changes on the users part that would alter the JS code of their application. This project does not in any way inject JS code, mutate it, remove it or in any way affect it.


Getting Started
===============

RapidDev Install
----------------

### RapidDev NPM Package

RapidDev is built on [node.js](http://nodejs.org/) and is required.

RapidDev can be installed via npm using the following command:

```
  sudo npm install rapiddev -g
```

Or if you want to use the master version directly from GitHub:

```
  sudo npm install -g appersonlabs/rapiddev
```

RapidDev usage
----------------
To use RapidDev, simply run any titanium 3.2 SDK based application and add the --rapiddev flag, like so:

```
  ti build -p ios --rapiddev
```

We will shortly be adding a studio plugin to make this even easier.

Now to switch back to a non-rapiddev enabled app, build your app as you normaly would without the --rapiddev flag

Development Files
----------------
In your app's project root, you can create a directory called `RapidDev`. The contents of this directory will be copied into your build whenever you are using the `--rapiddev`, or `--test` flags. This of this as Titaniums platform directories, but just for development. This is perfect for unit test files that should never end up in a production app.

Running unit tests
----------------
As part of RapidDevs "m.o." This is less auto-magical then some other solutions. So maybe you like this maybe you don't. We are open to feedback so raise a ticket if you feel this is too verbose.

To run unit tests using whatever library you want, simply add a "tests" tag in your TiApp.xml file with an array of key/values of js files in your project. For example:

```
    <tests>
        <default>/tests/app_test.js</default>
        <login>/tests/login.js</login>
    </tests>
```

These files will then be able run when you add the --test flag to your build command, so if for example you call `ti build -p ios --test login`, /tests/login.js would run INSTEAD of app.js! If no test name is given, the `default` test will run. We feel it is important to not also run app.js in order to run clean tests vs running over top of your app.
This test file can include any testing library you like, and are setup acording to that testing libraries specs as if RapidDev was not being used.

You can run tests with or without the --rapiddev flag. But if you use the 2 together, the tests will auto run for you on every file change in your app!


__Some notes and limitations__

 * Only files in the Resources directory will be sent to the device
   using RapidDev.
 * Native modules work just fine, you will just need to rebuild the app directly first as iOS does not support adding native code durring runtime
 * Custom fonts will be loaded if placed in the `Resources/fonts` directory.


Feedback appreciated.

@appersonlabs
