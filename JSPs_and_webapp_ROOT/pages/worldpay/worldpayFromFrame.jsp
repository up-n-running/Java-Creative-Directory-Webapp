<%@ page language="java"
  import="com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.DatabaseUtils,
          com.extware.member.Member,
          com.extware.member.MemberClient,
          com.extware.advert.sql.AdvertSql,
          com.extware.advert.Advert,
          com.extware.emailSender.EmailSender,
          java.util.ArrayList,
          java.sql.Connection,
          java.sql.Types,
          java.sql.PreparedStatement,
          java.text.SimpleDateFormat"
%>
<%
//find logged in member if there is one (99% of the time this page wil be called form worldpay servers so there will be none).
Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

//get all world pay params - most are ignored
String instId           = StringUtils.nullString( request.getParameter( "instId" ) );
String email            = StringUtils.nullString( request.getParameter( "email" ) );
String transTime        = StringUtils.nullString( request.getParameter( "transTime" ) );
String country          = StringUtils.nullString( request.getParameter( "country" ) );
String rawAuthCode      = StringUtils.nullString( request.getParameter( "rawAuthCode" ) );
String amount           = StringUtils.nullString( request.getParameter( "amount" ) );
String installation     = StringUtils.nullString( request.getParameter( "installation" ) );
String tel              = StringUtils.nullString( request.getParameter( "tel" ) );
String address          = StringUtils.nullString( request.getParameter( "address" ) );
String rawAuthMessage   = StringUtils.nullString( request.getParameter( "rawAuthMessage" ) );
String authAmount       = StringUtils.nullString( request.getParameter( "authAmount" ) );
String amountString     = StringUtils.nullString( request.getParameter( "amountString" ) );
String cardType         = StringUtils.nullString( request.getParameter( "cardType" ) );
String AVS              = StringUtils.nullString( request.getParameter( "AVS" ) );
String cost             = StringUtils.nullString( request.getParameter( "cost" ) );
String currency         = StringUtils.nullString( request.getParameter( "currency" ) );
String testMode         = StringUtils.nullString( request.getParameter( "testMode" ) );
String MC_shipping      = StringUtils.nullString( request.getParameter( "MC_shipping" ) );
String authAmountString = StringUtils.nullString( request.getParameter( "authAmountString" ) );
String fax              = StringUtils.nullString( request.getParameter( "fax" ) );
String lang             = StringUtils.nullString( request.getParameter( "lang" ) );
String transStatus      = StringUtils.nullString( request.getParameter( "transStatus" ) );   //Y or C
String authCurrency     = StringUtils.nullString( request.getParameter( "authCurrency" ) );
String postcode         = StringUtils.nullString( request.getParameter( "postcode" ) );
String authCost         = StringUtils.nullString( request.getParameter( "authCost" ) );
String countryMatch     = StringUtils.nullString( request.getParameter( "countryMatch" ) );
String cartId           = StringUtils.nullString( request.getParameter( "cartId" ) );
String transId          = StringUtils.nullString( request.getParameter( "transId" ) );
String authMode         = StringUtils.nullString( request.getParameter( "authMode" ) );
String name             = StringUtils.nullString( request.getParameter( "name" ) );
String callbackPW       = StringUtils.nullString( request.getParameter( "callbackPW" ) );
String adOptionNumber   = StringUtils.nullString( request.getParameter( "MC_adOption" ) );

boolean paymentCleared = transStatus.toUpperCase().equals( "Y" );

int advertId=-1;
int memberId=-1;

if( cartId.toUpperCase().startsWith( "AD_" ) )
{
  advertId = NumberUtils.parseInt( cartId.substring( 3, cartId.length() ), -1 );
}
else if( cartId.toUpperCase().startsWith( "MEM_" ) )
{
  String[] cartIdSplit = StringUtils.split( cartId, "_" );
  memberId = NumberUtils.parseInt( cartIdSplit[ 1 ], -1 );
}

//get logged in member if page being called from worldpay servers or if from resultY.html and membership expired whilst customer in worldpay
if( memberId != -1 && loggedInMember==null)
{
  loggedInMember = MemberClient.loadFullMember( memberId );
}

