//Fade-in image slideshow- By Dynamic Drive
//For full source code and more DHTML scripts, visit http://www.dynamicdrive.com
//This credit MUST stay intact for use
//altered and made good by John Milner : johndev@gmail.com

var slideshow_width='218px';  //SET IMAGE WIDTH
var slideshow_height='350px'; //SET IMAGE HEIGHT
var pause=3000; //SET PAUSE BETWEEN SLIDE (3000=3 seconds)

var fadeimages=new Array();
var fadedescriptions=new Array();  //ha - like fade descriptions act. tee hee

var preloadedimages=new Array();

var ie4=document.all;
var dom=document.getElementById;

var curpos=10;
var degree=10;
var curcanvas="canvas0";
var curimageindex=0;
var nextimageindex=1;
var dropslide = null;
var rotateInterval = null;


function fadepic()
{
  if( dropslide )
  {
    clearInterval(dropslide);
    dropslide = null;
  }

  if (curpos<100)
  {
    curpos+=10
    if (tempobj.filters)
      tempobj.filters.alpha.opacity=curpos;
    else if (tempobj.style.MozOpacity)
         {
           if( curpos==90 )
           {
             //mozilla flickers when it goes from 90% to 100%, so we make the image under it the same so when it flickers off you don't notice.
             document.getElementById( curcanvas ).innerHTML=getInnerHtml( getLastIndex( curimageindex ) );
           }
           tempobj.style.MozOpacity=curpos/100;
         }
    dropslide=setInterval("fadepic()",50);
  }
  else
  {
    //clearInterval(dropslide);
    //dropslide = null;
    nextcanvas=(curcanvas=="canvas0")? "canvas0" : "canvas1";
    tempobj=ie4? eval("document.all."+nextcanvas) : document.getElementById(nextcanvas);
    tempobj.innerHTML=getInnerHtml( nextimageindex );
    nextimageindex=getNextIndex( nextimageindex );
    rotateInterval = setTimeout("rotateimage()",pause);
  }
}

function getNextIndex( imageindex )
{
  return (imageindex<fadeimages.length-1) ? imageindex+1 : 0;
}

function getLastIndex( imageindex )
{
  return (imageindex>0) ? imageindex-1 : fadeimages.length-1;
}

function getInnerHtml( imageindex )
{
  return '<table border="0" cellpadding="0" cellspacing="0" width="' + slideshow_width + '"><tr><td width="100%" align="left"><img src="'+fadeimages[ imageindex ]+'"></td></tr><tr><td class="smallBulletLine">' + fadedescriptions[ imageindex ] + '</td></tr></table>';
}

function rotateimage()
{
  if( rotateInterval )
  {
    clearInterval( rotateInterval );
    rotateInterval = null
  }
  if (ie4||dom)
  {
    resetit(curcanvas);
    var crossobj=tempobj=ie4? eval("document.all."+curcanvas) : document.getElementById(curcanvas);
    crossobj.style.zIndex ++; crossobj.style.zIndex ++;
    if( crossobj.style.zIndex > 99 )
    {
      crossobj.style.zIndex = 1;
      tempElt = tempobj=ie4? eval("document.all."+ (curcanvas=="canvas0")? "canvas1" : "canvas0"  ) : document.getElementById( (curcanvas=="canvas0")? "canvas1" : "canvas0" );
      tempElt.style.zIndex = 0;
    }
    //var temp='setInterval("fadepic()",50)';
    dropslide=setInterval("fadepic()",50);
    curcanvas=(curcanvas=="canvas0")? "canvas1" : "canvas0";
  }
  else
  {
    document.images.defaultslide.src=fadeimages[curimageindex];
    rotateInterval = setInterval("rotateimage()", pause);
  }
  curimageindex=(curimageindex<fadeimages.length-1)? curimageindex+1 : 0;
  //rotateInterval = setInterval("rotateimage()", pause);
}

function resetit(what)
{
  curpos=10;
  var crossobj=ie4? eval("document.all."+what) : document.getElementById(what);
  if (crossobj.filters)
    crossobj.filters.alpha.opacity=curpos;
  else if (crossobj.style.MozOpacity)
         crossobj.style.MozOpacity=curpos/100;
}

function startSlideshow()
{

  //preload all slideshow images
  for ( p=0 ; p<fadeimages.length ; p++ )
  {
    preloadedimages[p]=new Image();
    preloadedimages[p].src=fadeimages[p];
  }

  if (ie4||dom)
  {
    var crossobj = ie4? eval("document.all."+curcanvas) : document.getElementById(curcanvas);
    crossobj.innerHTML = getInnerHtml( curimageindex );
    rotateimage();
  }
  else
    rotateInterval = setInterval("rotateimage()", pause);

}