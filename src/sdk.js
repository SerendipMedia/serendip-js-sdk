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
    },
    config : {
        'cs!settings' : {
            env : 'prod',
            'dev' : {
                SECURE_PROTOCOL : "http://",
                BASE_API_URL : "localapi.serendip.me:9000/v1",
                BASE_URL : "http://local.serendip.me",
                FB_APP_ID : '180530865322766',
                SESSION_COOKIE_NAME : 'PLAY_SESSION'
            },
            'prod' : {
                SECURE_PROTOCOL : "https://",
                BASE_API_URL : "api.serendip.me/v1",
                BASE_URL : "http://serendip.me",
                FB_APP_ID : '180530865322766',
                SESSION_COOKIE_NAME : 'PLAY_SESSION'
            }
        }
    }
});

require(['cs!main']);
