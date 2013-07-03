(function(){
    var iframe = document.createElement('iframe');
    iframe.style.display = "none";
    iframe.src = 'http://developers.serendip.me/sdk.html'
    iframe.src += "#origin="
    if (document.location.origin == null)
        iframe.src += (document.location.protocol + "//" + document.location.hostname)
    else
        iframe.src += document.location.origin
    document.body.appendChild(iframe);
//     listen to srnd ready message
    onSRNDPMsg = function(event) {
        if (event.origin.indexOf("developers.serendip.me") == -1) return;
        switch (event.data) {
            case "serendip-sdk-ready": onSrndpReady();
            break;
        }
    }
    window.addEventListener("message", onSRNDPMsg, false);
}());

require.config({
    paths : {
        jquery : 'jquery-1.10.1.min'
    },
    shim :{
        'jstorage' : ['jquery']
    }
});

require(['cs!main']);
