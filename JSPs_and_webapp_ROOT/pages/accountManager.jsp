<%@ page language="java"
  import="com.extware.member.MemberClient,
          com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.utils.BooleanUtils,
          com.extware.utils.PropertyFile,
          java.net.URLEncoder,
          java.util.Date"
%><%

//Get logged in user
Member member = (Member)request.getSession().getAttribute( "member" );

//if not logged in, sack them off
if( member==null )
{
  %><jsp:forward page="/loggedOut.jsp" /><%
  return;
}

//if email not validated, check they havent validated since last logging in
if( !member.emailValidated )
{
  MemberClient.checkIfValidatedYet( member );   //this will update object if thay have just validated their email
}

//if just got back from worldpay,update their details
if( BooleanUtils.isTrue( (String)request.getSession().getAttribute( "inworldpay" ) ) )
{
  member = MemberClient.loadFullMember( member.memberId );
  request.getSession().removeAttribute( "inworldpay" );
}

PropertyFile dataDictionary = PropertyFile.getDataDictionary();
float amount = dataDictionary.getInt( "membership.fullCostInPence" ) / 100.0f;
MemberContact memberContact = member.memberContact==null ? member.moderationMemberContact : member.memberContact;
Date now = new Date();
boolean live = member.goLiveDate!=null && member.expiryDate.after( now );
boolean showProfilePreviewLink = !live;

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<h1>Welcome back<%
if( memberContact != null )
{
%>, <%= memberContact.name %><%
}
%></h1>

<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td width="100%" style="padding-right: 15px"><jsp:include page="/text/text.jsp" flush="true"><jsp:param name="t" value="accman1"/></jsp:include></td>
  <td align="right"><img width="104" height="115" src="/art/filingCabinet.gif" /></td>
</tr>
</table>

<h4>Your current account status: <%= member.goLiveDate!=null ? ( member.expiryDate.after( now ) ? "<span style=\"color: #488BFF\">Live!</span>" : "<span style=\"color: #FC7A04\">Expired!</span>" ) : "<span style=\"color: #FC7A04\">Not live!</span>" %></h4>

<br />
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<%

String tickCrossImage = ( member.moderationMemberContact!=null || member.memberContact!=null ) ? "/art/tickInCircle.gif" : "/art/crossInCircle.gif";
String awaitingModeration = ( member.moderationMemberContact!=null ) ? "<img width=\"67\" height=\"20\" src=\"/art/awaitingModeration.gif\" />" : "&nbsp;";
String editLink = ( member.moderationMemberContact!=null || member.memberContact!=null ) ? "View/Edit" : "Add";
boolean orangeLink = !( member.moderationMemberContact!=null || member.memberContact!=null );
showProfilePreviewLink = showProfilePreviewLink || !awaitingModeration.equals( "&nbsp;" );

%>
<tr>
   <td width="403" height="23" colspan="3" class="accManShadeRow">
     <table width="100%" cellpadding="0" cellspacing="0" border="0">
     <tr>
       <td width="15"><img width="15" height="25" src="/art/accManDot.gif" /></td>
       <td class="accManShadeRowTxt">Registered?</td>
       <td width="20" style="padding-top: 3px"><img width="20" height="20" src="<%= tickCrossImage %>" /></td>
       <td style="padding-top: 3px; padding-left: 5px; width: 67px"><%= awaitingModeration %></td>
       <td class="accManShadeRowLinkTxt"><%= orangeLink ? "<span class=\"orange\">" : "" %><a href="/pages/registerContactDetails.jsp?mode=edit&divertto=accountman"><%= editLink %></a><%= orangeLink ? "</span>" : "" %></td>
     </tr>
     </table>
   </td>
</tr>
<tr>
  <td><p>Name addresses, numbers, etc</p></td>
</tr>
<%

