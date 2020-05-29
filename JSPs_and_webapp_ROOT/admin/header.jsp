<%@ page language="java"
  import="com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile"
%><%

PropertyFile adminProps = new PropertyFile( "com.extware.properties.Admin" );

PropertyFile defaultMenuProps = new PropertyFile( adminProps.getString( "menu." + adminProps.getInt( "menu.default" ) ) );

%><html>
<head>
  <title><%= adminProps.getString( "admin.appname" ) %>: Header</title>
  <link rel="stylesheet" type="text/css" href="/style/extWareHead.css" />
</head>
<body class="<%= defaultMenuProps.getString( "menu.name" ) %>Head">
<div class="headTop"><a href="http://www.eleventeenth.com/" target="eleventeenth"><img class="eleventeenth" src="/art/11tth.gif" border="0" /></a>administration suite</div>
<div class="headStrap" id="headStrap"><a class="headSupportEmail" href="mailto:<%= adminProps.getString( "admin.email.support" ) %>">eMail Support</a><span id="headStrapText">website content control</span></div>
</body>
</html>