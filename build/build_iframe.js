({
    baseUrl : "../target",
    paths : {
        requireLib : "../target/require",
        jquery : 'jquery-1.10.1.min',
        facebook_sdk : 'https://connect.facebook.net/en_US/all'
    },
    include : "requireLib",
    name : "iframe",
//    generateSourceMaps : true,
    preserveLicenseComments : false,
//    optimize : 'uglify2',
    out : "../lib/iframe.js"
})
