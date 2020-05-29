var currentBanner = -1;

var banners = new Array();

function banner( layer, timeout )
{
  this.layer   = layer;
  this.timeout = timeout;
}

function addBanner( layer, timeout )
{
  banners[banners.length] = new banner( layer, timeout );
}

function rotateBanners( index )
{
  if( currentBanner != -1 )
  {
    getElt( banners[currentBanner].layer ).style.display = "none";
  }

  if( typeof( index ) != "undefined" && typeof( index ) != "object" )
  {
    currentBanner = index
  }
  else
  {
    currentBanner++;
  }

  if( currentBanner >= banners.length )
  {
    currentBanner = 0;
  }

  movelayer( banners[currentBanner].layer, 280, 1 );
  getElt( banners[currentBanner].layer ).style.display = "block";

  tim = setTimeout( "rotateBanners()", banners[currentBanner].timeout * 1000 );
}

onload=rotateBanners