
function subSystemsName(serverUrl, process){
    var xhr = new XMLHttpRequest();
    var url = serverUrl+"/admin2.php?m=dcappinterface&f=getpointlist&c=all&type=info"
    console.log(url)
    xhr.open("POST",url,true);
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    xhr.send(null);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED){
            //console.log(xhr.getAllResponseHeaders())
        }
        if (xhr.readyState === XMLHttpRequest.DONE) {
            console.log( "subSystemsName:" + xhr.responseText)
//            var ret;
//            AES.decrypt(xhr.responseText.trim(), ret, 1)
//            console.log( "subSystemsName Decryption:" + ret)
            try{
                var res = JSON.parse( xhr.responseText.trim() )
            }catch(e){
                console.log(e)
                return;

            }
            process(res)
        }
    }
}

function loadTagInfo(serverUrl,subsystem,offset,number,process){
    var xhr = new XMLHttpRequest();
    var url = serverUrl+"/admin2.php?m=dcappinterface&f=getpointlist&c="+
            encodeURIComponent(subsystem) +"&type=info&o="+offset+"&n="+number
    console.log(url)
    xhr.open("POST",url,true);
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    xhr.send(null);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED){
            //console.log( "loadTagInfoResponseHeaders" + xhr.getAllResponseHeaders())
        }
        if (xhr.readyState === XMLHttpRequest.DONE) {
            //console.log( "loadTagInfoResponseText" + xhr.responseText)
            try{
                var res = JSON.parse( xhr.responseText.trim() )
            }catch(e){
                console.log(e)
                return;
            }
            process(res)
        }
    }
}

function loadTagValue(serverUrl,subsystem,offset,number,process){
    var xhr = new XMLHttpRequest();
    var url = serverUrl+"/admin2.php?m=dcappinterface&f=getpointlist&c="+
            encodeURIComponent(subsystem) +"&type=value&o="+offset+"&n="+number
    console.log(url)
    xhr.open("POST",url,true);
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    xhr.send(null);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED){
            //console.log( "loadTagValueResponseHeaders" + xhr.getAllResponseHeaders())
        }
        if (xhr.readyState === XMLHttpRequest.DONE) {
            //console.log( "loadTagValueResponseText" + xhr.responseText)
            try{
                var res = JSON.parse( xhr.responseText.trim() )
            }catch(e){
                console.log(e)
                return;
            }
            process(res);
        }
    }
}
