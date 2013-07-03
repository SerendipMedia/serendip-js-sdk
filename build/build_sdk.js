({
    baseUrl : "../target",
    paths : {
        requireLib : "../target/require",
        jquery : 'jquery-1.10.1.min'
    },
    include : "requireLib",
    name : "sdk",
    generateSourceMaps : true,
    preserveLicenseComments : false,
    optimize : 'uglify2',
    out : "../lib/sdk.js"
})
