require.config({
    paths : {
        jquery : 'jquery-1.10.1.min',
        facebook_sdk : '//connect.facebook.net/en_US/all'
    },
    shim :{
        'jstorage' : ['jquery'],
        'facebook_sdk' : {
            export: 'FB'
        }
    }
})

require(['cs!fb']);