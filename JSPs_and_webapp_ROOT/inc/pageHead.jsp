<%@ page language="java"
  import="com.extware.advert.Advert,
          com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.utils.BooleanUtils,
          com.extware.utils.PropertyFile,
          java.util.ArrayList"
%><%

Member loggedInMember = (Member)request.getSession().getAttribute( "member" );
MemberContact loggedInMemberContact = loggedInMember == null ? null : (  loggedInMember.memberContact == null ? loggedInMember.moderationMemberContact : loggedInMember.memberContact  );

//get Adverts
PropertyFile dataDictionary = PropertyFile.getDataDictionary();
ArrayList premiereLiveAds = Advert.getPremiereLiveAds();
ArrayList standardLiveAds = Advert.getStandardLiveAds();
int maxPremiereAds = dataDictionary.getInt( "advertising.maxPremiereLeft" );
int maxStandardAds = dataDictionary.getInt( "advertising.maxStandardLeft" );

boolean fromBrowseForm = request.getParameter( "formname" ) != null && request.getParameter( "formname" ).equals( "browse" );
boolean fromSearchForm = request.getParameter( "formname" ) != null && request.getParameter( "formname" ).equals( "search" );

%><html>
<head>
  <title><%= request.getParameter( "pgtitle" )==null ? "Nextface - The creative directory" : request.getParameter( "pgtitle" ) %></title>
<%

if( request.getParameter( "metakeywords" )==null )
{

%>  <meta name="keywords" content="Nextface, creative, directory, art, performance art, design, computer graphics, video, film, broadcast, online portfolio, graphics, jobs, creative jobs, design jobs, art courses, art publications, images" />
<%

}
else
{

%>  <meta name="keywords" content="<%= request.getParameter( "metakeywords" ) %>" />
<%

}

%>  <link rel="stylesheet" type="text/css" href="/style/general.css"/>
  <link rel="stylesheet" type="text/css" href="/style/menuTree.css" />
<script type="text/javascript" language="javascript" src="/js/layer.js"></script>
<script type="text/javascript" language="javascript" src="/js/menuTree.js"></script>
<script type="text/javascript" language="javascript" src="/js/showImage.js"></script>
<script type="text/javascript" language="javascript" src="/js/srchNBrowz.js"></script>
<script type="text/javascript" language="javascript" src="/js/pullDowns.js"></script>
<script type="text/javascript" language="javascript" src="/js/dropdown.js"></script>
<%
if( fromSearchForm )
{
%>
<script type="text/javascript">
function setupSearch()
{
  <%= request.getParameter( "searchtype" ) %>();
<%
  if( !request.getParameter( "compsizeval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'compSize'; sctOtpn( " + request.getParameter( "compsizeval" ) + " );" );
  }
  if( !request.getParameter( "jobtypeval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'jobType'; sctOtpn( " + request.getParameter( "jobtypeval" ) + " );" );
  }
  if( !request.getParameter( "filetypeval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'fileType'; sctOtpn( " + request.getParameter( "filetypeval" ) + " );" );
  }
  if( !request.getParameter( "categoryval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'category'; sctOtpn( " + request.getParameter( "categoryval" ) + " );" );
  }
  if( !request.getParameter( "disciplineval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'discipline'; sctOtpn( " + request.getParameter( "disciplineval" ) + " );" );
  }
  if( !request.getParameter( "countryval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'country'; sctOtpn( " + request.getParameter( "countryval" ) + " );" );
  }
  if( !request.getParameter( "regionval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'region'; sctOtpn( " + request.getParameter( "regionval" ) + " );" );
  }
  if( !request.getParameter( "countyval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'county'; sctOtpn( " + request.getParameter( "countyval" ) + " );" );
  }
  if( request.getParameter( "keyword" )!=null && !request.getParameter( "keyword" ).equals( "" ) && !request.getParameter( "keyword" ).equals( "  KEYWORD" ) )
  {

%>    document.getElementById( 'srcTxtCell' ).className = 'textInputCellSelected';
    document.forms[ 'search' ].keyword.value = '<%= request.getParameter( "keyword" ) %>';
<%

  }

%>}
</script>
<%

}

