<%@ page language="java"
  import="com.extware.advert.Advert,
          com.extware.advert.sql.AdvertSql,
          com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.utils.StringUtils,
          com.extware.utils.PropertyFile,
          java.util.ArrayList"
%><%
//Get logged in user if there is a user logged in
Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

if( AdvertSql.findUnpaidAdvertFileSpaceMB() >= dataDictionary.getInt( "advertFile.maxUnpaidStorageMegaBytes" ) )
{
  %><jsp:forward page="/pages/infoPage.jsp?page=cannotupload" /><%
  return;
}

//where are we going to redirect to on form submission - default to portfolio files form
String redirectTo = "/pages/advertsPayment.jsp";

if( request.getParameter( "divertto" )!=null && request.getParameter( "divertto" ).equals( "accountman" ) )
{
  redirectTo = "/pages/accountManager.jsp";
}

//hold the details of the objects used to populate the form.
Advert formPopulateAdvert = (Advert)request.getAttribute( "adverttoverify" );
MemberContact memberContactFallback = loggedInMember==null ? null : ( loggedInMember.moderationMemberContact != null ? loggedInMember.moderationMemberContact : loggedInMember.memberContact );
Member memberFallback = loggedInMember;


ArrayList errorsToReport = (ArrayList)request.getAttribute( "errors" );
if( errorsToReport != null && errorsToReport.size() > 0 )
{
  formPopulateAdvert = (Advert)request.getAttribute( "formadvert" );
}

//temp variables needed to fill jsp params
String v = null;
String c1v = null;
String c2v = null;
String c3v = null;
String o1 = null;
String o2 = null;

//property file for prices and dtrations of adverts
int noOfOptions = dataDictionary.getInt( "advertising.noOfOptions" );

int durationMonths = dataDictionary.getInt( "advertising.durationInMonths" );
int permiereCost = dataDictionary.getInt( "advertising.permiereCostPerMonthInPence" ) * durationMonths / 100;
int standardCost = dataDictionary.getInt( "advertising.standardCostPerMonthInPence" ) * durationMonths / 100;

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<%

//if we are returning from reg servlet with errors, the user has to scroll down to see the errors, so alert then here also that somneting is amiss
if( errorsToReport != null )
{

%>
<p class="error">There were some problems with the data you entered, please address the issues listed below, reselect your advert image file and try again.<p>
<%

}

java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat( "yyyy/MM/dd - HH:mm:ss");
java.util.Date[] adAvailability = AdvertSql.getAdvertAvailability();

%>
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="advert1"/>
</jsp:include>

<h4>Premier position advertising, <span class="orange"><%= ( adAvailability[ 0 ] == null) ? "available now." : "next availability: " + sdf.format( adAvailability[ 0 ] ) %></span></h4>
<table width="100%" border="0" cellspacing="0" cellpadding="0" >
<%
for( int i = 1 ; i <= noOfOptions ; i++ )
{
%><tr>
  <td nowrap="nowrap" style="white-space: nowrap"><h5 class="adOptionPriceList"><%= dataDictionary.getInt( "advertising.option." + i + ".durationInMonths" ) %> months:</h5></td>
  <td class="adOptionPriceCell"><h5 class="adOptionPriceList">£<%= dataDictionary.getInt( "advertising.option." + i + ".permiereCostPounds" ) %> (inc VAT)</h5></td>
</tr>
<%
}
%></table>
<h4 style="margin-top: 8px">Standard position advertising, <span class="orange"><%= ( adAvailability[ 1 ] == null) ? "available now." : "next availability: " + sdf.format( adAvailability[ 1 ] ) %></span></h4>
<table width="100%" border="0" cellspacing="0" cellpadding="0" >
<%

