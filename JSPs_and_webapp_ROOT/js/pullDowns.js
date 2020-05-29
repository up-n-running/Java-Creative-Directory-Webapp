descs = new Array();
descs[ 0 ] = new Array( new Array( 'join up', '/pages/registerContactDetails.jsp?mode=add' ),
                        new Array( 'info', '/pages/registerJoinup.jsp' ) );
descs[ 1 ] = new Array( new Array( 'account', '/pages/accountManager.jsp?fromPullDown=true' ) );
descs[ 2 ] = new Array( new Array( 'advertise', '/pages/advertsEdit.jsp' ),
                        new Array( 'info', '/pages/infoPage.jsp?page=addinfo' ) );
descs[ 3 ] = new Array( new Array( 'add job', '/pages/jobsEdit.jsp?fromPullDown=true' ),
                        new Array( 'info', '/pages/infoPage.jsp?page=jobinfo' ) );
descs[ 4 ] = new Array( new Array( 'contact us', '/pages/contactUs.jsp' ),
                        new Array( 'about us', '/pages/infoPage.jsp?page=aboutus' ),
                        new Array( 'tell others', '/pages/tellAFriend.jsp?bigtitle=true' ),
                        new Array( 'send news', '/pages/contactUs.jsp?type=news' ) );
descs[ 5 ] = new Array( new Array( 'help', '/pages/list.jsp?l=faqs' ),
                        new Array( 'FAQs', '/pages/list.jsp?l=faqs' ),
                        new Array( 'contact us', '/pages/contactUs.jsp' ),
                        new Array( 'Terms', '/pages/list.jsp?l=terms' ),
                        new Array( 'Privacy', '/pages/list.jsp?l=privacy' ) );
currentRow = -1;
currentPdNum = -1;
killMenuTimer = null;
fadeTimer = null;
fadeVal = 0;


function showPd( pdNum, rowNum )
{
  clearInterval( killMenuTimer );
  killMenuTimer = null;

  oldPdNum = currentPdNum;

  currentPdNum = pdNum;
  currentRow = rowNum;

  elementName = 'pullDown' + pdNum + '_' + rowNum
  elt = document.getElementById( elementName );
  if( rowNum==1 )
    elt.className = 'pullCellMainSelected';
  else
    elt.className = 'pullCellSelected';

  if( rowNum==1 && pdNum != oldPdNum )
  {
    pullDownCode =  '<table border="0" cellpadding="0" cellspacing="0" width="81">';
    for( row = 2 ; row <= descs[ pdNum-1 ].length ; row++ )
    {
      pullDownCode += '<tr><td id="pullDown' + pdNum + '_' + row + '" onmouseover="showPd( ' + pdNum + ', ' + row + ' );" onmouseout="hidePd( ' + pdNum + ', ' + row + ' );" onclick="selectPd( ' + pdNum + ', ' + row + ' )" class="pullCell">' + descs[ pdNum-1 ][ row-1 ][0] + '</td></tr>';
    }
    pullDownCode += '</table>';

    hidelayer( 'pulldownoptions' );
    movelayer(  'pulldownoptions', getlayerleft( elementName ) , getlayertop( elementName )+19 );
    writelayer( 'pulldownoptions', pullDownCode );
    showlayer( 'pulldownoptions' );

    //set fading
    fadeIn( true )
  }
}

function fadeIn( reset )
{
  clearInterval( fadeTimer );
  fadeTimer = null;
  elt = document.getElementById( 'pulldownoptions' );
  if( reset )
    fadeVal = 0;
  else
    fadeVal += 1;
  elt.className = 'opaq' + fadeVal;
  if( fadeVal < 9 )
  {
    fadeTimer = setInterval( "fadeIn( false )", 20 );
  }
}

function hidePd( pdNum, rowNum )
{
  elementName = 'pullDown' + pdNum + '_' + rowNum
  elt = document.getElementById( elementName );
  if( rowNum==1 )
    elt.className = 'pullCellMain';
  else
    elt.className = 'pullCell';

  if( pdNum == currentPdNum && rowNum == currentRow )
  {
    clearInterval( killMenuTimer );
    killMenuTimer = null;
    killMenuTimer  = setInterval( "killMenu()", 100 );
  }
}

function selectPd( pdNum, rowNum )
{
  document.location.href = descs[ pdNum-1 ][ rowNum-1 ][1];
}

function killMenu()
{
  currentRow = -1;
  currentPdNum = -1;
  clearInterval( killMenuTimer );
  killMenuTimer = null;
  hidelayer( 'pulldownoptions' );
}