if( fromBrowseForm )
{

%>
<script type="text/javascript">
function setupBrowse()
{
<%

  if( !request.getParameter( "categoryval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'Bcategory'; sctOtpn( " + request.getParameter( "categoryval" ) + " );" );
  }
  if( !request.getParameter( "disciplineval" ).equals( "-1" ) )
  {
    out.println( "  lastDropDownName = 'Bdiscipline'; sctOtpn( " + request.getParameter( "disciplineval" ) + " );" );
  }

%>}
</script>
<%

}

%>
</head>
<body topmargin="0" onload="initialise( 'load' );<%= fromSearchForm ? " setupSearch();" : "" %><%= fromBrowseForm ? " setupBrowse();" : "" %>" onresize="initialise( 'resize' );">
<script type="text/javascript">
var origWindowHidth = getwindowwidth();
</script>
<table align="center" border="0" cellpadding="0" cellspacing="0" > <!--800px -->
<tr>
<td>
<table border="0" cellpadding="0" cellspacing="0" >
<tr>
  <td valign="top" rowspan="1" width="175"><img width="175" height="100" src="/art/sp1.gif"></td>
  <td valign="top" rowspan="1" width="31"><img width="31" height="100" src="/art/sp2.gif"></td>
  <td height="100" width="383" align="right">
    <table cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%"><script type="text/javascript">if( origWindowHidth <= 800 ) { document.write( '<img width="10" height="1" src="/art/blank.gif" />' ) } else { document.write( '<img width="46" height="1" src="/art/blank.gif" />' ) }</script><noscript><img width="45" height="1" src="/art/blank.gif" /></noscript></td>
      <td><img width="353" height="100" src="/art/logo1a.gif" /></td>
    </tr>
    </table>
  </td>
  <td width="178" height="100" align="right"><img width="178" height="100" src="/art/logo1b.gif" /></td>
</tr>
<tr>
  <td valign="top" width="175" rowspan="2">
    <table cellpadding="0" cellspacing="0" width="175" height="211px">
    <tr>
      <td id="searchPanel" height="213px">
<script type="text/javascript">
  restartSearch();
</script>
<noscript>
members beginning with:
<a href="/a.jsp?l=A">A</a> <a href="/a.jsp?l=B">B</a> <a href="/a.jsp?l=C">C</a> <a href="/a.jsp?l=D">D</a> <a href="/a.jsp?l=E">E</a>
<a href="/a.jsp?l=F">F</a> <a href="/a.jsp?l=G">G</a> <a href="/a.jsp?l=H">H</a> <a href="/a.jsp?l=I">I</a> <a href="/a.jsp?l=J">J</a>
<a href="/a.jsp?l=K">K</a> <a href="/a.jsp?l=L">L</a> <a href="/a.jsp?l=M">M</a> <a href="/a.jsp?l=N">N</a> <a href="/a.jsp?l=O">O</a>
<a href="/a.jsp?l=P">P</a> <a href="/a.jsp?l=Q">Q</a> <a href="/a.jsp?l=R">R</a> <a href="/a.jsp?l=S">S</a> <a href="/a.jsp?l=T">T</a>
<a href="/a.jsp?l=U">U</a> <a href="/a.jsp?l=V">V</a> <a href="/a.jsp?l=W">W</a> <a href="/a.jsp?l=X">X</a> <a href="/a.jsp?l=Y">Y</a>
<a href="/a.jsp?l=Z">Z</a> <a href="/a.jsp?l=0">0-9</a> <a href="/a.jsp?l=_">_</a>
</noscript>
      </td>
    </tr>
    </table>
    <table cellpadding="0" cellspacing="0" border="0" width="175">
    <tr>
      <td height="4px"></td>
    </tr>
    <tr>
      <td><img width="175" height="30" src="/art/browse.gif" /></td>
    </tr>
    <tr>
      <td id="browsePanel" height="68px"></td>
    </tr>
<script type="text/javascript">
  startBrowse();