for( int i = 1 ; i <= noOfOptions ; i++ )
{
%><tr>
  <td nowrap="nowrap" style="white-space: nowrap"><h5 class="adOptionPriceList"><%= dataDictionary.getInt( "advertising.option." + i + ".durationInMonths" ) %> months:</h5></td>
  <td class="adOptionPriceCell"><h5 class="adOptionPriceList">£<%= dataDictionary.getInt( "advertising.option." + i + ".standardCostPounds" ) %> (inc VAT)</h5></td>
</tr>
<%

}

%></table>
<br />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="advert2"/>
</jsp:include>

<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6"><a href="/pages/accountManager.jsp">Not right now, I'll think about it</a></h6></td><td width="100%"></td>
</tr>
</table>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="linkNoTarget">Or proceed below...</h6></td>
  <td width="100%"></td>
</tr>
</table>

<br />
<%

//if we are returning from reg servlet with errors
if( errorsToReport != null )
{

%>
<p>There were some problems with the data you entered, please address the issues listed below, reselect your advert image file and try again.<p>
<%

  for( int i=0; i<errorsToReport.size(); i++ )
  {

%><p class="error"><%= (String)errorsToReport.get( i ) %></p>
<%

  }
}

%>
<br />
<h4>Advertising account setup</h4>
<form name="advertedit" method="post" action="/servlet/Adverts" enctype="multipart/form-data">
  <input type="hidden" name="form" value="jobedit" />
  <input type="hidden" name="redirectto" value="<%= redirectTo %>" />
  <input type="hidden" name="mode" value="add" />
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="formTable">
  <tr>
    <td class="formLabel">Organisation name*</td>
    <td class="formElementCell"><input class="formElement" name="name" type="text" value="<%= formPopulateAdvert == null ? ( memberContactFallback==null ? "" : memberContactFallback.name ) : formPopulateAdvert.name %>" maxlength="200" /></td>
  </tr>
<%

v =  formPopulateAdvert == null ? ( memberContactFallback==null ? "" : String.valueOf( memberContactFallback.statusRef ) ) : String.valueOf( formPopulateAdvert.statusRef );
o1 = formPopulateAdvert == null ? ( memberContactFallback==null ? "" : memberContactFallback.statusOther ) : formPopulateAdvert.statusOther;

%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="advertedit"/>
  <jsp:param name="dropdownlabel" value="Your Status*"/>
  <jsp:param name="dropdownname"  value="advertstatusref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="other1label" value="Other"/>
  <jsp:param name="other1name"  value="statusother"/>
  <jsp:param name="other1value" value="<%= o1 %>"/>
</jsp:include>
<%

v = formPopulateAdvert == null ? ( memberContactFallback==null ? "" : String.valueOf( memberContactFallback.countryRef ) ) : String.valueOf( formPopulateAdvert.countryRef );

%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="advertedit"/>
  <jsp:param name="dropdownlabel" value="Country (Base of Operation)*"/>
  <jsp:param name="dropdownname"  value="countryref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="bespokespecialtreatment" value="countryukcheck"/>
</jsp:include>
<%

v = formPopulateAdvert == null ? ( memberContactFallback==null ? "" : String.valueOf( memberContactFallback.regionRef ) ) : String.valueOf( formPopulateAdvert.regionRef );
c1v = formPopulateAdvert == null ? ( memberContactFallback==null ? "" : String.valueOf( memberContactFallback.countyRef ) ) : String.valueOf( formPopulateAdvert.countyRef );
String p1 = formPopulateAdvert==null ? ( memberContactFallback==null ? "" : memberContactFallback.address1 ) : formPopulateAdvert.address1;
String p2 = formPopulateAdvert==null ? ( memberContactFallback==null ? "" : memberContactFallback.address2 ) : formPopulateAdvert.address2;
String p3 = formPopulateAdvert==null ? ( memberContactFallback==null ? "" : memberContactFallback.city ) : formPopulateAdvert.city;
String p4 = formPopulateAdvert==null ? ( memberContactFallback==null ? "" : memberContactFallback.postcode ) : formPopulateAdvert.postcode;

