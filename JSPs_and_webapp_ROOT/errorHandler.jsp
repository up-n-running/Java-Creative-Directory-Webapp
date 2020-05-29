<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.member.MemberClient,
          com.extware.utils.SiteUtils,
          com.extware.utils.StringUtils,
          java.net.URLEncoder"
%>
<%
String requestURL = (String)request.getAttribute("REDIRECT_URL");
String[] splitURL = StringUtils.split( requestURL, "/" );
String profileURL = splitURL[ splitURL.length-1 ];

Member redirectMember = MemberClient.loadFullMember( profileURL );

if( redirectMember != null )
{

  String memberid = String.valueOf( redirectMember.memberId );

%>
<jsp:include page="/pages/profileDetails.jsp" flush="true" >
  <jsp:param name="memberId" value="<%= memberid %>"/>
</jsp:include>
<%

return;

}

%>
<html>
<head>
  <title>Apache Tomcat/5.0.19 - Error report</title>
  <style><!--H1 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:22px;} H2 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:16px;} H3 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:14px;} BODY {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;} B {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;} P {font-family:Tahoma,Arial,sans-serif;background:white;color:black;font-size:12px;}A {color : black;}A.name {color : black;}HR {color : #525D76;}--></style>
</head>
  <body>
    <h1>HTTP Status 404 - <%= requestURL %></h1>
    <HR size="1" noshade>
    <p><b>type</b> Status report</p>
    <p><b>message</b> <u><%= requestURL %></u></p>
    <p><b>description #1</b> <u>The requested resource (<%= requestURL %>) is not available.</u></p>
<%

if( redirectMember == null)
{

%>    <p><b>description #2</b> <u>Nor was the member with profileURL (<%= profileURL %>) found.</u></p>
<%

}
else
{

%>    <p><b>description #2</b> <u>However member no (<%= redirectMember.memberId %>) found, will redirect to their page.</u></p>
<%

}

%>
    <HR size="1" noshade>
    <h3>Apache Tomcat/5.0.19</h3>
  </body>
</html>