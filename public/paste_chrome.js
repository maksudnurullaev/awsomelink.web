var currentPasteType = "blob";
var editBody;
var pasteColector;
var imagesBeforePaste = 0;

$( document ).ready(function() {
    if( document.getElementById('pasteImageHolder') ){
        setupPasteFeatures();
    }
});

function setupPasteFeatures(){
    editBody = document.getElementById('pasteImageHolder');
    editBody.addEventListener('paste', handlePaste);
    pasteColector = document.getElementById('pasteCollector');
};

function handlePaste(evt) {
    var cbData;
    if (evt.clipboardData) {
        cbData = evt.clipboardData;
    } else if (window.clipboardData) {
        cbData = window.clipboardData;      
    }
    switch (currentPasteType) {
        case "no script":
            console.info("paste handler is using default paste with no paste script running");
            imagesBeforePaste = editDocument.querySelectorAll('img').length;
            //setTimeout(setMessageForDefault, DEFAULT_PASTE_TIMEOUT);
            // do nothing in paste handler, so browser does whatever is default
            break;
        case "blob":
            console.info("paste handler is using blob conversion");
            if (evt.msConvertURL) {
                var fileList = cbData.files;
                if (fileList.length > 0) {
                    for (var i = 0; i < fileList.length; i++) {
                        var file = fileList[i];
                        var url = URL.createObjectURL(file);
                        evt.msConvertURL(file, "specified", url);
                    }
                    //setTimeout(function () {setMessageForNonDefault("success"); }, DEFAULT_PASTE_TIMEOUT);
                } else {
                    //setTimeout(function () {setMessageForNonDefault("no image"); }, DEFAULT_PASTE_TIMEOUT);     
                }
            } else 
            if (cbData.items) {
                var itemList = cbData.items;
                if (itemList.length > 0) {
                    var foundImage = false;
                    for (var i = 0; i < itemList.length; i++) {
                        if (-1 != itemList[i].type.indexOf('image')) {
                            var file = itemList[i].getAsFile();
                            var url = URL.createObjectURL(file);
                            pasteCollector.innerHTML += '<div class="col-xs-6 col-md-3"><a href="#" class="thumbnail"><img src="' + url + '"></a></div>';
                            foundImage = true;
                            break;
                        }
                    }                   
                    if (foundImage) {
                        evt.preventDefault();
                        //setTimeout(function () {setMessageForNonDefault("success"); }, DEFAULT_PASTE_TIMEOUT);
                    } else {
                        //setTimeout(function () {setMessageForNonDefault("no image"); }, DEFAULT_PASTE_TIMEOUT);     
                    }
                } else {
                    //setTimeout(function () {setMessageForNonDefault("no image"); }, DEFAULT_PASTE_TIMEOUT);     
                }
            } else {
                    //setTimeout(function () {setMessageForNonDefault("failure"); }, DEFAULT_PASTE_TIMEOUT);  
                evt.preventDefault();
                return false;
            }
            break;
        default:
            console.error("invalid paste type in handlePaste: " + currentPasteType);
    }
    //setTimeout(updateMarkup, DEFAULT_PASTE_TIMEOUT);
};