%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="advertedit"/>
  <jsp:param name="dropdownlabel" value="UK region*"/>
  <jsp:param name="dropdownname"  value="ukregionref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="bespokespecialtreatment" value="addressinsert"/>
  <jsp:param name="address1" value="<%= p1 %>"/>
  <jsp:param name="address2" value="<%= p2 %>"/>
  <jsp:param name="city" value="<%= p3 %>"/>
  <jsp:param name="postcode" value="<%= p4 %>"/>
  <jsp:param name="child1label"   value="County / Unitary authority*"/>
  <jsp:param name="child1name"    value="countyref"/>
  <jsp:param name="child1value"   value="<%= c1v %>"/>
</jsp:include>
 <tr>
    <td class="formLabel">Telephone number*</td>
    <td class="formElementCell"><input class="formElement" name="telephone" value="<%= formPopulateAdvert==null ? ( memberContactFallback==null ? "" : memberContactFallback.telephone ) : formPopulateAdvert.telephone %>" type="text" maxlength="200" /></td>
  </tr>
  <tr>
    <td class="formLabel">Fax number</td>
    <td class="formElementCell"><input class="formElement" name="fax" value="<%= formPopulateAdvert==null ? ( memberContactFallback==null ? "" : memberContactFallback.fax ) : formPopulateAdvert.fax %>" type="text" maxlength="200" /></td>
  </tr>
  <tr>
    <td class="formLabel">Email address*</td>
    <td class="formElementCell"><input class="formElement" name="email" value="<%= formPopulateAdvert==null ? ( memberFallback==null ? "" : memberFallback.email ) : formPopulateAdvert.email %>" type="text" maxlength="200" /></td>
  </tr>
  <tr>
    <td class="formLabel">Confirm email address*</td>
    <td class="formElementCell"><input class="formElement" name="confirmemail" value="<%= (   (String)request.getAttribute( "confirmemail" )!=null   ?   (String)request.getAttribute( "confirmemail" )   :   (formPopulateAdvert==null ? ( memberFallback==null ? "" : memberFallback.email ) : formPopulateAdvert.email)    ) %>" type="text" maxlength="200" /></td>
  </tr>
<%

String webAddressVal = formPopulateAdvert==null ? ( memberContactFallback==null ? "" : memberContactFallback.webAddress ) : formPopulateAdvert.webAddress;

if( !webAddressVal.toUpperCase().startsWith( "HTTP://" ) )
{
  webAddressVal = "http://" + webAddressVal;
}

%>
  <tr>
    <td class="formLabel"><b>Web address*</b></td>
    <td class="formElementCell"><input class="formElement" name="webaddress" value="<%= webAddressVal %>" type="text" maxlength="200" /></td>
  </tr>
  <tr>
    <td class="formLabel">Confirm web address*</td>
    <td class="formElementCell"><input class="formElement" name="confirmwebaddress" value="<%= (   (String)request.getAttribute( "confirmwebaddress" )!=null   ?   (String)request.getAttribute( "confirmwebaddress" )   :   webAddressVal  ) %>" type="text" maxlength="200" /></td>
  </tr>
  <tr>
    <td class="formLabel" colspan="2">We will use this address/URL as the target for your advert banner<br /><br /></td>
  </tr>
<%

v = formPopulateAdvert==null ? ( memberContactFallback==null ? "" : String.valueOf( memberContactFallback.whereDidYouHearRef ) ) : String.valueOf( formPopulateAdvert.whereDidYouHearRef );
o1 = formPopulateAdvert==null ? ( memberContactFallback==null ? "" : memberContactFallback.whereDidYouHearOther ) : formPopulateAdvert.whereDidYouHearOther;
o2 = formPopulateAdvert==null ? ( memberContactFallback==null ? "" : memberContactFallback.whereDidYouHearMagazine ) : formPopulateAdvert.whereDidYouHearMagazine;

