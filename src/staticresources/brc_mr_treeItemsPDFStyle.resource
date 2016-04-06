body { 
    /*font-family: 'Arial Unicode MS';*/
    font-family: Arial, Arial Unicode MS, sans-serif;
}

.sumTableHeader{
    background: #6C8B94;
    height: 25px;
    vertical-align: middle;
    color: #FFFFFF;
    font-size: 10pt; 
    padding-left: 10px;
    font-weight: bold;
} 

.sumTableHeader:first-of-type{
    border-radius: 6px 0px 0px 6px;
}

.sumTableHeader:last-of-type{
    border-radius: 0px 6px 6px 0px;
}

.sumTableFooter{
    vertical-align: middle;
    border-top: solid 1px #757575;
    font-weight: bold;
    font-size: 11pt; 
    padding-left: 10px;
    height: 25px;
}

.sumTableRow, .sumTableSubRow{
    height: 25px;
    vertical-align: middle;
    border-bottom: solid 1px #C3BDBD;
    font-size: 10pt;
    padding-left: 10px;
}

.sumTableRow:first-of-type{
    font-weight:bold;
    text-align: left;
}

.sumTableSubRow{
    height: 18px;
    font-style: italic;
}

.sumTableSubRow:first-of-type{
    padding-left:30px;
    text-align: left;
}

.sumTableRow, .sumTableSubRow, .sumTableFooter, .sumTableHeader{
    padding-right: 10px;
    text-align: center;    
}
.sumTableRow:last-of-type, .sumTableFooter:last-of-type, .sumTableHeader:last-of-type{
    text-align: right;
	font-weight: bold;    
}

.sumTableSubRow:last-of-type{
    text-align: left;        
}

.sumTableFooter:first-of-type{
    text-align: left;    
}

@page{
	size:A4 portrait;
    
    margin-top: 1cm;
 	margin-bottom: 1cm; 
 	margin-left: 2cm; 
 	margin-right: 1cm; 
             
	@bottom-right {
		content: "Page " counter(page);
		font-family: 'Arial', 'Helvetica', sans-serif;
		font-size:10px;
	}
}        

.reportWidth{
    width: 17.5cm;
}

.tdLevel1Left, .tdLevel1Right {
	font-weight: bold;
    background: #E9DCA7;
    height: 25px;
    vertical-align: middle;
    font-size: 10pt;
    padding-left: 15px;
    padding-right: 15px;
}  
        
.tdLevel1Left{
	border-radius: 6px 0px 0px 6px;
}
            
.tdLevel1Right{
	border-radius: 0px 6px 6px 0px;
    text-align: right;
}

td.tdLevel2, td.tdLevel3, td.tdLevel4, td.tdLevel5{
	vertical-align: middle;
    padding-left: 15px;
    padding-right: 15px;        
    border-bottom: solid 1px #BDB9B9;
    height: 25px;
}
      
td.tdLevel2{
	font-size: 10pt;
	font-weight: bold;
    border-bottom: solid 1px #999090;
}
            
td.tdLevel3{
	font-size: 9pt;
	font-weight: bold;
	font-style: italic;
}  

td.tdLevel4, td.tdLevel5{
	font-size: 8pt;
    border-bottom: solid 1px #D7D7D7;
} 

td.tdLevel4{
    color: rgb(75, 113, 247);
}

td.tdLevel5{
    color: rgb(149, 138, 138);
}

.titleClass{
    font-weight:bold; 
    font-size: 14pt; 
    margin-left: 2.5cm;
    color: #575757;
}

.tdTitleClass{
    vertical-align:middle; 
    padding-bottom: 0.4cm;
}

td.currencytTdHeader{
    font-size: 11pt;
    font-weight: bold;
    text-align: center;
    vertical-align: middle;
    border-bottom: solid 1px #C6BDBD;
    height: 20px;}

td.currencyTdValue{
    text-align: center;
    padding: 4px;
    font-size: 10pt;
    /*font-weight: bold;*/    
}

.currencyHeader{
    font-size: 15pt;
    margin-left: 15px;
    margin-bottom: 10px;    
}

