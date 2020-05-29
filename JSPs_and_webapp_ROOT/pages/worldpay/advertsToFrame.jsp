<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils"
%>
<%
String cartId         = StringUtils.nullString(    request.getParameter( "cartId" ) );
String amount         = StringUtils.nullString(    request.getParameter( "amount" ) );
String desc           = StringUtils.nullString(    request.getParameter( "desc" ) );
String address        = StringUtils.nullString(    request.getParameter( "address" ) );
String postcode       = StringUtils.nullString(    request.getParameter( "postcode" ) );
boolean isUK          = BooleanUtils.parseBoolean( request.getParameter( "isUK" ) );
String tel            = StringUtils.nullString(    request.getParameter( "tel" ) );
String fax            = StringUtils.nullString(    request.getParameter( "fax" ) );
String email          = StringUtils.nullString(    request.getParameter( "email" ) );
String adFile         = StringUtils.nullString(    request.getParameter( "adFile" ) );
PropertyFile dataDictionary = PropertyFile.getDataDictionary();

%>
<html>
<head>
  <title>Nextface Advertising Payment</title>
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
  <jsp:param name="t" value="advertpay1"/>
</jsp:include>
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
          <td style="padding-bottom: 5px;"><b>Amount:</b></td>
          <td width="100%">&nbsp;£<%= amount %></td>
        </tr>
        <tr>
          <td style="padding-bottom: 13px;"><b>Description:</b></td>
          <td width="100%">&nbsp;<%= desc %></td>
        </tr>
        <tr>
          <td nowrap="nowrap" style="white-space: nowrap"><b>Advertisement preview:</b></td>
          <td width="100%">&nbsp;<%= adFile %></td>
        </tr>
        </table>
        <br />
        <h4>IMPORTANT: After clicking 'proceed' you will be taken to the WorldPay Secure Payment area. Once you have entered your payment details, be sure to wait untill you see a screen confirming the payment before closing the browser</h4>

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

if( isUK )
{

%>          <input type="hidden" name="country" value="GB" /><%

}

%>
          <input type="hidden" name="tel" value="<%= tel %>" />
          <input type="hidden" name="fax" value="<%= fax %>" />
          <input type="hidden" name="email" value="<%= email %>" />
          <input type="hidden" name="MC_callback" value="<%= dataDictionary.getString( "hostUrl" ) %>/pages/worldpay/worldpayFromFrame.jsp" />

          <br />
          <table cellpadding="0" cellspacing="0" width="100%">
          <tr>
            <td width="100%"><a href="#" onclick="document.worldpay.submit(); return false;"><img width="152" height="20" src="/art/proceedToCheckout.gif" border="0" /></a></td>
            <td nowrap="nowrap" class="finiliseAccTxt">...Finalise your account setup</td>
          </tr>
          </table>
        </form>

        <div class="h1style">&nbsp;</div>
        <br />

        <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
          <td nowrap="nowrap"><h6 class="burgundyh6" style="text-align: left;"><a target="_parent" onclick="window.history.go( -1 ); return false;" href="/pages/accountManager.jsp">Go back and change the details</a></h6></td>
          <td nowrap="nowrap" class="linkAnnotation" width="100%">...Back to previous page</td>
        </tr>
        </table>

        <br />
<jsp:include page="/text/text.jsp" flush="true">
  <jsp:param name="t" value="advertpay2"/>
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