</script>
    <tr>
      <td height="4px"></td>
    </tr>
    <tr>
      <td>
        <table cellpadding="0" cellspacing="0" width="175">
        <tr>
          <td rowspan="5" valign="top" bgcolor="#D0D0D0" width="1" id="sep1"><img width="1" height="84" src="/art/greyFade.gif"></td>
          <td align="center" width="173"><a href="/pages/registerContactDetails.jsp?mode=add"><img width="153" height="52" src="/art/join.gif"></a></td>
          <td rowspan="5" valign="top" bgcolor="#D0D0D0" width="1" id="sep2"><img width="1" height="84" SRC="/art/greyFade.gif"></td>
        </tr>
        <tr>
          <td align="CENTER" class="orange" style="font-size:10px"><a href="/pages/registerJoinup.jsp">tell me more about joining</a></td>
        </tr>
        <tr>
          <td align="CENTER" class="orange" style="font-size:10px; padding-top:5px"><a href="/pages/tellAFriend.jsp">tell a friend about Nextface</a></td>
        </tr>
        <tr>
          <td height="25px"></td>
        </tr>
        <tr>
          <td align="center" VALIGN="TOP">
            <table cellpadding="0" cellspacing="0" width="152">
<%

for( int i = 1 ; i <= (maxPremiereAds*2) ; i += 2 )
{
  Advert tempAd;
  if( i < premiereLiveAds.size() )
  {
    tempAd = (Advert)premiereLiveAds.get( i );

%>            <tr>
              <td class="premAd"><%= tempAd.getPostProcessAssetHtml( "Advert" ) %></td>
            </tr>
<%

  }
  else
  {

%>            <tr>
              <td class="premAdUnused">Premier Advertising<BR>From £<%= Advert.lowestPremierMonthlyCost %> per month</td>
            </tr>
<%

  }

%>            <tr>
              <td height="4px"></td>
            </tr>
<%

}

%>
<%

for( int i = 0 ; i < (maxStandardAds*2) ; i += 2 )
{
  Advert tempAd;
  if( i < standardLiveAds.size() )
  {
    tempAd = (Advert)standardLiveAds.get( i );
%>            <tr>
              <td class="standAd"><%= tempAd.getPostProcessAssetHtml( "Advert" ) %></td>
            </tr>
<%

  }
  else
  {

%>            <tr>
              <td class="standAdUnused">Standard Advertising<BR>From £<%= Advert.lowestStandardMonthlyCost %> per month</td>
            </tr>
<%

  }

%>            <tr>
              <td height="4px"></td>
            </tr>
<%
}
%>            </table>
            </td>
        </tr>
        </table>
      </td>
    </tr>
    </table>
  </td>
  <td valign="top" height="90"><img width="44" height="50" src="/art/sp3.gif"></td>
  <td height="90" align="right" valign="top" colspan="2">
    <table cellpadding="0" cellspacing="0" border="0">
    <tr>
      <td  height="90" valign="top" class="backG">
        <table border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td><table cellpadding="0" cellspacing="0" border="0"><tr><!--<td width="2">--></td><td id="pullDown1_1" onmouseover="showPd( 1, 1 );" onmouseout="hidePd( 1, 1 );" onclick="selectPd( 1, 1 )" class="pullCellMain">join up</td><td width="2"></td></table></td>
          <td><table cellpadding="0" cellspacing="0" border="0"><tr><td width="2"></td><td id="pullDown2_1" onmouseover="showPd( 2, 1 );" onmouseout="hidePd( 2, 1 );" onclick="selectPd( 2, 1 )" class="pullCellMain">account</td><td width="2"></td></table></td>
          <td><table cellpadding="0" cellspacing="0" border="0"><tr><td width="2"></td><td id="pullDown3_1" onmouseover="showPd( 3, 1 );" onmouseout="hidePd( 3, 1 );" onclick="selectPd( 3, 1 )" class="pullCellMain">advertise</td><td width="2"></td></table></td>
          <td><table cellpadding="0" cellspacing="0" border="0"><tr><td width="2"></td><td id="pullDown4_1" onmouseover="showPd( 4, 1 );" onmouseout="hidePd( 4, 1 );" onclick="selectPd( 4, 1 )" class="pullCellMain">add job</td><td width="2"></td></table></td>
          <td><table cellpadding="0" cellspacing="0" border="0"><tr><td width="2"></td><td id="pullDown5_1" onmouseover="showPd( 5, 1 );" onmouseout="hidePd( 5, 1 );" onclick="selectPd( 5, 1 )" class="pullCellMain">contact us</td><td width="2"></td></table></td>
          <td><table cellpadding="0" cellspacing="0" border="0"><tr><td width="2"></td><td id="pullDown6_1" onmouseover="showPd( 6, 1 );" onmouseout="hidePd( 6, 1 );" onclick="selectPd( 6, 1 )" class="pullCellMain">help</td><td width="2"></td></table></td>
          <td><table cellpadding="0" cellspacing="0" border="0"><tr><td width="2"></td><td onmouseover="this.className='homeCellSelected';" onmouseout="this.className='homeCell';" class="homeCell"><a href="/index.jsp"><img width="15" height="16" border="0" src="/art/home.gif" border="0"></a></td></tr></table></td>
        </tr>