tickCrossImage = ( member.moderationMemberProfile!=null || member.memberProfile!=null ) ? "/art/tickInCircle.gif" : "/art/crossInCircle.gif";
awaitingModeration = ( member.moderationMemberProfile!=null ) ? "<img width=\"67\" height=\"20\" src=\"/art/awaitingModeration.gif\" />" : "&nbsp;";
editLink = ( member.moderationMemberProfile!=null || member.memberProfile!=null ) ? "View/Edit" : "Add";
orangeLink = !( member.moderationMemberProfile!=null || member.memberProfile!=null );
showProfilePreviewLink = showProfilePreviewLink || !awaitingModeration.equals( "&nbsp;" );

%>
<tr>
   <td width="403" height="23" colspan="3" class="accManShadeRow">
     <table width="100%" cellpadding="0" cellspacing="0" border="0">
     <tr>
       <td width="15"><img width="15" height="25" src="/art/accManDot.gif" /></td>
       <td class="accManShadeRowTxt">Profile details added?</td>
       <td width="20" style="padding-top: 3px"><img width="20" height="20" src="<%= tickCrossImage %>" /></td>
       <td style="padding-top: 3px; padding-left: 5px; width: 67px"><%= awaitingModeration %></td>
       <td class="accManShadeRowLinkTxt"><%= orangeLink ? "<span class=\"orange\">" : "" %><a href="/pages/registerProfileDetails.jsp?mode=edit&divertto=accountman"><%= editLink %></a><%= orangeLink ? "</span>" : "" %></td>
     </tr>
     </table>
   </td>
</tr>
<tr>
  <td><p>Statement, specialisations, etc</p></td>
</tr>
<%

tickCrossImage = ( member.moderationMemberFiles.size() > 0 || member.memberFiles.size() > 0 ) ? "/art/tickInCircle.gif" : "/art/crossInCircle.gif";
awaitingModeration = ( member.moderationMemberFiles.size() > 0 ) ? "<img width=\"67\" height=\"20\" src=\"/art/awaitingModeration.gif\" />" : "&nbsp;";
editLink = ( member.moderationMemberFiles.size() > 0 || member.memberFiles.size() > 0 ) ? "View/Edit" : "Add";
orangeLink = !( member.moderationMemberFiles.size() > 0 || member.memberFiles.size() > 0 );
showProfilePreviewLink = showProfilePreviewLink || !awaitingModeration.equals( "&nbsp;" );

%>
<tr>
   <td width="403" height="23" colspan="3" class="accManShadeRow">
     <table width="100%" cellpadding="0" cellspacing="0" border="0">
     <tr>
       <td width="15"><img width="15" height="25" src="/art/accManDot.gif" /></td>
       <td class="accManShadeRowTxt">Portfolio files uploaded?</td>
       <td width="20" style="padding-top: 3px"><img width="20" height="20" src="<%= tickCrossImage %>" /></td>
       <td style="padding-top: 3px; padding-left: 5px; width: 67px"><%= awaitingModeration %></td>
       <td class="accManShadeRowLinkTxt"><%= orangeLink ? "<span class=\"orange\">" : "" %><a href="/pages/registerPortfolioFiles.jsp?divertto=accountman"><%= editLink %></a><%= orangeLink ? "</span>" : "" %></td>
     </tr>
     </table>
   </td>
</tr>
<tr>
  <td><p>Portfolio images and files, etc</p></td>
</tr>
<%

tickCrossImage = ( member.emailValidated ) ? "/art/tickInCircle.gif" : "/art/crossInCircle.gif";
awaitingModeration = "&nbsp;";
editLink = ( member.emailValidated ) ? "Edit email" : "Help!";
orangeLink = !( member.emailValidated );
String footerDesc = ( !member.emailValidated ) ? "We've sent you an email, please read it to find out more" : "You have validated your email address";

