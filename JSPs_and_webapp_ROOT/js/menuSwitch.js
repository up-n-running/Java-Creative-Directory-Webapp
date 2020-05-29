var dev_menuSwitch = "1.0";	// Version of menuSwitch.js

var straps = new Array();
straps["extSite"]    = "website content control";
straps["extSell"]    = "powerful e-commerce";
straps["extPress"]   = "24-hour press office solution";
straps["extCat"]     = "powerful catalogue management";
straps["extDirect"]  = "e-mail direct marketing system";
straps["extTracked"] = "automated sales reporting solutions";

var currentMenu = "";

function setMenu( prod )
{
  if( parent.head )
  {
    parent.head.document.body.className = prod + "Head";
    parent.head.document.getElementById( "headStrapText" ).innerHTML = straps[prod];
  }

  if( parent.menu )
  {
    parent.menu.document.body.className = prod + "Menu";
    parent.menu.document.getElementById( "menuHead" ).className = prod + "MenuHead";
    parent.menu.document.getElementById( currentMenu + "Menu" ).style.display = "none";
    parent.menu.document.getElementById( prod + "Menu" ).style.display = "block";
    currentMenu = prod;
  }
}
