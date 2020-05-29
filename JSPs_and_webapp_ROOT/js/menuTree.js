var def_menuTree = "2.0";	// The verssion of menuTree.js

// Tuning variables, set these in your own scripts if you want to change them

var menuOffsetVert   =   5;	// Defines offset of sub menu from top of parent element
var menuOffsetHoriz  = -10;	// Defines offset of sub menu from right of parent element
var classTopAdd      = "T";	// Extension to menu item style class names for top menu item
var classBottomAdd   = "B";	// Extension to menu item style class names for bottom menu item
var closeTimeout     =  10;	// Time in milliseconds before a menu will close

var pageBorders = new Array( 5, 5, 5, 5 );	// Space to leave at the top, right, bottom, left of a page when a menu pops up

// Reference variables, use these in your scripts

var menuTypeVert  = "V";	// Defines a vertical menu
var menuTypeHoriz = "H";	// Defines a horizontal menu

var showBorderTop    = 1;	// Border type value to set top border on
var showBorderRight  = 2;	// Border type value to set right border on
var showBorderBottom = 4;	// Border type value to set bottom border on
var showBorderLeft   = 8;	// Border type value to set left border on

var pageBorderTop    = 0;	// Position of top border in pageBorders array
var pageBorderRight  = 1;	// Position of right border in pageBorders array
var pageBorderBottom = 2;	// Position of bottom border in pageBorders array
var pageBorderLeft   = 3;	// Position of left border in pageBorders array

// shouldn't need to edit past here

var idLevelSep      = ".";	// The character to separate menu levels in ids
var menuLayerIdAdd  = "_M";	// Id extension to designate a sub menu layer
var menuTableIdAdd  = "_T";	// Id extension to designate menu item table
var menuItemIdAdd   = "_I";	// Id extension to designate a menu item

var topLevelMenus = new Array();	// Convenience variable to access top level menus

var hideTimeout = new Array();	// Collection of timeouts hashed on menuItemId;

var roundabout = 0;		// Recursion preventer (DEBUG DEBUG)

function menuBorder( type, artDir, n, nne, ne, ene, e, ese, se, sse, s, ssw, sw, wsw, w, wnw, nw, nnw )
{
  this.type   = type;
  this.n      = ( ( typeof( n   ) != "undefined" ) ? artDir + n   : '' );
  this.nne    = ( ( typeof( nne ) != "undefined" ) ? artDir + nne : '' );
  this.ne     = ( ( typeof( ne  ) != "undefined" ) ? artDir + ne  : '' );
  this.ene    = ( ( typeof( ene ) != "undefined" ) ? artDir + ene : '' );
  this.e      = ( ( typeof( e   ) != "undefined" ) ? artDir + e   : '' );
  this.ese    = ( ( typeof( ese ) != "undefined" ) ? artDir + ese : '' );
  this.se     = ( ( typeof( se  ) != "undefined" ) ? artDir + se  : '' );
  this.sse    = ( ( typeof( sse ) != "undefined" ) ? artDir + sse : '' );
  this.s      = ( ( typeof( s   ) != "undefined" ) ? artDir + s   : '' );
  this.ssw    = ( ( typeof( ssw ) != "undefined" ) ? artDir + ssw : '' );
  this.sw     = ( ( typeof( sw  ) != "undefined" ) ? artDir + sw  : '' );
  this.wsw    = ( ( typeof( wsw ) != "undefined" ) ? artDir + wsw : '' );
  this.w      = ( ( typeof( w   ) != "undefined" ) ? artDir + w   : '' );
  this.wnw    = ( ( typeof( wnw ) != "undefined" ) ? artDir + wnw : '' );
  this.nw     = ( ( typeof( nw  ) != "undefined" ) ? artDir + nw  : '' );
  this.nnw    = ( ( typeof( nnw ) != "undefined" ) ? artDir + nnw : '' );
}

function menuItem( name, text, href, onStyle, offStyle, size, fade, menuClass, doNumber, onMouseOver, onMouseOut )
{
  this.name = name;
  this.orient = menuTypeVert;
  this.size = size;
  this.menuClass = menuClass;
  this.doNumber = doNumber;
  this.onMouseOver = onMouseOver;
  this.onMouseOut = onMouseOut;

  this.border = null;

  this.text = text;
  this.href = href;
  this.onStyle = onStyle;
  this.offStyle = offStyle;
  this.fade = ( ( fade == null ) ? 100 : fade );

  this.items = new Array();
}

function mainMenu( name, orient, size, menuClass, doNumber, onMouseOver, onMouseOut )
{
  this.name = name;
  this.orient = orient;
  this.size = size;
  this.menuClass = menuClass;
  this.doNumber = doNumber;
  this.onMouseOver = onMouseOver;
  this.onMouseOut = onMouseOut;

  this.border = null;

  this.items = new Array();
}