%>
<jsp:include page="/inc/dropdown.jsp" flush="true" >
  <jsp:param name="formname" value="advertedit"/>
  <jsp:param name="dropdownlabel" value="Where did you hear about Nextface?*"/>
  <jsp:param name="dropdownname"  value="wheredidyouhearref"/>
  <jsp:param name="dropdownvalue" value="<%= v %>"/>
  <jsp:param name="other1label" value="Other"/>
  <jsp:param name="other1name"  value="wheredidyouhearother"/>
  <jsp:param name="other1value" value="<%= o1 %>"/>
  <jsp:param name="other2label" value="Magazine name"/>
  <jsp:param name="other2name"  value="wheredidyouhearmagazine"/>
  <jsp:param name="other2value" value="<%= o2 %>"/>
</jsp:include>
  </table>

  <br />
  <h4>Browse to your advertisement graphic</h4>
  <table cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td><input class="bigFormElement" type="file" name="advertfile" size="50" /></td>
  </tr>
  </table>
  <br />
<script type="text/javascript">
  noOfOptions = <%= noOfOptions %>;
  function setCheckBox( premiere, optNo )
  {
    for( i = 1 ; i <= noOfOptions ; i++ )
    {
      theForm = document.forms[ 'advertedit' ];
      theForm.elements[ 'premiereposition' + i ].checked=false;
      theForm.elements[ 'standardposition' + i ].checked=false;
    }
    adtype = premiere ? 'premiere' : 'standard';
    theForm.elements[ adtype + 'position' + optNo ].checked=true;
  }
</script>
<table width="100%" border="0" cellspacing="0" cellpadding="0" >
<%

for( int i = 1 ; i <= noOfOptions ; i++ )
{

%><tr>
  <td class="adOptionHead"><b>Premier position <%= dataDictionary.getInt( "advertising.option." + i + ".durationInMonths" ) %> months</b></td><td><input name="premiereposition<%= i %>" value="t" type="checkbox" <%= ( formPopulateAdvert != null && formPopulateAdvert.premierePosition && ( StringUtils.nullString( (String)request.getAttribute( "optionnumber" ) ).equals( String.valueOf( i ) ) ) ) ? "checked=\"checked\" " : "" %> onclick="setCheckBox( true, <%= i %> );" /></td><td class="adOptionCost"> £<%= dataDictionary.getInt( "advertising.option." + i + ".permiereCostPounds" ) %> (inc VAT)</td>
</tr>
<%

}
for( int i = 1 ; i <= noOfOptions ; i++ )
{

%><tr>
  <td class="adOptionHead"><b>Standard position <%= dataDictionary.getInt( "advertising.option." + i + ".durationInMonths" ) %> months</b></td><td><input name="standardposition<%= i %>" value="t" type="checkbox" <%= ( formPopulateAdvert != null && !formPopulateAdvert.premierePosition && ( StringUtils.nullString( (String)request.getAttribute( "optionnumber" ) ).equals( String.valueOf( i ) ) ) ) ? "checked=\"checked\" " : "" %> onclick="setCheckBox( false, <%= i %> );" /></td><td class="adOptionCost"> £<%= dataDictionary.getInt( "advertising.option." + i + ".standardCostPounds" ) %> (inc VAT)</td>
</tr>
<%

}

%>
</table>
<br />
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td class="adEditTandCAnnotation">I have read the</td>
  <td nowrap="nowrap"><h6 class="listTitle"><a target="_blank" href="list.jsp?l=terms">Terms & Conditions</a></h6></td>
  <td><input id="termschk" name="termscheck" value="t" type="checkbox"></td>
  <td class="adEditTandCAnnotation">Tick box to confirm</td>
</tr>
</table>
<br />
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6><a onclick="if( document.getElementById( 'termschk' ).checked ) { document.forms[ 'advertedit' ].submit(); return false; } else { alert( 'Please confirm that you have read the terms & conditions by clicking the checkbox above' ); return false; }" href="">See preview and continue to secure payment area</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
</form>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />
