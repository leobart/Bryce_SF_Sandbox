/* 
 * Usage:
 * import this JS in your page
 * create         
  function endSession() {
      some actions here...
  }
  
  Add for document ready:
  
          $j(document).ready(function() {
            try{
          	   wireUpEvents();  
            }catch(e){
            }            
        });

  
 */
var validNavigation = false;
                  
        function wireUpEvents() {
          window.onbeforeunload = function() {
              if (!validNavigation) {
                 endSession();
              }
          }
         
          // Attach the event keypress to exclude the F5 refresh
          $j(document).bind('keypress', function(e) {
            if (e.keyCode == 116){
              validNavigation = true;
            }
          });
         
          // Attach the event click for all links in the page
          $j("a").bind("click", function() {
            validNavigation = true;
          });
         
          // Attach the event submit for all forms in the page
          $j("form").bind("submit", function() {
            validNavigation = true;
          });
         
          // Attach the event click for all inputs in the page
          $j("input[type=submit]").bind("click", function() {
            validNavigation = true;
          });
           
        }
