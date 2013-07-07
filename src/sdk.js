(function(){
    var iframe = document.createElement('iframe');
    iframe.style.display = "none";
    iframe.src = 'http://local.serendip.me/sdk.html'
    iframe.src += "#origin="
    if (document.location.origin == null)
        iframe.src += (document.location.protocol + "//" + document.location.hostname)
    else
        iframe.src += document.location.origin
    window.SRNDP_FB_IFRAME = iframe
    document.body.appendChild(iframe);
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
