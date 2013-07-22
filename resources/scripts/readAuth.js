var hash = window.location.hash;
if (hash == "")
    hash = window.location.href.split("?")[1]
hash = decodeURIComponent(hash);
obj = {};
if (typeof hash != 'undefined') {
    if (hash.indexOf("#") != -1) hash = hash.substring(1);
    hashArr = hash.split('&');
    for (i = 0; i < hashArr.length; i++) {
        paramPair = hashArr[i].split('=');
        obj[paramPair[0]] = paramPair[1];
    }
    origin = obj["origin"];
    delete obj["origin"];
    chrome.runtime.sendMessage(obj)
    window.close();
}