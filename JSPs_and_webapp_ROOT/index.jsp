<%@ page language="java"
         import="com.extware.member.Member,
                 com.extware.member.MemberClient,
                 com.extware.member.MemberContact,
                 com.extware.member.MemberFile,
                 java.net.URLEncoder,
                 java.util.ArrayList"
%><%
int memberOfWeekId = MemberClient.getMemberOfWeekId( );
Member memberOfWeek = MemberClient.loadFullMember( memberOfWeekId );
ArrayList memberFiles = memberOfWeek.memberFiles;
MemberContact memberContact = memberOfWeek.memberContact;
//added specialOffer div and 'id="mainPage"' on main table declaration for march only

%>
<jsp:include page="/inc/pageHead.jsp" flush="true"/>
<div id="specialOffer"><img width="208" height="63" src="/art/FreeOfferPopUp.gif" /></div>
<script type="text/javascript" language="javascript1.2" src="/js/imageSlideshow.js"></script>
<script type="text/javascript" language="javascript1.2">
//SET IMAGE PATHS.
<%

MemberFile tempFile;
int fileNo = 0;

for( int i = 0 ; i < memberFiles.size() ; i++ )
{
  tempFile = (MemberFile)memberFiles.get( i );

  if( !tempFile.portraitImage && tempFile.isImage )
  {

%>  fadeimages[ <%= fileNo %> ] = "<%= tempFile.getHtmlFileName( "MemberOfWeekImage" ) %>"; fadedescriptions[ <%= fileNo++ %> ] = "<%= tempFile.description %>";
<%

  }
}

%>
if( fadeimages.length == 1 )
{
  fadeimages[ 1 ] = fadeimages[ 0 ];
  fadedescriptions[ 1 ] = fadedescriptions[ 0 ];
}
</script>
<jsp:include page="/text/text.jsp" flush="true">
  <jsp:param name="t" value="homepage1"/>
</jsp:include>
<table id="mainPage" border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td><h6 style="text-align: left"><a href="/pages/list.jsp?l=faqs">Who can join? - Category options</a></h6></td>
  <td width="100%"><h6><a href="/pages/registerJoinup.jsp">How do I join?</a></h6></td>
</tr>
</table>
<div class="h1style">featured work of the week</div>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td rowspan="2" width="218" height="300">
<script type="text/javascript" language="JavaScript1.2">
if( fadeimages.length > 0 )
{
  if (ie4||dom)
    document.write( '<div style="position:relative;width:'+slideshow_width+';height:'+slideshow_height+';overflow:hidden"><div id="canvas0" style="z-index: 0;position:absolute;width:'+slideshow_width+';height:'+slideshow_height+';top:0;left:0;filter:alpha(opacity=10);-moz-opacity:10;background-color: #FFFFFF;"></div><div id="canvas1" style="z-index: 1; position:absolute;width:'+slideshow_width+';height:'+slideshow_height+';top:0;left:0;filter:alpha(opacity=10);-moz-opacity:10;background-color: #FFFFFF;"></div></div>' );
  else
    document.write( '<img name="defaultslide" src="'+fadeimages[0]+'">' );
}
</script>
  </td>
  <td valign="top">
    <table cellpadding="0" cellspacing="0" width="100%">
      <tr><td class="featName"><%= memberContact.name %></td></tr>
      <tr><td class="featPlace" style="padding-top: 4px"><%= memberContact.getPrimaryDisciplineDesc() %></td></tr><%
%><%= memberContact.getSecondaryDisciplineDesc()==null ? "" : "    <tr><td class=\"featPlace\">" + memberContact.getSecondaryDisciplineDesc() + "</td></tr>\n" %><%
%><%= memberContact.getTertiaryDisciplineDesc()==null  ? "" : "    <tr><td class=\"featPlace\">" + memberContact.getTertiaryDisciplineDesc()  + "</td></tr>\n" %><%
%>      <tr><td class="featPlace" style="padding-top: 6px"><%= memberContact.city %></td></tr><%
%><%= memberContact.getRegionDesc()==null ? "" : "    <tr><td class=\"featPlace\">" + memberContact.getRegionDesc() + "</td></tr>\n" %><%
%>      <tr><td class="featPlace"><%= memberContact.getCountryDesc() %></td></tr>
      <tr><td height="10px"></td></tr>
      <tr><td align="right" nowrap="nowrap"><h6 class="orangeh6"><a href="/pages/profileDetails.jsp?memberId=<%= memberOfWeek.memberId %>&backtodesc=Homepage&returnTo=<%= URLEncoder.encode( "/" ) %>">Show full portfolio</a></h6></td></tr>
    </table>
  </td>
</tr>
</table>
<div class="h1style">Recently joined</div>
<table border="0" cellpadding="7" cellspacing="0">
<tr>
<%

ArrayList newImageMembers = MemberClient.getLatestMainImages( 6 );
Member tempMember;
String cellHTML = "";


for( int i = 0 ; i < newImageMembers.size() ; i++ )
{
  tempMember = (Member)newImageMembers.get( i );
  tempFile = (MemberFile)tempMember.memberFiles.get( 0 );

  cellHTML = "<a href=\"/pages/profileDetails.jsp?memberId=" + tempMember.memberId + "&returnTo=" + URLEncoder.encode( "/" ) + "&backtodesc=Homepage\">" + tempFile.getPostProcessAssetHtml( "SrchResults" ) + "</a>";

%>  <td width="56" height="56" <%= ( i == 0 ) ? "style=\"padding-left: 0px\"" : "" %><%= ( i == 5 ) ? "style=\"padding-right: 0px\"" : "" %>><%= cellHTML %></td>
<%

}

%>
</tr>
</table>
<jsp:include page="/inc/pageFoot.jsp" flush="true"/>