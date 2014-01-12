var win = Ti.UI.createWindow({
  backgroundColor:'red'
});

win.addEventListener('click', function() {
    Ti.App._restart();
})
alert('win2');

module.exports = win;