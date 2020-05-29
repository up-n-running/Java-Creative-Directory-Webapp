function showImage( imgsrc, width, height, title )
{
  var win = window.open( "", "IMAGEPOP", "width=" + width + ",height=" + height );

  win.document.open( "text/html" );
  win.document.write( '<html><head><title>' + title + '</title><style type="text/css">body{background:white;margin:0px}</style></head><body onload="self.focus()"><img onclick="self.close()" src="' + imgsrc + '" title="' + title + ' (click to close)"/></body></html>' );
  win.document.close();

  return false;
}