String fromPage="";
PropertyFile dataDictionary = PropertyFile.getDataDictionary();
String hostUrl = "http://" + dataDictionary.getString( "hostUrl" );

if( !callbackPW.equals( dataDictionary.getString( "worldpay.password" ) ) )
{
  out.print( "Invalid password sent from worldpay, " + ( advertId==-1 ? "your membership has not been marked as paid within our system" : "your advert has NOT been sent for moderation" ) + ", this is a serious error please use the contact us section to get in touch, quoting your cartId of " + cartId + " and we will be in touch regarding refunds or getting your " + ( advertId==-1 ? "membership live" : "advert on the site" ) + ".<br /><br />" );
  return;
}

if( paymentCleared )
{
  //updatepaymentcleared dates and stuff in database.
  if( advertId != -1 )
  {
    AdvertSql.setAdvertAsPaid( advertId, adOptionNumber );

    if( loggedInMember != null )    //this is just so that in the fricking account manager the icon changes to say that you've paced an advert, woopty fucking doo.
    {
      MemberClient.markMemberAsAdvertiser( loggedInMember, true );
    }

    //the advert moderated email must only go once payment has been made
    Advert advert = AdvertSql.loadAdvert( advertId );
    if( advert.moderatedDate != null )
    {
      ArrayList replacerKeys = new ArrayList();
      ArrayList replacerVals = new ArrayList();

      replacerKeys.add( "&lt;USERNAME&gt;" );
      replacerVals.add( advert.name );

      replacerKeys.add( "&lt;CLIENTADGOLIVEDATE&gt;" );
      SimpleDateFormat sdf = new SimpleDateFormat( "EEEE, dd MMMM, yyyy" );
      replacerVals.add( sdf.format( advert.goLiveDate ) );

      EmailSender.sendMail( "advertmod", "Your Nextface advert has been approved and is now live", null, replacerKeys, replacerVals, null, advert.email );
    }
  }
  else
  {
    MemberClient.setMemberAsPaid( memberId, loggedInMember );
  }
}

String INSERT_WORLDPAY_RESPONSE = "INSERT INTO WORLDPAYRESPONSES ( advertId, memberId, transId, cartId, instId, responseDate, transTime, name, tel, email, amount, currency, transStatus, rawAuthMessage, rawAuthCode, avs, authCurrency, authAmmount, cardType ) " +
                                  " VALUES ( ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )";

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps = conn.prepareStatement( INSERT_WORLDPAY_RESPONSE );

if( advertId==-1 )
{
  ps.setNull( 1, Types.INTEGER );
}
else
{
  ps.setInt( 1, advertId );
}

if( memberId==-1 )
{
  ps.setNull( 2, Types.INTEGER );
}
else
{
  ps.setInt( 2, memberId );
}
ps.setString(  3, transId );
ps.setString(  4, cartId );
ps.setString(  5, instId );
ps.setString(  6, transTime );
ps.setString(  7, name );
ps.setString(  8, tel );
ps.setString(  9, email );
ps.setString( 10, amount );
ps.setString( 11, currency );
ps.setString( 12, transStatus );
ps.setString( 13, rawAuthMessage );
ps.setString( 14, rawAuthCode );
ps.setString( 15, AVS );
ps.setString( 16, authCurrency );
ps.setString( 17, authAmount );
ps.setString( 18, cardType );

ps.executeUpdate();

ps.close();
conn.close();

%>
<html>
<head>
  <title>Nextface Payment Results</title>
  <link rel="stylesheet" type="text/css" href="<%= hostUrl %>/style/general.css"/>
</head>
<body>
<table width="430" border="0" cellspacing="0" cellpadding="0">
<tr>
  <td height="1" width="4%"><img width="1" height="1" src="<%= hostUrl %>/art/blank.gif" /></td>
  <td width="4%"><img width="1" height="1" src="<%= hostUrl %>/art/blank.gif" /></td>
  <td width="406">
    <table cellpadding="0" cellspacing="0" border="0" width="406">
    <tr>
      <td>
