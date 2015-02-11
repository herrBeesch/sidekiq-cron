$(function () {
  var routeSearch = function(){
    var argsString =  "";
    if ($( "#tagSearchInput" ) && $( "#tagSearchInput" ).val()){
      argsString = $( "#tagSearchInput" ).val().replace(/ /g, '.');
    }
    // var currentURL = window.location;
    // window.location.href = currentURL.protocol +  currentURL.host + '/sidekiq/cron/' + argsString;
    if (argsString.length == 0){
      window.location.pathname = '/sidekiq/cron';
    }
    else {
      window.location.pathname = '/sidekiq/cron/' + argsString;
    }
  };
  $( "#tagSearchSubmit" ).bind({ 
    click: function(){
      routeSearch();
    }
  });
  $( ".search-tag" ).bind({ 
    click: function(){
      tag = $(this).data('tag');
      if (window.location.pathname.split('/')[window.location.pathname.split('/').length-1] == "cron"){
        window.location.pathname = window.location.pathname + '/' + tag;
      }
      else {
        window.location.pathname = window.location.pathname + '.' + tag;
      }
    }
  });
  $( "#tagSearchInput" ).bind({ 
    keyup: function(e){
      var code = e.keyCode || e.which;
      if(code == 13) { //Enter keycode
        routeSearch();
       }
    }
  });
  
})
