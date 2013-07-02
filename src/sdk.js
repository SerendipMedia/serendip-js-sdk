require.config({
    paths : {
        jquery : 'jquery-1.10.1.min'
    },
    shim :{
        'jstorage' : ['jquery']
    }
})

require(['cs!main']);