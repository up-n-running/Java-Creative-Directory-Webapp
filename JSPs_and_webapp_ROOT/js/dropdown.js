function emptyList( box )
{
  while ( box.options.length ) box.options[0] = null;
}

function fillList( box, arr, pleaseSelect )
{
  if( pleaseSelect!='' )
  {
    option = new Option( pleaseSelect, 'none' );
    box.options[box.options.length] = option;
  }
  initialOptionsLength = box.options.length;
  for ( i = initialOptionsLength; i < (arr.length+initialOptionsLength) ; i++ )
  {
option = new Option( arr[i-initialOptionsLength], (i+1-initialOptionsLength) );
box.options[box.options.length] = option;
  }
  //preselect top option
  box.selectedIndex=0;
}

function changeChildren( box, parentGrpName, childName, pleaseSelect )
{
  parentValue = box.options[box.selectedIndex].value;
  dataArray = eval( parentGrpName+'Data' );
  childDropDown = eval( 'box.form.' + childName );
  list = new Array();
  if( parentValue=='none' )
  {
    childDropDown.disabled = true;
    list = new Array();
    list[0] = 'Please Choose Option Above';
    pleaseSelect='';
  }
  else
  {
    childDropDown.disabled=false;
    list = dataArray[ parentValue ];
  }
  emptyList( childDropDown );
  fillList( childDropDown, list, pleaseSelect );
}


function setOtherFieldStatus( box, othF, othHdl, plsSelectTxt, notApplicableTxt )
{
  if( typeof( othF ) != 'undefined' )
  {
    if( box.options[box.selectedIndex].value == othHdl)
    {
      othF.disabled=false;
      othF.value='';
      othF.focus();
    }
    else if ( box.options[box.selectedIndex].value == 'none' )
    {
      othF.value=plsSelectTxt;
      othF.disabled=true;
    }
    else
    {
      othF.value=notApplicableTxt;
      othF.disabled=true;
    }
  }
}