var def_dateForm = "1.1"		// version of dateForm.js

var dayExt  = "Day";			// extension to form element names for day drop downs
var monExt  = "Month";			// extension to form element names for month drop downs
var yearExt = "Year";			// extension to form element names for year drop downs

var firstDayValLine  = 1;		// selectedIndex of first value in day select elements
var firstMonValLine  = 1;		// selectedIndex of first value in month select elements
var firstYearValLine = 1;		// selectedIndex of first value in year select elements

var dateToSetTo = new Date();		// date object representing date to set all declared date sets to

var dateElementRoots = new Array();	// array of date element name roots
var dateListToSetTo  = new Array();	// array of dates to set elements to

// Should not need to edit past here

var monthLengths = new Array( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

if( typeof( def_onload ) != "undefined" )
{
  onloadAdd( setDates );
}
else
{
  window.onload = setDates;
}

function setDates( theForm )
{
  var i;

  if( typeof( theForm ) == "undefined" || typeof( theForm.action ) == "undefined" )
  {
    theForm = document.forms[0];
  }

  for( i = 0 ; i < dateElementRoots.length ; i++ )
  {
    elemName = dateElementRoots[i];

    if( typeof( theForm.elements[elemName + dayExt] ) != "undefined" )
    {
      if( theForm.elements[elemName + dayExt].selectedIndex == 0 )
      {
        firstDayValLine  = ( ( theForm.elements[elemName + dayExt].options[0].text  == "" ) ? 1 : 0 );
        firstMonValLine  = ( ( theForm.elements[elemName + monExt].options[0].text  == "" ) ? 1 : 0 );
        firstYearValLine = ( ( theForm.elements[elemName + yearExt].options[0].text == "" ) ? 1 : 0 );

        var useDate = new Date();

        if( typeof( dateListToSetTo[i] ) != "undefined" && dateListToSetTo[i] != null )
        {
          useDate = dateListToSetTo[i];
        }
        else if( typeof( dateToSetTo ) != "undefined" && dateToSetTo != null )
        {
          useDate = dateToSetTo;
        }

        if( ( typeof( dateListToSetTo[i] ) == "undefined" || dateListToSetTo[i] == null ) &&
            firstDayValLine == 1 &&
            firstMonValLine == 1 &&
            firstYearValLine == 1 )
        {
          blankDate( elemName );
        }
        else
        {
          baseYear = theForm.elements[elemName + yearExt].options[firstYearValLine].text;
          theForm.elements[elemName + dayExt].selectedIndex  = firstDayValLine  + useDate.getDate() - 1;
          theForm.elements[elemName + monExt].selectedIndex  = firstMonValLine  + useDate.getMonth();
          var yearSet = firstYearValLine + useDate.getFullYear() - baseYear;
          theForm.elements[elemName + yearExt].selectedIndex = ( ( yearSet < firstYearValLine ) ? firstYearValLine : yearSet );
        }
      }

      theForm.elements[elemName + dayExt].onchange  = checkDate;
      theForm.elements[elemName + monExt].onchange  = checkDate;
      theForm.elements[elemName + yearExt].onchange = checkDate;
    }
  }
}

function isLeapYear( year )
{
  return ( ( year % 4 == 0 ) && ( ( year % 100 !=0 ) || ( year % 400 == 0 ) ) );
}

function checkDate( element )
{
  if( typeof( element ) == "undefined" )
  {
    element = event;
  }

  if( typeof( element.target ) != "undefined" )
  {
    element = element.target;
  }
  else if( typeof( element.srcElement ) != "undefined" )
  {
    element = element.srcElement;
  }

  elemName = element.name;
  theForm  = element.form;

  if( elemName.indexOf( dayExt ) != -1 )
  {
    elemName = elemName.substring( 0, elemName.length - dayExt.length );
  }
  else if( elemName.indexOf( monExt ) != -1 )
  {
    elemName = elemName.substring( 0, elemName.length - monExt.length );
  }
  else if( elemName.indexOf( yearExt ) != -1 )
  {
    elemName = elemName.substring( 0, elemName.length - yearExt.length );
  }

  firstDayValLine  = ( ( theForm.elements[elemName + dayExt].options[0].text  == "" ) ? 1 : 0 );
  firstMonValLine  = ( ( theForm.elements[elemName + monExt].options[0].text  == "" ) ? 1 : 0 );
  firstYearValLine = ( ( theForm.elements[elemName + yearExt].options[0].text == "" ) ? 1 : 0 );

  dayVal   = element.form.elements[elemName + dayExt].selectedIndex  - firstDayValLine  + 1;
  monVal   = element.form.elements[elemName + monExt].selectedIndex  - firstMonValLine;
  yearVal  = element.form.elements[elemName + yearExt].selectedIndex - firstYearValLine;
  baseYear = element.form.elements[elemName + yearExt].options[firstYearValLine].text;

  if( dayVal  == ( 1 - firstDayValLine ) ||
      monVal  == ( 0 - firstMonValLine ) ||
      yearVal == ( 0 - firstYearValLine ) )
  {
    return;
  }

  maxDayVal = monthLengths[monVal];

  if( monVal == 1 && isLeapYear( yearVal + parseInt( baseYear ) ) )
  {
    maxDayVal++;
  }

  if( dayVal > maxDayVal )
  {
    element.form.elements[ elemName + dayExt  ].selectedIndex = firstDayValLine + maxDayVal - 1;
  }
}

function blankDate( elemName )
{
  theForm = document.forms[0];

  theForm.elements[elemName + dayExt].selectedIndex  = 0;
  theForm.elements[elemName + monExt].selectedIndex  = 0;
  theForm.elements[elemName + yearExt].selectedIndex = 0;

  return false;
}