function setBorder( item, border )
{
  item.border = border;
}

function addItem( item, name, text, href, onStyle, offStyle, subMenSize, fade, menuClass, doNumber, onMouseOver, onMouseOut )
{
  var posn = item.items.length;
  item.items[posn] = new menuItem( name, text, href, onStyle, offStyle, subMenSize, fade, menuClass, doNumber, onMouseOver, onMouseOut );
  return posn;
}

function findItem( item, name )
{
  var i;
  var dotPos = name.indexOf( idLevelSep );

  if( typeof( item.length ) == "number" )	// We have the topLevelMenus array here, we need to find the menu
  {
    if( dotPos != -1 )				// Dotted sub-menu item, find this on the top level menu
    {
      name1 = name.substring( 0, dotPos );
      name2 = name.substring( dotPos + 1, name.length );

      return findItem( item[name1], name2 );
    }

    return item[name];				// Just the top level menu name, return it
  }

  if( name == "" )
  {
    return item;
  }

  if( dotPos != -1 )
  {
    name1 = name.substring( 0, dotPos );
    name2 = name.substring( dotPos + 1, name.length );

    return findItem( findItem( item, name1 ), name2 );
  }

  for( i = 0 ; i < item.items.length ; i++ )
  {
    if( item.items[i].name == name )
    {
      return item.items[i];
    }
  }

  return null;
}

function renderBorderTL( menuVar )
{
  var border = menuVar.border;

  if( border != null && border.type != 0 )
  {
    dp( '<table border="0" cellpadding="0" cellspacing="0">\n' );

    if( ( border.type & showBorderTop ) != 0 )
    {
      dp( '<tr>\n' );

      if( ( border.type & showBorderLeft ) != 0 )
      {
        dp( '  <td>' + ( ( border.nw != "" ) ? '<img src="' + border.nw + '" />' : '' ) + '</td>\n' );
      }

      dp( '  <td style="background-image: url(\'' + border.n + '\'); background-repeat: repeat-x; text-align: left">'  + ( ( border.nnw != "" ) ? '<img src="' + border.nnw + '" />' : '' ) + '</td>\n' );
      dp( '  <td style="background-image: url(\'' + border.n + '\'); background-repeat: repeat-x; text-align: right">' + ( ( border.nne != "" ) ? '<img src="' + border.nne + '" />' : '' ) + '</td>\n' );

      if( ( border.type & showBorderRight ) != 0 )
      {
        dp( '  <td>' + ( ( border.ne != "" ) ? '<img src="' + border.ne + '" />' : '' ) + '</td>\n' );
      }

      dp( '</tr>\n' );
    }

    dp( '<tr>\n' );

    if( ( border.type & showBorderLeft ) != 0 )
    {
      dp( '  <td style="background-image: url(\'' + border.w + '\'); background-repeat: repeat-y; vertical-align: top">'  + ( ( border.wnw != "" ) ? '<img src="' + border.wnw + '" />' : '' ) + '</td>\n' );
    }

    dp( '  <td colspan="2" rowspan="2">\n' );
  }
}

function renderBorderBR( menuVar )
{
  var border = menuVar.border;

  if( menuVar.border != null && menuVar.border.type != 0 )
  {
    dp( '</td>\n' );

    if( ( border.type & showBorderRight ) != 0 )
    {
      dp( '  <td style="background-image: url(\'' + border.e + '\'); background-repeat: repeat-y; vertical-align: top">'  + ( ( border.ene != "" ) ? '<img src="' + border.ene + '" />' : '' ) + '</td>\n' );
    }

    if( ( border.type & showBorderLeft ) != 0 || ( border.type & showBorderRight ) != 0 )
    {
      dp( '<tr>\n' );

      if( ( border.type & showBorderLeft ) != 0 )
      {
        dp( '  <td style="background-image: url(\'' + border.w + '\'); background-repeat: repeat-y; vertical-align: bottom">'  + ( ( border.wsw != "" ) ? '<img src="' + border.wsw + '" />' : '' ) + '</td>\n' );
      }

      if( ( border.type & showBorderRight ) != 0 )
      {
        dp( '  <td style="background-image: url(\'' + border.e + '\'); background-repeat: repeat-y; vertical-align: bottom">'  + ( ( border.ese != "" ) ? '<img src="' + border.ese + '" />' : '' ) + '</td>\n' );
      }

      dp( '</tr>\n' );
    }

    if( ( border.type & showBorderBottom ) != 0 )
    {
      dp( '<tr>\n' );

      if( ( border.type & showBorderLeft ) != 0 )
      {
        dp( '  <td>' + ( ( border.sw != "" ) ? '<img src="' + border.sw + '" />' : '' ) + '</td>\n' );
      }

      dp( '  <td style="background-image: url(\'' + border.s + '\'); background-repeat: repeat-x; text-align: left">'  + ( ( border.ssw != "" ) ? '<img src="' + border.ssw + '" />' : '' ) + '</td>\n' );
      dp( '  <td style="background-image: url(\'' + border.s + '\'); background-repeat: repeat-x; text-align: right">' + ( ( border.sse != "" ) ? '<img src="' + border.sse + '" />' : '' ) + '</td>\n' );

      if( ( border.type & showBorderRight ) != 0 )
      {
        dp( '  <td>' + ( ( border.se != "" ) ? '<img src="' + border.se + '" />' : '' ) + '</td>\n' );
      }

      dp( '</tr>\n' );
    }

    dp( '</table>\n' );
  }
}

