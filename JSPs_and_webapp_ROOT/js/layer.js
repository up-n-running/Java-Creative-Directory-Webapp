var def_layer="2.0";		// layer.js version

var saveInnerWidth;
var saveInnerHeight;

function set()
{
  if( !window.saveInnerWidth )
  {
    saveInnerWidth = window.innerWidth;
    saveInnerHeight = window.innerHeight;
  }
}

function getpagescrollx()
{
  if( window.pageXOffset )
    return window.pageXOffset;

  if( document.body && document.body.scrollLeft )
    return document.body.scrollLeft;

  return -1;
}

function getpagescrolly()
{
  if( window.pageYOffset )
    return window.pageYOffset;

  if( document.body && document.body.scrollTop )
    return document.body.scrollTop;

  return( -1 );
}

function hidelayer( layername )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.visibility )
    {
      elt.visibility="hidden";
    }
    else
    {
      elt.style.visibility="hidden";
    }

    return(1);
  }

  return( -1 );
}

function showlayer( layername )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.visibility )
    {
      elt.visibility="visible";
    }
    else
    {
      elt.style.visibility="visible";
    }

    return(1);
  }

  return( -1 );
}

function getfade( layername )
{
  if( document.all)
  {
    elt = getElt( layername );
    if( elt != null )
    {
      return ( elt.style.filter );
    }
  }

  return( -1 );
}

function setstatic( layername )
{
  if( document.all )
  {
    elt = getElt( layername );
    if( elt != null )
    {
      elt.style.position="static";
    }
  }
}

function setfade( layername, fade )
{
  if( document.all )
  {
    elt = getElt( layername );
    if( elt != null )
    {
      elt.style.filter= /*"alpha(opacity="+(fade*100)+") ;*/ "-moz-opacity:" + fade + ";";
    }
  }

  return( -1 );
}

function movelayer( layername, xco, yco )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( typeof( elt.left ) != "undefined" )
    {
      elt.left=xco;
      elt.top=yco;
    }
    else
    {
      elt.style.left=xco;
      elt.style.top=yco;
    }

    return( 1 );
  }

  return( -1 );
}

function cliplayer( layername, left, right, top, bottom )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.clip )
    {
      elt.clip.left   = left;
      elt.clip.top    = top;
      elt.clip.right  = right;
      elt.clip.bottom = bottom;
    }
    else
      elt.style.clip = 'rect(' + top + 'px ' + right + 'px ' + bottom + 'px ' + left +'px)';

    return( 1 );
  }

  return( -1 );
}

function getwindowwidth()
{
  if( window.innerWidth )
    return( window.innerWidth );

  if( document.body && document.body.clientWidth )
    return( document.body.clientWidth );

  return( 0 );
}

function getwindowheight()
{
  if( window.innerHeight )
    return( window.innerHeight );

  if( document.body && document.body.clientHeight )
    return( document.body.clientHeight );

  return( 0 );
}

function getlayerleft( layername )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.pageX )
    {
      return elt.pageX;
    }

    x = 0;
    while( elt.offsetParent != null )
    {
      x += elt.offsetLeft;
      elt = elt.offsetParent;
    }
    x += elt.offsetLeft;
    return x;
  }

  return( -1 );
}

function getlayertop( layername )
{
  elt = getElt( layername );

  if( elt != null )
  {
    if( elt.pageY )
    {
      return elt.pageY;
    }

    y = 0;

    while( elt.offsetParent != null )
    {
      y += elt.offsetTop;
      elt = elt.offsetParent;
    }

    y += elt.offsetTop;
    return y;
  }

  return(-1);
}

function getlayerwidth( layername )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.style && elt.style.pixelWidth )
      return elt.style.pixelWidth;

    if( elt.style && elt.style.width )
      return stringToNumber(elt.style.width);

    if( elt.offsetWidth )
      return stringToNumber( elt.offsetWidth );

    if( elt.document && elt.document.width )
      return elt.document.width;

    if( elt.clip )
      return elt.clip.right - elt.clip.left;
  }

  return( 0 );
}