<%

if( loggedInMember==null )
{

%>        <tr>
          <td colspan="2"></td>
          <td colspan="3" height="19" class="loginHelp">your email address</td>
          <td colspan="1" class="loginHelp">password</td>
          <td></td>
        </tr>
        <tr>
          <td colspan="2"><form name="login" action="/login.jsp"><input type="hidden" name="redirectto" value="/pages/accountManager.jsp" /><table cellpadding="0" cellspacing="0" border="0"><tr><td><img width="22" height="16" src="/art/loginArrows.gif" /></td><td class="loginTextBig">Members login here</td></tr></table></td>
          <td colspan="3"><table cellpadding="0" cellspacing="0" border="0"><tr><td width="2"></td><td><input name="email" type="text" class="membLog" width="251" value="" /></td><td width="2"></td></table></td>
          <td><table cellpadding="0" cellspacing="0" border="0"><tr><td width="2"></td><td><input name="passwd" type="password" class="membPass" value=""></div></td><td width="2"></td></table></td>
          <td><table cellpadding="0" cellspacing="0" ><tr><td width="2"></td><td valign="top" style="padding-top: 1px"><input type="image" width="17" height="18" src="/art/loginButton.gif" onclick="if( checkLoginForm() ){ document.forms[ 'login' ].submit(); } return false;" /></form></td></table></td>
        </tr>
<%

}
else
{

%>         <tr>
           <td colspan="6" height="19"></td>
         </tr>
         <tr>
           <td colspan="5"><table cellpadding="0" cellspacing="0" border="0"><tr><td><img width="22" height="16" src="/art/loginArrows.gif" /></td><td class="loginTextBig">Logged in<%= loggedInMemberContact == null ? "" : " as " + loggedInMemberContact.name %></td></tr></table></td>
           <td colspan="1"><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td class="loginTextBig" style="text-align: right;">logout</td><td width="2"></tr></table></td>
           <td><table cellpadding="0" cellspacing="0" border="0"><tr><td width="2"></td><td style="padding-top: 1px"><a href="/logout.jsp"><img width="17" height="18" src="/art/loginButton.gif" /></a></form></td></table></td>
         </tr>
<%

}

%>         <tr><td colspan="7" height="5"></td></tr>
<%

if( loggedInMember==null )
{

%>         <tr><td colspan="7" class="loginText" align="right">Forgotten your password? <a href="/pages/forgottenPassword.jsp" class="loginText">click here</a></td></tr>
<%

}

%>         </table>
      </td>
    </tr>
    </table>
  </td>
</tr>
<tr>
  <td valign="top" colspan="2">
    <table cellpadding="0" cellspacing="0" border="0" width="100%">
<%

if( BooleanUtils.isTrue( request.getParameter( "wideForWorldpay" ) ) )
{

%>    <tr>
        <td>
          <table cellpadding="0" cellspacing="0" border="0" width="430">
          <tr>
            <td>
<%

}
else
{

%>    <tr>
        <td height="1"><img width="3" height="1" src="/art/blank.gif" /></td>
        <td><img width="3" height="1" src="/art/blank.gif" /></td>
        <td width="406">
          <table cellpadding="0" cellspacing="0" border="0" width="406">
          <tr>
            <td>
<%

}

%>