function renderMenu( menuVar, nameStem )
{
  if( typeof( nameStem ) == "undefined" )
  {
    topLevelMenus[menuVar.name] = menuVar;
    nameStem = menuVar.name;
  }

  renderBorderTL( menuVar );

  dp( '<table border="0" cellpadding="0" cellspacing="0"' + ( ( menuVar.menuClass ) ? ' class="' + menuVar.menuClass +'" id="' + nameStem + menuTableIdAdd + '"' : '' ) + '>\n' +
      '<tr>\n' );

  var i;

  for( i = 0 ; i < menuVar.items.length ; i++ )
  {
    menuItem = menuVar.items[i];

    if( i != 0 && menuVar.orient == menuTypeVert )
    {
      dp( '</tr>\n<tr>\n' );
    }

    var menuItemId = ( ( nameStem != "" ) ? nameStem + idLevelSep : "" ) + menuItem.name;

    dp( '<td><a href="' + menuItem.href +
        '" onMouseOver="hLight(\'' + menuItemId +
        '\', event )' + ( ( menuItem.onMouseOver != null ) ? ";" + menuItem.onMouseOver : "" ) + '" onMouseOut="lLight(\'' + menuItemId +
        '\')' + ( ( menuItem.onMouseOut != null ) ? ";" + menuItem.onMouseOut : "" ) + '"><div id="' + menuItemId +
        '_I"' + ( (  menuVar.size != -1 ) ? ' style="width: ' + menuVar.size : '' ) +
        'px;" class="' + menuItem.offStyle + classNameAdd( i, menuVar ) +
        '">' + menuItem.text + '</div></a></td>\n' );
  }

  dp( '</tr>\n' +
      '</table>\n' );

  renderBorderBR( menuVar );
}

function classNameAdd( itemNum, menuVar )
{
  var numItems = menuVar.items.length;
  var doNumber = menuVar.doNumber;

  if( typeof( doNumber ) != "undefined" && doNumber != 0 )
  {
    return ( "-" + ( itemNum + 1 ) );
  }

  if( itemNum == 0 )
  {
    return classTopAdd;
  }

  if( itemNum == numItems - 1 )
  {
    return classBottomAdd;
  }

  return "";
}

function classNameAddFrom( newClassBase, oldClassName, menuVar )
{
  var doNumber = menuVar.doNumber;

  if( typeof( doNumber ) != "undefined" && doNumber != 0 )
  {
    var pos = oldClassName.lastIndexOf( "-" );

    if( pos != -1 )
    {
      var endStr = oldClassName.substring( pos + 1, oldClassName.length );
      var endInt = parseInt( "0" + endStr, 10 );

      if( endInt > 0 && endInt <= menuVar.items.length )
      {
        return ( "-" + endInt );
      }
    }
  }

  if( oldClassName.substring( oldClassName.length - classTopAdd.length, oldClassName.length ) == classTopAdd )
  {
    return classTopAdd;
  }

  if( oldClassName.substring( oldClassName.length - classBottomAdd.length, oldClassName.length ) == classBottomAdd )
  {
    return classBottomAdd;
  }

  return "";
}

function renderSubMenu( menuVar, menuItemId )
{
  if( typeof( nameStem ) == "undefined" )
  {
    nameStem = "";
  }

  dp( '<div id="' + menuItemId + '_M" class="menuLayer">' );
  renderMenu( menuVar, menuItemId );
  dp( '</div>' );
}

function renderSubs( menuVar, nameStem )
{
  if( typeof( nameStem ) == "undefined" )
  {
    nameStem = menuVar.name;
  }

  if( roundabout++ == 10 ) return;

  var j;

  for( j = 0 ; j < menuVar.items.length ; j++ )
  {
    var menuItem = menuVar.items[j];

    var menuItemId = ( ( nameStem != "" ) ? nameStem + idLevelSep : "" ) + menuItem.name;

    if( menuItem.items.length > 0 )
    {
      renderSubMenu( menuItem, menuItemId );
      renderSubs( menuItem, menuItemId );
    }
  }
}