%>
<tr>
   <td width="403" height="23" colspan="3" class="accManShadeRow">
     <table width="100%" cellpadding="0" cellspacing="0" border="0">
     <tr>
       <td width="15"><img width="15" height="25" src="/art/accManDot.gif" /></td>
       <td class="accManShadeRowTxt">Email address validated?</td>
       <td width="20" style="padding-top: 3px"><img width="20" height="20" src="<%= tickCrossImage %>" /></td>
       <td style="padding-top: 3px; padding-left: 5px; width: 2px"><%= awaitingModeration %></td>
       <td class="accManShadeRowTxt" style="width: 151px; text-align: right; padding-right: 18px"><%= orangeLink ? "<span class=\"orange\">" : "" %><a href="/pages/emailAdmin.jsp?divertto=accountman"><%= editLink %></a><%= orangeLink ? "</span>" : "" %></td>
     </tr>
     </table>
   </td>
</tr>
<tr>
  <td><p><%= footerDesc %></p></td>
</tr>
<%

  boolean paid = ( member.lastPaymentDate!=null && ( member.expiryDate == null || member.expiryDate.after( now ) ) );
  tickCrossImage = ( paid ) ? "/art/tickInCircle.gif" : "/art/crossInCircle.gif";
  awaitingModeration = "&nbsp;";
  editLink = ( paid ) ? "Pay again" : "Pay now";
  footerDesc = ( !paid ) ? "Payment of £" + amount + " makes your membership live" : "Payment of £" + amount + " extends your membership by another year";
  orangeLink = !paid;
  boolean alertFirst = !member.emailValidated;

%>
<tr>
   <td width="403" height="23" colspan="3" class="accManShadeRow">
     <table width="100%" cellpadding="0" cellspacing="0" border="0">
     <tr>
       <td width="15"><img width="15" height="25" src="/art/accManDot.gif" /></td>
       <td class="accManShadeRowTxt">Membership paid?</td>
       <td width="20" style="padding-top: 3px"><img width="20" height="20" src="<%= tickCrossImage %>" /></td>
       <td style="padding-top: 3px; padding-left: 5px; width: 67px"><%= awaitingModeration %></td>
       <td class="accManShadeRowLinkTxt"><%= orangeLink ? "<span class=\"orange\">" : "" %><a <%= alertFirst ? "onclick=\"return confirm( 'You should validate your email address before making payment, check your inbox now for details. If there\\'s a problem and our moderation team cannot contact you because of an invalid email address, we reserve the right to take your profile offline without refund. Are you sure you want to coninue to make payment before you\\'ve validated your email address?' );\"" : ""%> href="/pages/registerPayment.jsp?divertto=accountman"><%= editLink %></a><%= orangeLink ? "</span>" : "" %></td>
     </tr>
     </table>
  </td>
</tr>
<tr>
  <td width="403"><p><%= footerDesc %></p></td>
</tr>
<%

  if( showProfilePreviewLink )
  {
    awaitingModeration = "&nbsp;";
    editLink = "Preview";
    footerDesc = "Preview of your profile (before <span class=\"orange\"><a href=\"/pages/list.jsp?l=moderation\" target=\"_blank\">moderation</a></span>)";

%>
<tr>
   <td width="403" height="23" colspan="3" class="accManShadeRow">
     <table width="100%" cellpadding="0" cellspacing="0" border="0">
     <tr>
       <td width="15"><img width="15" height="25" src="/art/accManDot.gif" /></td>
       <td class="accManShadeRowTxt">Preview my profile</td>
       <td width="20" style="padding-top: 3px">&nbsp</td>
       <td style="padding-top: 3px; padding-left: 5px; width: 67px"><%= awaitingModeration %></td>
       <td class="accManShadeRowLinkTxt"><span class="orange"><a href="/pages/profileDetails.jsp?preview=true&backtodesc=Account+Manager&returnTo=<%= URLEncoder.encode( "/pages/accountManager.jsp" ) %>"><%= editLink %></a></span></td>
     </tr>
     </table>
  </td>
</tr>
<tr>
  <td width="403"><p><%= footerDesc %></p></td>
</tr>
<%

  }

