function ipsum( elementName, maxParas, formName )
{
  if( typeof( parent.lorem ) != "undefined" && typeof( parent.lorem.length ) != "undefined" && parent.lorem.length > 0 )
  {
    if( typeof( formName ) == "undefined" )
    {
      formName = "0";
    }

    if( typeof( maxParas ) == "undefined" )
    {
      maxParas = parent.lorem.length;
    }

    document.write( "Auto Ipsum<br />" );

    for( var i = 1 ; i <= maxParas ; i++ )
    {
      document.write( ' <a href="#" onclick="return dolor(\'' + formName + '\', \'' + elementName + '\', ' + i + ')">' + i + '</a>' );
    }

    document.write( '<br /><a href="#" onclick="return dolor(\'' + formName + '\', \'' + elementName + '\', 0)">Clear</a>' );
  }
}

function dolor( formName, elementName, paraCount )
{
  var theElem = document.forms[formName].elements[elementName];
  theElem.value = "";

  for( var i = 0 ; i < paraCount ; i++ )
  {
    theElem.value = theElem.value + ( ( i != 0 ) ? "\r\n\r\n" : "" ) + parent.lorem[i];
  }

  return false;
}
