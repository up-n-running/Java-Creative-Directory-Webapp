<%@ page language="java" import="
  com.extware.extsite.newsletter.NewsletterStatuses,
  com.extware.utils.BooleanUtils,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.PreparedStatementUtils,
  com.extware.utils.StringUtils,
  com.extware.user.UserDetails,
  java.net.URLEncoder,
  java.sql.Connection,
  java.sql.PreparedStatement,
  java.sql.ResultSet,
  java.text.SimpleDateFormat,
  java.util.Date
" %><%

UserDetails user = UserDetails.getUser( session );

if( user == null )
{
  response.sendRedirect( "/admin/login.jsp" );
  return;
}

if( !user.isUltra() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String SELECT_TYPES_SQL = "SELECT n.newsletterId, n.newsletterTypeId, n.newsletterName, n.status, n.lastUpdate, n.startSendDate, n.endSendDate, COUNT(r.userId) totalRecipients, COUNT(ru.userId) unsentRecipients, COUNT(rs.userId) sentRecipients FROM newsletters n LEFT JOIN newsletterRecipients r ON r.newsletterId=n.newsletterId LEFT JOIN newsletterRecipients ru ON ru.newsletterId=n.newsletterId AND ru.status=? LEFT JOIN newsletterRecipients rs ON rs.newsletterId=n.newsletterId AND rs.status=? GROUP BY n.newsletterId, n.newsletterTypeId, n.newsletterName, n.status, n.lastUpdate, n.startSendDate, n.endSendDate ORDER BY n.createDate DESC";

char status;

int count;
int newsletterId;
int newsletterTypeId;
int totalRecipients;
int unsentRecipients;
int sentRecipients;

String newsletterName;
String errors         = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message        = StringUtils.nullString( request.getParameter( "message" ) ).trim();

Date lastUpdate;
Date startSendDate;
Date endSendDate;

SimpleDateFormat dateFormat = new SimpleDateFormat( "dd-MMM-yyyy HH:mm" );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>Newsletter Type Admin</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="6" class="title">Review Newsletters</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="6" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="6" class="message"><%= message %></td>
</tr>
<%

}

count = 0;

ps = conn.prepareStatement( SELECT_TYPES_SQL );
PreparedStatementUtils.setString( ps, 1, NewsletterStatuses.RECIPIENT_UNSENT );
PreparedStatementUtils.setString( ps, 2, NewsletterStatuses.RECIPIENT_SENT );
rs = ps.executeQuery();

while( rs.next() )
{
  if( count == 0 )
  {

%><tr>
  <td class="listHead">Newsletter Name</td>
  <td class="listHead">Updated</td>
  <td class="listHead">Status</td>
  <td class="listHead" colspan="2"></td>
</tr>
<%

  }

  newsletterId     = rs.getInt(       "newsletterId" );
  newsletterTypeId = rs.getInt(       "newsletterTypeId" );
  newsletterName   = rs.getString(    "newsletterName" );
  status           = rs.getString(    "status" ).charAt( 0 );
  lastUpdate       = rs.getTimestamp( "lastUpdate" );
  startSendDate    = rs.getTimestamp( "startSendDate" );
  endSendDate      = rs.getTimestamp( "endSendDate" );
  totalRecipients  = rs.getInt(       "totalRecipients" );
  unsentRecipients = rs.getInt(       "unsentRecipients" );
  sentRecipients   = rs.getInt(       "sentRecipients" );

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%= newsletterName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= dateFormat.format( lastUpdate ) %></td>
  <td class="listLine<%= ( count % 2 ) %>"><%= NewsletterStatuses.getStatusText( status ) + ( ( status == NewsletterStatuses.NEWSLETTER_SENDING ) ? " (" + sentRecipients + "/" + totalRecipients + ")" : "" ) %></td>
<%

  if( status != NewsletterStatuses.NEWSLETTER_SENDING && status != NewsletterStatuses.NEWSLETTER_SENT )
  {

%>  <td class="listLine<%= ( count % 2 ) %>"><a href="editNewsletter.jsp?newsletterTypeId=<%= newsletterTypeId %>&newsletterId=<%= newsletterId %>">Edit</a></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="build.jsp?newsletterTypeId=<%= newsletterTypeId %>&newsletterId=<%= newsletterId %>">Stories</a></td>
<%

  }

  if( status == NewsletterStatuses.NEWSLETTER_READY )
  {

%>  <td class="listLine<%= ( count % 2 ) %>"><a href="sendNewsletter.jsp?newsletterTypeId=<%= newsletterTypeId %>&newsletterId=<%= newsletterId %>">Send</a></td>
<%

  }

%>
</tr>
<%

  count++;
}

rs.close();
ps.close();

if( count == 0 )
{

%><tr>
  <td colspan="6" class="listSubHead">No Newsletter Types Found</td>
</tr>
<%

}

%>
<tr>
  <td colspan="6" class="formButtons"><a href="index.jsp">Create a New Newsletter</a></td>
</tr>
</table>
</body>
</html><%

conn.close();

%>