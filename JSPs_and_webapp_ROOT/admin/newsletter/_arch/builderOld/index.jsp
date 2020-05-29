<%@ page language="java"
         import="com.extware.utils.StringUtils,
                 com.extware.utils.NumberUtils,
                 com.extware.utils.DatabaseUtils,
                 com.extware.utils.PropertyFile,
                 java.sql.Connection,
                 java.util.ArrayList,
                 com.extware.user.UserDetails,
                 com.extware.newsletter.NewsletterType,
                 com.extware.newsletter.Newsletter,
                 com.extware.newsletter.NewsletterStoryTemplate
" %><%

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
  PropertyFile dataDictionary = PropertyFile.getDataDictionary();

  String mode = StringUtils.nullString( request.getParameter("mode") );

  String redirect = "list";

  try
  {
    Connection conn = DatabaseUtils.getDatabaseConnection();

    if ( redirect.equals("list") )
    {
      ArrayList newsletterTypes = NewsletterType.getNewsletterTypeList( conn );
      request.setAttribute("newsletterTypes",newsletterTypes);
    }

    conn.close();
  }
  catch( Exception ex )
  {
    request.setAttribute("exception",ex);
    request.setAttribute("className","/admin/newsletters/index.jsp");
    request.setAttribute("cannotFind",ex.toString());
    %><jsp:forward page="/errors/error.jsp" /><%
    return;
  }

  redirect += ".jsp";

%><jsp:forward page="<%= redirect %>" />