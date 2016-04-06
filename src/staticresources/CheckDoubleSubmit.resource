    	$j = jQuery.noConflict();
    	var isClicked = false;
        function checkDoubleSubmit(){
        	if (isClicked) {
            	return false;
            }else {
            	isClicked = true;
                blockPage();
                $j("[id*='CmdBtnGrp']").addClass("btnDisabled");
                $j("[id*='CmdBtnGrp']").val("Processing...");
                return true;
            }
        }
