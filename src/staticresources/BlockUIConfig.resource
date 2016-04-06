     $j = jQuery.noConflict();  
     //function to block the whole page  
     function blockPage(){   
       $j.blockUI({ message: '<img src="/img/loading32.gif" /><h1> Processing...</h1>',   
         css: {   
          border: 'none',   
          padding: '15px', 
          '-webkit-border-radius': '10px',   
          '-moz-border-radius': '10px',   
          top:  ($j(window).height() - 100) /2 + 'px', 
          left: ($j(window).width() - 100) /2 + 'px', 
          width: '100px', 
          opacity: .8},
         overlayCSS: { opacity: .2 }
       });   
       return false;  
     }  
     //function to unblock the page  
     function unblockPage(){  
       $j.unblockUI();  
     }  
     
