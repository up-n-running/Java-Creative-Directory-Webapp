<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.member.Member,
          com.extware.member.MemberContact,
          java.text.SimpleDateFormat"
%>
<%
//Get logged in user if there is a user logged in
Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

//if not logged in, sack them off
if( loggedInMember==null )
{
  %><jsp:forward page="/loggedOutNoChrome.jsp" /><%
  return;
}

MemberContact memberContact = loggedInMember==null ? null : ( loggedInMember.moderationMemberContact != null ? loggedInMember.moderationMemberContact : loggedInMember.memberContact );

//fetch all fields we're going to pass into worldpay
PropertyFile dataDictionary = PropertyFile.getDataDictionary();
float amount = dataDictionary.getInt( "membership.fullCostInPence" ) / 100.0f;

String address = memberContact==null ? "" : memberContact.address1;

if( memberContact != null && memberContact.address2!=null && memberContact.address2.length() > 0 )
{
  address += "&#10;" + memberContact.address2;
}

if( memberContact != null && memberContact.city!=null && memberContact.city.length() > 0 )
{
  address += "&#10;" + memberContact.city;
}

SimpleDateFormat cartIdDateFormat = new SimpleDateFormat( "yyyyMMddHHmmss" );
String cartId   = "MEM_" + loggedInMember.memberId + ( loggedInMember.expiryDate == null ? "" : "_" + cartIdDateFormat.format( loggedInMember.expiryDate ) );

String desc     = "One Year's Nextface Membership";

String postcode = memberContact==null ? "" : memberContact.postcode;
boolean isUK    = memberContact==null ? true : memberContact.countryRef==1;
String tel      = memberContact==null ? "" : memberContact.telephone;
String fax      = memberContact==null ? "" : memberContact.fax;
String email    = loggedInMember.email;

%>
<html>
<head>
  <title>Nextface Membership Payment</title>
  <link rel="stylesheet" type="text/css" href="/style/general.css"/>
</head>
<body>
<table width="430" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td height="1" width="3%"><img width="1" height="1" src="/art/blank.gif" /></td>
  <td width="3%"><img width="1" height="1" src="/art/blank.gif" /></td>
  <td width="406">
    <table cellpadding="0" cellspacing="0" border="0" width="406">
    <tr>
      <td>
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="memberpay1"/>
</jsp:include>
        <br />
<%

if( request.getParameter( "first" ) != null )
{

%>
        <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td nowrap="nowrap"><h6 class="burgundyh6"><a target="_parent" href="/pages/accountManager.jsp">Save what I've entered so far an i'll come back later</a></h6></td>
          <td width="100%"></td>
        </tr>
        </table>
<%

}
else
{

%>
        <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td nowrap="nowrap"><h6 class="burgundyh6"><a target="_parent" href="/pages/accountManager.jsp">Go back to account manager, i'll come back later</a></h6></td>
          <td width="100%"></td>
        </tr>
        </table>
<%

}

%>
        <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td nowrap="nowrap"><h6 style="background: none; margin-bottom: 0px;">Or proceed below...</h6></td>
          <td width="100%"></td>
        </tr>
        </table>
        <div class="h1style">&nbsp;</div>
        <br />

        <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td><img width="222" height="43" src="/art/paymentLogos.gif" /></td>
          <td class="worldpayLogoSpacing">...Payment cards accepted</td>
        </tr>
        <tr>
          <td><a href="http://www.worldpay.com" target="_blank"><img width="168" height="53" src="/art/worldPayLogo.gif" /></a></td>
          <td class="worldpayLogoSpacing">...Administered by WorldPay</td>
        </tr>
        </table>

        <br />
        <h5>Payment summary:</h5>
        <table width="100%" border="0" cellspacing="0" cellpadding="0" >
        <tr>
            <td style="padding-bottom: 5px"><b>Amount:</b></td>
            <td width="100%">&nbsp;£<%= amount %></td>
        </tr>
        <tr>
            <td><b>Description:</b></td>
            <td width="100%">&nbsp;<%= desc %></td>
        </tr>
        </table>

        <br />
        <h4>IMPORTANT: After clicking 'proceed' you will be taken to the WorldPay Secure Payment area. Once you have entered your payment details, be sure to wait untill you see a screen confirming the payment before closing the browser</h4>
        <br />
        <form action="https://select.worldpay.com/wcc/purchase" method=POST name="worldpay">
          <input type="hidden" name="instId" value="91648" />   <!-- done -->
          <input type="hidden" name="accId1" value="47013500" />
          <input type="hidden" name="authMode" value="A" />
          <input type="hidden" name="cartId" value="<%= cartId %>" />
          <input type="hidden" name="amount" value="<%= amount %>" />
          <input type="hidden" name="currency" value="GBP" />
          <input type="hidden" name="desc" value="<%= desc %>" />
          <input type="hidden" name="testMode" value="0" />
          <input type="hidden" name="address" value="<%= address %>" />
          <input type="hidden" name="postcode" value="<%= postcode %>" />
<%

if( isUK ) //UK
{

%>          <input type="hidden" name="country" value="GB" /><%

}

%>
          <input type="hidden" name="tel" value="<%= tel %>" />
          <input type="hidden" name="fax" value="<%= fax %>" />
          <input type="hidden" name="email" value="<%= email %>" />
          <input type="hidden" name="MC_callback" value="<%= dataDictionary.getString( "hostUrl" ) %>/pages/worldpay/worldpayFromFrame.jsp" />
          <table cellpadding="0" cellspacing="0" width="100%">
          <tr>
            <td width="100%"><a href="#" onclick="document.worldpay.submit(); return false;"><img width="152" height="20" src="/art/proceedToCheckout.gif" border="0" /></a></td>
            <td nowrap="nowrap" class="finiliseAccTxt">...Finalises your account setup</td>
          </tr>
          </table>
        </form>
        <div class="h1style">&nbsp;</div>
        <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td nowrap="nowrap"><h6 class="burgundyh6" style="text-align: left;"><a target="_parent"  href="/pages/accountManager.jsp">Exit to account manager</a></h6></td>
          <td nowrap="nowrap" class="linkAnnotation" width="100%">...This will keep your data and exit</td>
        </tr>
        </table>

        <br />
<jsp:include page="/text/text.jsp" flush="true">
  <jsp:param name="t" value="memberpay2"/>
</jsp:include>
      </td>
    </tr>
    </table>
  </td>
  <td width="3%"><img width="1" height="1" src="/art/blank.gif" /></td>
</tr>
<tr>
  <td height="1" width="3%"><img width="1" height="1" src="/art/blank.gif" /></td>
  <td height="1" width="3%"><img width="1" height="1" src="/art/blank.gif" /></td>
  <td width="406" height="1" ><img width="406" height="1" src="/art/blank.gif" /></td>
  <td height="1" width="3%"><img width="1" height="1" src="/art/blank.gif" /></td>
</tr>
</table>
</body>
</html>