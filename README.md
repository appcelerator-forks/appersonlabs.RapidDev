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


__Some notes and limitations__

 * Only files in the Resources directory will be sent to the device
   using RapidDev.
 * Native modules work just fine, you will just need to rebuild the app directly first as iOS does not support adding native code durring runtime
 * Custom fonts will be loaded if placed in the `Resources/fonts`
   directory for iOS only.


Feedback appreciated.

@appersonlabs
