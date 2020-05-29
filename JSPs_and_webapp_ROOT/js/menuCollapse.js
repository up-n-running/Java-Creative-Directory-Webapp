var def_menuCollapse = "1.0";		// The Version of menuCollapse.js

var menuCollapserClass = "menuGroupCollapser"
var menuOpenClass      = "menuGroupTitleO";
var menuClosedClass    = "menuGroupTitleC";

function menuGroupToggle( ev )
{
  var group;

  if( typeof( ev ) == "undefined" )
  {
    ev = event;
  }

  if( typeof( ev.target ) == "undefined" )
  {
    group = ev.srcElement;
  }
  else
  {
    group = ev.target;
  }

  menuName = group.id.substring( 0, group.id.indexOf( "collapser" ) );

  if( menuName == "" )
  {
    menuName = group.id.substring( 0, group.id.indexOf( "title" ) );
  }

  titleBar = getElt( menuName + "title" );
  linksBox = getElt( menuName + "links" );

  if( titleBar.className == menuOpenClass )
  {
    linksBox.style.display = "none";
    titleBar.className = menuClosedClass;
  }
  else
  {
    linksBox.style.display = "block";
    titleBar.className = menuOpenClass;
  }
}

function setupMenus()
{
  divList = document.getElementsByTagName( "a" );

  for( var i = 0 ; i < divList.length ; i++ )
  {
    if( divList[i].className == menuCollapserClass )
    {
      divList[i].onclick = menuGroupToggle;
    }
  }

  loaded = true;
}

onload=setupMenus;
