<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils,
          com.extware.user.UserDetails,
          com.extware.advert.sql.AdvertSql,
          com.extware.advert.Advert,
          com.extware.advert.AdvertModerationComparator,
          com.extware.emailSender.EmailSender,
          java.util.ArrayList,
          java.util.Date,
          java.util.Collections,
          java.util.GregorianCalendar,
          java.util.Calendar,
          java.text.SimpleDateFormat
"
%>
<%!
   JspWriter out = null;
   int rowNum = 1;

   PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
   boolean lastRowWasSeperator = false;

   void setOut(JspWriter out)
   {
     this.out = out;
   }

   void resetRowNum()
   {
     this.rowNum = 1;
     lastRowWasSeperator=false;
   }

   PropertyFile getddProps()
   {
     return ddProps;
   }

   void displayModRow ( String fieldNam, int pValue, int value, String ddGroup ) throws java.io.IOException
   {
      displayModRow( false, fieldNam, ddProps.getString( ddGroup + "." + pValue + "." + value ) );
   }

   void displayModRow ( String fieldNam, int value, String ddGroup ) throws java.io.IOException
   {
      displayModRow( false, fieldNam, ddProps.getString( ddGroup + "." + value ) );
   }

   void displayModRow ( String fieldNam, String[] modValues ) throws java.io.IOException
   {
     String modValue = "<ul>";

     for( int i = 0 ; modValues!= null && i < modValues.length ; i++ )
     {
       modValue += "<li>" + modValues[ i ] + "</li>";
     }

     modValue += "</ul>";

     displayModRow ( true, fieldNam, modValue );
   }

   void displayModRow ( String fieldNam, String modValue ) throws java.io.IOException
   {
     displayModRow ( true, fieldNam, modValue );
   }


   void displayModRow ( boolean bold, String fieldNam, String value ) throws java.io.IOException
   {
      value = StringUtils.nullReplace( value, "NONE" );

      out.println( "<tr>" );
      out.println( "  <td class=\"listLine" + ( rowNum % 2 ) + "\">" + fieldNam + ":</td>" );
      out.println( "  <td width=\"540\" class=\"listLine" + ( rowNum % 2 ) + "\">" + (bold?"<b>":"") + value + (bold?"<b>":"") + "</td>" );
      out.println( "</tr>" );

      rowNum++;
      lastRowWasSeperator = false;
   }

   void insertSeperator() throws java.io.IOException
   {
     insertSeperator( 1 );
   }

   void insertSeperator( int height ) throws java.io.IOException
   {
     if( lastRowWasSeperator )
     {
       height--;
     }

     if( height > 0 )
     {
       out.println( "<tr><td colspan=\"3\" style=\"height: " + height + "px; background: #000000;\"></td></tr>" );
       lastRowWasSeperator = true;
     }
   }

%>
<%
   // sets the out jspWriter in the method tag to the proper out jspWriter
   setOut(out);
%>
<%
UserDetails user = UserDetails.getUser( session );

if( user == null )
{
  response.sendRedirect( "/admin/login.jsp" );
  return;
}

if( !user.isAdmin() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String errors     = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message    = StringUtils.nullString( request.getParameter( "message" ) ).trim();

// if coming back to this form, we must make the change required
String mode = StringUtils.nullString( request.getParameter( "mode" ) );
int advertId = NumberUtils.parseInt( request.getParameter( "id" ), -1 );

if( mode.equals( "hold" ) )
{
  AdvertSql.putAdvertOnHold( advertId );  //i know this method should be in AdvertSql, but i'm cheating ok?
}
else if( mode.equals( "pass" ) )
{
  AdvertSql.moderatePassAdvert( advertId );
  Advert advert = AdvertSql.loadAdvert( advertId );

  if( advert.paymentDate != null )
  {
    ArrayList replacerKeys = new ArrayList();
    ArrayList replacerVals = new ArrayList();
    replacerKeys.add( "&lt;USERNAME&gt;" );
    replacerVals.add( advert.name );
    replacerKeys.add( "&lt;CLIENTADGOLIVEDATE&gt;" );
    SimpleDateFormat sdf = new SimpleDateFormat( "EEEE, dd MMMM, yyyy" );
    replacerVals.add( sdf.format( advert.goLiveDate ) );

    EmailSender.sendMail( "advertmod", "Your Nextface advert has been approved and is now ready to go live", null, replacerKeys, replacerVals, null, advert.email );
  }
}
else if( mode.equals( "fail" ) )   //id is asset id
{
  //this deletes asset file and asset row and memberFile row
  int assetId = NumberUtils.parseInt( request.getParameter( "assetid" ), -1 );

  if( assetId != -1 )
  {
    Advert tempAd = new Advert();
    tempAd.assetId = assetId;
    tempAd.deleteMe();
  }
  else
  {
    //there's no asset so we simply delete the database row.
    AdvertSql.moderateFailAdvert( advertId );
  }
}

ArrayList adverts = AdvertSql.loadAdvertsForModeration();
//the query does its best to sort these values, but just to tart it up a bit - we pass it through javas posh sorting algorithm with a stupidly complex comparator
Collections.sort( adverts, new AdvertModerationComparator() );  //the constructor sets a now timestamp internally in that class for working out whether stuff is live or not. good eh?

Date now = new Date();  //to find out if stuff is live yet.

%><html>
<head>
<title>Moderation</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="5" class="title">Advert Moderation</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="5" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="5" class="message"><%= message %></td>
</tr>
<%

}

