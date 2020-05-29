<%@ page language="java"
         import="com.extware.member.Member,
                 com.extware.member.MemberClient,
                 com.extware.member.MemberContact,
                 com.extware.utils.StringUtils,
                 java.util.ArrayList"
%>
<html>
<head>
  <title>Nextface - The creative directory</title>
  <link rel="stylesheet" type="text/css" href="/style/general.css"/>
</head>
<body>
<h1>Nextface creative companies list for people without javascript</h1>
<%

ArrayList memberResults = MemberClient.memberSearch( null, -1, -1, -1, -1, -1, -1, "", StringUtils.nullReplace( request.getParameter( "l" ), "a" ).toUpperCase(), true );
Member member;
MemberContact memberContact;

for( int i = 0 ; i < memberResults.size(); i++ )
{
  member = (Member)memberResults.get( i );
  memberContact = member.memberContact;

%><a href="/<%= member.profileURL %>"><%= memberContact.name %>, <%= memberContact.getStatusDesc() %>, <%= memberContact.getPrimaryDisciplineDesc() %><%= memberContact.getSecondaryDisciplineDesc() != null ? ", " + memberContact.getSecondaryDisciplineDesc() : "" %><%= memberContact.getTertiaryDisciplineDesc() != null ? ", " + memberContact.getTertiaryDisciplineDesc() : "" %><br />
<%= memberContact.getCountyDesc() != null ? ( memberContact.getCountyDesc() + ", " + memberContact.getRegionDesc() ) : memberContact.getCountryDesc() %></a><br /><br />
<%

}

%>
</body>
</html>