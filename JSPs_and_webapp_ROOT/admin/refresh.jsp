<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile"
%><%

PropertyFile adminProps = new PropertyFile( "com.extware.properties.Admin" );
adminProps.refresh();

int menuCount = 1;

while( adminProps.getString( "menu." + menuCount ) != null )
{
  new PropertyFile( adminProps.getString( "menu." + menuCount ) ).refresh();
  menuCount++;
}

int otherCount = 1;

while( adminProps.getString( "other." + otherCount ) != null )
{
  new PropertyFile( adminProps.getString( "other." + otherCount ) ).refresh();
  otherCount++;
}

%><html>
<head>
  <link rel="stylesheet" type="text/css" href="/admin/html/style/admin.css">
<script type="text/javascript">
function refeshMenu()
{
  if( typeof( parent.menu ) != "undefined" )
  {
    parent.menu.location.reload();
  }

  if( typeof( parent.head ) != "undefined" )
  {
    parent.head.location.reload();
  }

  location.href = "<%= adminProps.getString( "menu.home.link" ) %>";
}

window.onload = refeshMenu;
</script>
</head>
<body>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title">Refreshing Menu</td>
</tr>
</table>
</body>
</html>