%>
</table>
<div class="h1style">&nbsp;</div>
<h4>Additional functions:</h4>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<%

  boolean placedJobs = ( member.memberJobs.size() > 0 );
  tickCrossImage = ( placedJobs ) ? "/art/tickInCircle.gif" : "/art/crossInCircle.gif";
  awaitingModeration = ( member.areThereJobsAwaitingModeration() ) ? "<img width=\"67\" height=\"20\" src=\"/art/awaitingModeration.gif\" />" : "&nbsp;";
  editLink = ( placedJobs ) ? "View/Edit" : "Add";
  orangeLink = !placedJobs;
  footerDesc = ( live ) ? "Post a" + ( placedJobs ? "nother" : "" ) + " job vacancy for free" : "Post your job vacancies for free when you are a fully paid member";

%>
<tr>
   <td width="403" height="23" colspan="3" class="accManShadeRow"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
     <td width="15"><img width="15" height="25" src="/art/accManDot.gif" /></td>
     <td class="accManShadeRowTxt">Add job vacancy?</td>
     <td width="20" style="padding-top: 3px"><img width="20" height="20" src="<%= tickCrossImage %>" /></td>
     <td style="padding-top: 3px; padding-left: 5px; width: 67px"><%= awaitingModeration %></td>
     <td class="accManShadeRowLinkTxt"><%= orangeLink ? "<span class=\"orange\">" : "" %><a href="/pages/jobsEdit.jsp?mode=add"><%= editLink %></a><%= orangeLink ? "</span>" : "" %></td>
   </tr></table></td>
</tr>
<tr>
  <td><p><%= footerDesc %></p></td>
</tr>
<%

  tickCrossImage = ( member.placedAdvert ) ? "/art/blank.gif" : "/art/blank.gif";
  awaitingModeration = "&nbsp;";
  editLink = "Place advert";
  orangeLink = true;

%>
<tr>
   <td width="403" height="23" colspan="3" class="accManShadeRow"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
     <td width="15"><img width="15" height="25" src="/art/accManDot.gif" /></td>
     <td class="accManShadeRowTxt">Advertise with Nextface?</td>
     <td width="20" style="padding-top: 3px"><img width="20" height="20" src="<%= tickCrossImage %>" /></td>
     <td style="padding-top: 3px; padding-left: 5px; width: 47px"><%= awaitingModeration %></td>
     <td class="accManShadeRowLinkTxt" style="width: 108px;"><%= orangeLink ? "<span class=\"orange\">" : "" %><a href="/pages/advertsEdit.jsp?"><%= editLink %></a><%= orangeLink ? "</span>" : "" %></td>
   </tr></table></td>
</tr>
<tr>
  <td><p>Advertise on the Nextface Creative & Design Directory</p></td>
</tr>
</table>
<br />
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td width="160"><table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6 class="orangeh6"><a href="/pages/contactUs.jsp?mode=comment">Contact us</a></h6></td><td width="100%"></td></tr></table></td>
  <td width="20"></td>
  <td><p>...Send us your suggestions, comments or complaints.</p></td>
</tr>
<tr>
  <td width="160"><table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6 class="orangeh6"><a href="/pages/contactUs.jsp?mode=news">Suggest news item</a></h6></td><td width="100%"></td></tr></table></td>
  <td width="20"></td>
  <td><p>...Send us a news article and we'll put it up for free</p></td>
</tr>
<tr>
  <td width="160"><table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6 class="burgundyh6"><a href="/pages/deleteAccount.jsp">Delete my account</a></h6></td><td width="100%"></td></tr></table></td>
  <td width="20"></td>
  <td><p>...Delete your account from our directory</p></td>
</tr>
</table>
<div class="h1style">&nbsp;</div>
<table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6><a href="/index.jsp">Exit to homepage</a></h6></td><td width="100%"></td></tr></table>
<jsp:include page="/inc/pageFoot.jsp" flush="true"/>