Advert advert = null;
String filePreview;
String description;
String holdStyleInsert;
String loggedinStyleInsert;
Calendar wentOnHoldCal;
Calendar nowCal;

for( int i = 0 ; i < adverts.size() ; i++ )
{
  advert = (Advert)adverts.get( i );

  //display logic
  description = "NEW_CHANGE";
  holdStyleInsert = "";
  loggedinStyleInsert = "";

  if( advert.onModerationHold )
  {
    holdStyleInsert = " background-color: yellow";
    description = "ON_HOLD";

    wentOnHoldCal = new GregorianCalendar();
    wentOnHoldCal.setTime( advert.wentOnHoldDate );
    nowCal = new GregorianCalendar();
    nowCal.setTime( now );

    if( wentOnHoldCal.get( Calendar.YEAR ) == nowCal.get( Calendar.YEAR ) && wentOnHoldCal.get( Calendar.DAY_OF_YEAR ) == nowCal.get( Calendar.DAY_OF_YEAR ) )
    {
      holdStyleInsert = " background-color: #11ffff";
      description     = "NEW_HOLD";
    }
  }

%><tr>
  <td colspan="2">&nbsp;<br /></td>
</tr>
<tr>
  <td colspan="2" class="listHead">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td class="listHead" style="text-align: right; padding: 1px;<%= loggedinStyleInsert %>">Organisation:</td>
        <td width="100%" class="listHeadLink" style="<%= loggedinStyleInsert %>"><%= advert.name %></a></td>
        <td colspan="2" class="listHead" style="<%= holdStyleInsert %>"><%= description %></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Email:</td>
        <td width="100%" class="listHeadLink"><a href="mailto:<%= advert.email %>"><%= advert.email %></a></td>
        <td class="listHead" class="listHead" <%= advert.paymentDate!=null ? ">PAID" : ">UNPAID" %></td>
        <td><a href="adverts.jsp?mode=pass&id=<%= advert.advertId %>"><img src="/art/admin/moderation/pass.gif" border="0"/></a></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Links To:</td>
        <td width="100%" class="listHeadLink"><a href="<%= advert.webAddress %>" target="_blank"><%= advert.webAddress %></a></td>
        <td class="listHead" class="listHead" <%= advert.goLiveDate == null ? ">NOT_LIVE" : ( advert.expiryDate.before( now ) ? ">LIVE!" : ">EXPIRED" ) %></td>
        <td><a href="adverts.jsp?mode=hold&id=<%= advert.advertId %>"><img src="/art/admin/moderation/onhold.gif" border="0" /></a></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable" nowrap="nowrap" style="white-space: nowrap">Date Posted:</td>
        <td class="listHead" colspan="2" <%= "nowrap=\"nowrap\" " + "style=\"white-space: nowrap\" >" + advert.creationDate %></td>
        <td><a href="adverts.jsp?mode=fail&id=<%= advert.advertId %>&assetid=<%= advert.assetId %>"><img src="/art/admin/moderation/fail.gif" border="0"/></a></td>
      </tr>
    </table>
  </td>
</tr>
<tr>
  <td class="listHead">Field</td>
  <td class="listHead">To Be Moderated</td>
</tr>
<%

    resetRowNum();

    insertSeperator( 2 );
    displayModRow( "Organisation Name", advert.name           );
    displayModRow( "Your Status"      , advert.statusRef      ,   "advertstatusref"   );
    displayModRow( "Other Status"     , advert.statusOther    );
    insertSeperator();
    displayModRow( "Address Line 1"   , advert.address1       );
    displayModRow( "Address Line 2"   , advert.address2       );
    displayModRow( "City"             , advert.city           );
    displayModRow( "Postcode"         , advert.postcode       );
    displayModRow( "County"           , advert.regionRef      , advert.countyRef , "countyref"    );
    displayModRow( "UK Region"        , advert.regionRef      , "ukregionref"    );
    displayModRow( "Country"          , advert.countryRef     , "countryref"     );
    insertSeperator();
    displayModRow( "Telephone Number" , advert.telephone      );
    displayModRow( "Fax Number"       , advert.fax            );
    displayModRow( "Email Address"    , advert.email          );
    insertSeperator();
    displayModRow( "Where Did You Hear", advert.whereDidYouHearRef     , "wheredidyouhearref" );
    displayModRow( "Other Heard About" , advert.whereDidYouHearOther    );
    displayModRow( "Other Magazine"    , advert.whereDidYouHearMagazine );
    insertSeperator();
    displayModRow( "Web Address Link"  , "<span style=\"color: #2222ee;\"><a href=\"" + advert.webAddress + "\" target=\"_blank\">" + advert.webAddress + "</a></span>"   );
    insertSeperator();

    filePreview = "No image uploaded";

    if( advert.assetId != -1 )
    {
      filePreview = advert.getPostProcessAssetHtml( "Advert" );
    }

    displayModRow( "File Preview", filePreview );
    insertSeperator(2);

}

if( adverts.size() == 0 )
{

%><tr>
  <td colspan="5" class="listSubHead">No Adverts Requiring Moderation!!!!!!!</td>
</tr>
<%

}

%>
</table>
</body>
</html>