function dp( str )
{
  document.write( str );
}

function idParent( idStr )
{
  var dotPos = idStr.lastIndexOf( idLevelSep );

  if( dotPos != -1 )
  {
    return idStr.substring( 0, dotPos );
  }

  return "";
}

function hLightLayer( ev )
{
  var elem;

  if( typeof( ev ) == "undefined" )
  {
    elem = event.srcElement;
    ev = event;
  }
  else
  {
    elem = ev.target;
  }

  if( typeof( elem.id ) != "undefined" )
  {
    while( elem.id == "" )
    {
      elem = elem.parentElement;
    }

    var id = elem.id.substring( 0, elem.id.length - menuLayerIdAdd.length );

    hLight( id, ev );
  }
}

function lLightLayer( ev )
{
  var elem;

  if( typeof( ev ) == "undefined" )
  {
    elem = event.srcElement;
    ev = event;
  }
  else
  {
    elem = ev.target;
  }

  if( typeof( elem.id ) != "undefined" )
  {
    while( elem.id == "" )
    {
      elem = elem.parentElement;
    }

    var id = elem.id.substring( 0, elem.id.length - menuLayerIdAdd.length );

    lLight( id, ev );
  }
}

function hLight( itemId, event )
{
  var menuItem = findItem( topLevelMenus, itemId );

  getElt( itemId + menuItemIdAdd ).className = menuItem.onStyle + classNameAddFrom( menuItem.onStyle, getElt( itemId + menuItemIdAdd ).className, findItem( topLevelMenus, idParent( itemId ) ) );

  var itemIdPath = itemId

  while( itemIdPath != "" )
  {
    clearTimeout( hideTimeout[itemIdPath] );
    itemIdPath = idParent( itemIdPath );
  }

  if( menuItem.items.length > 0 )
  {
    if( typeof( menuItem.fade ) != "undefined" )
    {
      setfade( itemId + menuLayerIdAdd, menuItem.fade );
    }

    getElt( itemId + menuLayerIdAdd ).onmouseover = hLightLayer;
    getElt( itemId + menuLayerIdAdd ).onmouseout  = lLightLayer;

    var newLeft = 0;
    var newTop  = 0;

    if( findItem( topLevelMenus, idParent( itemId ) ).orient == menuTypeVert )
    {
      newLeft = getlayerleft( itemId + menuItemIdAdd ) + getlayerwidth( itemId + menuItemIdAdd ) + menuOffsetHoriz;
      newTop  = getlayertop( itemId + menuItemIdAdd ) + menuOffsetVert;
    }
    else
    {
      newLeft = getlayerleft( itemId + menuItemIdAdd ) + menuOffsetVert;
      newTop  = getlayertop( itemId + menuItemIdAdd ) + getlayerheight( itemId + menuItemIdAdd ) + menuOffsetHoriz;
    }

    newTop  = keepInside( getlayerheight( itemId + menuLayerIdAdd ), newTop,  pageBorders[ pageBorderTop ],  getwindowheight() - pageBorders[ pageBorderBottom ] );
    newLeft = keepInside( getlayerwidth(  itemId + menuLayerIdAdd ), newLeft, pageBorders[ pageBorderLeft ], getwindowwidth()  - pageBorders[ pageBorderRight ] );

    movelayer( itemId + menuLayerIdAdd, newLeft, newTop );
    showlayer( itemId + menuLayerIdAdd );
  }
}

function keepInside( size, pos, low, high )
{
  if( pos + size > high )
  {
    pos = high - size;
  }

  if( pos < low )
  {
    pos = low;
  }

  return pos;
}

function lLight( itemId )
{
  var itemIdPath = itemId

  while( itemIdPath.indexOf( "." ) != -1 )
  {
    clearTimeout( hideTimeout[itemIdPath] );
    hideTimeout[itemIdPath] = setTimeout( "hideMenu( '" + itemIdPath + "' )", closeTimeout );
    itemIdPath = idParent( itemIdPath );
  }
}

function hideMenu( itemId )
{
  clearTimeout( hideTimeout[itemId] );
  var menuItem = findItem( topLevelMenus, itemId );
  getElt( itemId + menuItemIdAdd ).className = menuItem.offStyle + classNameAddFrom( menuItem.offStyle, getElt( itemId + menuItemIdAdd ).className, findItem( topLevelMenus, idParent( itemId ) ) );

  if( menuItem.items.length > 0 )
  {
    hidelayer( itemId + menuLayerIdAdd );
  }
}
