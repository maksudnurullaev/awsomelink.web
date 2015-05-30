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
    if (cbData.items) {
        var itemList = cbData.items;
        if (itemList.length > 0) {
            for (var i = 0; i < itemList.length; i++) {
                if (-1 != itemList[i].type.indexOf('image')) {
                    var file = itemList[i].getAsFile();
                    addImageData2Form(file,itemList[i].type);
                    // 2. view as thumbnails
                    var url = URL.createObjectURL(file);
                    pasteCollector.innerHTML += '<div class="col-xs-6 col-md-3"><a href="#" class="thumbnail"><img src="' + url + '"></a></div>';
                    break;
                }
            }                   
        } else {
            console.info("ERROR! Not 'cbData.items' supported!");
        }
    } 
};

function uniqueTime(){
   return( new Date().getTime()) ;
};

function addImageData2Form(file, type){
    var types = type.split("/");
    var name = "";
    name = name.concat('screenshot_',uniqueTime(),'_', getNextImageIndex(),'.',types[1]); 
    var reader = new FileReader();
    reader.onload = function(event){ blobImageLoaded(event,name) };
    reader.readAsDataURL(file);//Convert the blob from clipboard to base64
};

function blobImageLoaded(event,name){
    console.log(event.target.result); //event.target.results contains the base64 code to create the image.
    var form_paste = y = document.forms[0]; 
    var x = document.createElement("input");
    x.setAttribute("name", name);
    x.setAttribute("type","hidden");
    x.setAttribute("value",event.target.result);
    form_paste.appendChild(x); //you said Appended to the form.
};

function getNextImageIndex(){
    var imgs = $("#pasteCollector img");
    return(imgs.length + 1);
};