function getlayerheight( layername )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.style && elt.style.pixelHeight )
      return elt.style.pixelHeight;

    if( elt.style && elt.style.height )
      return stringToNumber(elt.style.height);

    if( elt.offsetHeight )
      return stringToNumber( elt.offsetHeight );

    if( elt.document && elt.document.height )
      return elt.document.height;

    if( elt.clip )
      return elt.clip.bottom - elt.clip.top;
  }

  return( 0 );
}

function parseDomClip( layername )
{
  elt = getElt( layername );
  str = elt.style.clip;

  i = str.indexOf( "(" );
  topr = parseInt( str.substring( i + 1, str.length ), 10 );

  i = str.indexOf( " ", i + 1 );
  rightr = parseInt( str.substring( i + 1, str.length ), 10 );

  i = str.indexOf( " ", i + 1 );
  bottomr = parseInt( str.substring( i + 1, str.length ), 10 );

  i = str.indexOf( " ", i + 1 );
  leftr = parseInt( str.substring( i + 1, str.length ), 10 );

  ret = new Array( topr, rightr, bottomr, leftr )
  return ret;
}

function getclipleft( layername )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.clip )
    {
      return( elt.clip.left );
    }

    if( elt.style )
    {
      clip = parseDomClip( layername );

      return( clip[3] );
    }
  }

  return(-1);
}

function getclipright( layername )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.clip )
    {
      return( elt.clip.left );
    }

    if( elt.style )
    {
      clip = parseDomClip( layername );

      return( clip[1] );
    }
  }

  return (-1);
}

function getcliptop( layername )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.clip )
    {
      return( elt.clip.left );
    }

    if( elt.style )
    {
      clip = parseDomClip( layername );

      return( clip[0] );
    }
  }

  return (-1);
}

function getclipbottom( layername )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( elt.clip )
    {
      return( elt.clip.left );
    }

    if( elt.style )
    {
      clip = parseDomClip( layername );

      return( clip[2] );
    }
  }

  return (-1);
}

function catchheight( layername )
{
  if( document.layers )
  {
    elt = getElt( layername );

    if( elt != null )
    {
      elt.height=elt.clip.height;
      elt.width=elt.clip.width;
    }
  }
}

function getElt()
{
  if( document.getElementById && document.getElementsByName )
  {
    var name = getElt.arguments[getElt.arguments.length - 1];

    if( document.getElementById( name ) )		// First try to find by id
    {
      return document.getElementById( name );
    }
    else if( document.getElementsByName( name ) )	// Then if that fails by name
    {
      return document.getElementsByName( name )[0];
    }
  }
  else if( document.layers )
  {
    var currentLayer = document.layers[getElt.arguments[0]];

    for( var i = 1 ; i < getElt.arguments.length && currentLayer ; i++ )
    {
      currentLayer = currentLayer.document.layers[getElt.arguments[i]];
    }

    return currentLayer;
  }
  else if( document.all )
  {
    var elt = document.all[getElt.arguments[getElt.arguments.length - 1]];

    return( elt );
  }

  return null;
}


function stringToNumber( s )
{
  return parseInt( ( '0' + s ), 10 )
}


function writelayer( layer, txt )
{
  tl = getElt( layer );
  if ( typeof(tl) != "undefined")
  {
    if( typeof(tl.innerHTML) == "undefined" )
    {
      tl.document.write( txt );
      tl.document.close();
    }
    else
    {
      tl.innerHTML = txt;
    }
  }
}

function sizelayer( layername, wdim, hdim )
{
  elt = getElt( layername );
  if( elt != null )
  {
    if( typeof( elt.width ) != "undefined" )
    {
      elt.width=wdim;
      elt.top=hdim;
    }
    else
    {
      elt.style.width=wdim;
      elt.style.height=hdim;
    }

    return( 1 );
  }

  return( -1 );
}