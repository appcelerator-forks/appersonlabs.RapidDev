// open a single window
var win = Ti.UI.createWindow({
    backgroundColor:'red'
});

alert('bong!');
// Ti.App.addEventListener('test', function() {
//     alert('called!');
// });

Ti.App.fireEvent('test', {});
//win.add(image);
var label = Ti.UI.createLabel();
win.add(label);
win.open();