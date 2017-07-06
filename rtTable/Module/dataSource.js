function subSystemsName(serverUrl,model,finished){
    var xhr = new XMLHttpRequest();
    var url = serverUrl+"/api/index.php?c=all&t=info"
    console.log(url)
    xhr.open("POST",url,true);
    xhr.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    xhr.send(null);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED){
            //console.log(xhr.getAllResponseHeaders())
        }
        if (xhr.readyState === XMLHttpRequest.DONE) {
            //console.log( "subSystemsName" + xhr.responseText)
            try{
                var res = JSON.parse( xhr.responseText.trim() )
            }catch(e){
                console.log(e)
                return;
            }
            var i;
            for(i=0; i<res.length; i++){
                model.append( {
                                 text: res[i].class_name,
                                 number: res[i].class_pointnum,
                                 description: res[i].description
                             } )
            }
            finished()
        }
    }
}

function loadTagInfo(serverUrl,model,subsystem,offset,number,finished){
    var xhr = new XMLHttpRequest();
    var url = serverUrl+"/api/index.php?c="+ encodeURIComponent(subsystem) +"&t=info&o="+offset+"&n="+number
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
            var i;
            for(i=0; i<res.length; i++){
                model.append( {
                                 index: i,
                                 description: res[i].description,
                                 id: res[i].id,
                                 point_name: res[i].point_name,
                                 type: res[i].type,
                                 uint: res[i].uint,
                                 value: "",
                                 lastUpdateTime: ""
                             } )
            }
            finished(i)
        }
    }
}

function loadTagValue(serverUrl,model,subsystem,offset,number){
    var xhr = new XMLHttpRequest();
    var url = serverUrl+"/api/index.php?c="+ encodeURIComponent(subsystem) +"&t=value&o="+offset+"&n="+number
    //console.log(url)
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
            for(var i in res){
                for(var j=0; j<model.count; j++){
                    if(model.get(j).id === res[i].id){
                        model.setProperty(j,"value", res[i].value)
                        model.setProperty(j,"lastUpdateTime", Date() )
                    }
                }
            }
        }
    }
}
