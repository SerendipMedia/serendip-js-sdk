require.config({
    paths : {
        jquery : 'jquery-1.10.1.min',
        facebook_sdk : 'https://connect.facebook.net/en_US/all'
    },
    shim :{
        'jstorage' : ['jquery'],
        'jquery.cookie' : ['jquery'],
        'facebook_sdk' : {
            export: 'FB'
        }
    },
    config : {
        'cs!settings' : {
            env : 'prod',
            logging : false,
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
})

require(['cs!srndp_router']);