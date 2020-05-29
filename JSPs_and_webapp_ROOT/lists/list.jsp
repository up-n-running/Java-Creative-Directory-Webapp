<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.extsite.lists.ListType,
          com.extware.utils.FileUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.SiteUtils,
          com.extware.utils.StringUtils,
          java.util.ArrayList"
%><%

String listHandle = StringUtils.nullString( request.getParameter( "l" ) );

ListType listType = ListType.getListType( listHandle );

if( listType != null )
{
  request.setAttribute( "listType", listType );

  String typePage = listType.listHandle + ".jsp";
  String typeFile = SiteUtils.getWebappRoot() + DataDictionary.DIRSEP + "lists" + DataDictionary.DIRSEP + typePage;

%><!-- <%= typeFile %> --><%

  if( !FileUtils.fileExists( typeFile ) )
  {
    typePage = "default.jsp";
  }

%><jsp:include page="<%= typePage %>" flush="true" /><%

}
else
{
  out.print( listHandle + " List Not Found" );
}

%>