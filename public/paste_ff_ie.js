var editBody;
var pasteColector;
var imagesBeforePaste = 0;
var editDocument;
var editBody;
var re = /^data:image\/(\w+);base64/ ;

$(function() {
    $('#form_paste').submit(function() {
        // DO STUFF
        submitPasteForm();
        return true; // return false to cancel form action
    });
});

function submitPasteForm(){
    var allImages = $('img', editBody);
    for (var i=0;i<allImages.length;i++){
        var img = allImages[i];
        var src_head = img.src.substring(0,50);
        var result = src_head.match(re);
        if( result ){
            var type = result[1];
            addImageData2Form(img.src, type);
        }
    }
};
    
function setupPasteFeatures(){
    editDocument = document.getElementById('editFrame').contentDocument;
    editBody = editDocument.body;
};

function uniqueTime(){
   return( new Date().getTime()) ;
};

function addImageData2Form(src, type){
    var name = "";
    name = name.concat('screenshot_',uniqueTime(),'_', getNextImageIndex(),'.',type); 
    var form_paste = document.forms[0]; 
    var x = document.createElement("input");
    x.setAttribute("name", name);
    x.setAttribute("type","hidden");
    x.setAttribute("value",src);
    form_paste.appendChild(x); //you said Appended to the form.
};

function getNextImageIndex(){
    var imgs = $('img', editBody);
    return(imgs.length);
};
