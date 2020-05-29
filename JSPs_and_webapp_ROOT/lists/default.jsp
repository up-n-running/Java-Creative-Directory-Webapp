<%@ page language="java"
  import="com.extware.extsite.lists.ListType,
          com.extware.extsite.lists.ListItem,
          com.extware.user.UserDetails,
          com.extware.utils.BooleanUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          java.util.ArrayList,
          java.text.SimpleDateFormat"
%><%

UserDetails user = UserDetails.getUser( session );

String listHandle = StringUtils.nullString( request.getParameter( "l" ) );

ListType listType = ListType.getListType( listHandle );

if( !listType.isVisibleTo( user ) )
{
  return;
}

ArrayList listItems = listType.getListItems();

boolean showView = BooleanUtils.parseBoolean( request.getParameter( "showView" ) );

int maxItems = NumberUtils.parseInt( request.getParameter( "maxItems" ), listItems.size() );

String siteSpec = StringUtils.padRight( StringUtils.nullString( request.getParameter( "s" ) ), 4, '1' );

SimpleDateFormat dateFormat = new SimpleDateFormat( "dd/MMM/yyyy" );

%><table class="<%= listHandle %>" border="0" cellpadding="0" cellspacing="0">
<tr>
  <td class="head"><%= listType.listName %></td>
</tr>
<%

for( int i = 0 ; i < listItems.size() && i < maxItems ; i++ )
{
  ListItem item = (ListItem)listItems.get( i );

%><tr>
  <td class="list"><table border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td>
        <p class="date"><%= dateFormat.format( item.fromDate ) + ( ( item.toDate != null && !item.toDate.equals( item.fromDate ) ) ? " - " + dateFormat.format( item.toDate ) : "" ) %></p>
        <p class="title"><%= item.title %></p>
        <p class="standfirst"><%= item.standfirst %></p>
      </td>
    </tr>
<%
//display the content of the extra fields if there is any
if ( item.hasExtraFields )
{
%>
    <tr>
      <td>
	<%
	for (i=0;i<item.extraFieldLabels.size();i++) 
	{
	%>
	<p class="extrafield"><%= item.extraFieldLabels.get(i)%> &nbsp; <%= item.extraFieldValues.get(i)%></p>
	<%
	} //end for 
	%>
      </td>
    </tr>
<%
}

%>



    <tr>
      <td class="more"><a href="/?i=<%= item.listItemId %>&s=<%= siteSpec %>">...read more</a></td>
    </tr>
    </table></td>
</tr>
<%

}

if( listItems.size() == 0 )
{

%><tr>
  <td>No <%= listType.listName %> today</td>
</tr>
<%

}

if( showView )
{

%><tr>
  <td class="view"><a href="/?l=<%= listType.listHandle %>&s=<%= siteSpec %>">View the <%= listType.listName %> page</a></td>
</tr>
<%

}

%></table>