<%

String includePagePrefix = "";

if( paymentCleared && advertId == -1 )
{
  includePagePrefix = "memPayYes";
}
else if( paymentCleared && advertId > -1 )
{
  includePagePrefix = "adPayYes";
}
else if( !paymentCleared && advertId == -1 )
{
  includePagePrefix = "memPayNo";
}
else
{
  includePagePrefix = "adPayNo";
}

String tempPageName = includePagePrefix + "1";

%>

<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="<%= tempPageName %>"/>
</jsp:include>

        <br />
        <h4>Transaction Summary</h4>
        <table cellpadding="0" cellspacing="0">
<%

if( paymentCleared )
{
  if( advertId == -1 )
  {

%>
        <tr>
          <td class="transSum1">Annual membership fee paid:</td>
          <td class="transSum2"><%= authAmountString %></td>
        </tr>
<%

  }
  else
  {

%>
        <tr>
          <td class="transSum1">Advertising fee paid:</td>
          <td class="transSum2"><%= authAmountString %></td>
        </tr>
<%

  }

%>
        <tr>
          <td class="transSum1">Merchant's Reference:</td>
          <td class="transSum2"><%= cartId %></td>
        </tr>
        <tr>
          <td class="transSum1">Transaction Id:</td>
          <td class="transSum2"><%= transId %></td>
        </tr>
<%

}
else
{
  if( advertId == -1 )
  {

%>
        <tr>
          <td class="transSum1">Annual membership fee paid:</td>
          <td class="transSum2">Transaction cancelled</td>
        </tr>
<%

  }
  else
  {

%>
        <tr>
          <td class="transSum1">Advertising fee paid:</td>
          <td class="transSum2">Transaction cancelled</td>
        </tr>
<%
  }
}

boolean redirectToAccMan = ( advertId == -1 );
tempPageName = includePagePrefix + "2";

%>
        </table>
        <br />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="<%= tempPageName %>"/>
</jsp:include>
        <br />
<jsp:include page="/inc/tellAFriend.jsp" flush="true" >
  <jsp:param name="redirecttoaccman" value="<%= redirectToAccMan %>"/>
</jsp:include>
        <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
<%
  if( advertId == -1 && ( paymentCleared || ( loggedInMember != null && ( loggedInMember.memberProfile != null || loggedInMember.moderationMemberProfile!=null ) ) ) )
  {
%>
          <td nowrap="nowrap"><h6 class="burgundyh6" style="text-align: left;"><a target="_parent"  href="<%= hostUrl %>/pages/accountManager.jsp">Exit to account manager</a></h6></td>
          <td nowrap="nowrap" class="linkAnnotation" width="100%">...This will keep your data and exit</td>
<%
  }
  else if( advertId == -1 )
  {
%>
          <td nowrap="nowrap"><h6 class="burgundyh6" style="text-align: left;"><a target="_parent"  href="<%= hostUrl %>/pages/registerProfileDetails.jsp?mode=edit">Continue registration</a></h6></td>
          <td nowrap="nowrap" class="linkAnnotation" width="100%">...Enter your profile details</td>
<%
  }
  else
  {
%>
          <td nowrap="nowrap"><h6 class="burgundyh6" style="text-align: left;"><a target="_parent"  href="<%= hostUrl %>/index.jsp">Exit to homepage</a></h6></td>
          <td nowrap="nowrap" class="linkAnnotation" width="100%">...This will keep your data and exit</td>
<%
  }
%>
        </tr>
        </table>
      </td>
    </tr>
    </table>
  <td width="1%"><img width="1" height="1" src="/art/blank.gif" /></td>
</tr>
<tr>
  <td height="1" width="4%"><img width="1" height="1" src="/art/blank.gif" /></td>
  <td height="1" width="4%"><img width="1" height="1" src="/art/blank.gif" /></td>
  <td width="406" height="1"><img width="406" height="1" src="/art/blank.gif" /></td>
  <td height="1" width="1%"><img width="1" height="1" src="/art/blank.gif" /></td>
</tr>
</table>
</body>
</html>