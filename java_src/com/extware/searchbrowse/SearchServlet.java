package com.extware.searchbrowse;

import com.extware.framework.SuperServlet;

import com.extware.member.MemberClient;

import com.extware.utils.NumberUtils;
import com.extware.utils.PropertyFile;
import com.extware.utils.StringUtils;

import java.io.IOException;

import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet called on submission of javascript search or browse form.
 *
 * @author   John Milner
 */
public class SearchServlet extends SuperServlet
{

/**
 * doGet
 *
 * @param request               request
 * @param response              response
 * @exception IOException       IOException
 * @exception ServletException  ServletException
 */
  public void doGet( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException
  {
    this.doPost( request, response );
  }

/**
 * Servlet called on submission of javascript search or browse form.
 *
 * @param request               request
 * @param response              response
 * @exception IOException       IOException
 * @exception ServletException  ServletException
 */
  public void doPost( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException
  {
    PropertyFile dataDictionary = PropertyFile.getDataDictionary();

    String redirectTo = "/index.jsp";

    String formName        = StringUtils.nullString( request.getParameter( "formname" ) );
    String searchType      = StringUtils.nullString( request.getParameter( "searchtype" ) );
    int    compSizeVal     = NumberUtils.parseInt( request.getParameter( "compsizeval" ), -1 );
    int    jobTypeVal      = NumberUtils.parseInt( request.getParameter( "jobtypeval" ), -1 );
    int    fileTypeVal     = NumberUtils.parseInt( request.getParameter( "filetypeval" ), -1 );
    int    categoryVal     = NumberUtils.parseInt( request.getParameter( "categoryval" ), -1 );
    int    disciplineVal   = NumberUtils.parseInt( request.getParameter( "disciplineval" ), -1 );
    int    countryVal      = NumberUtils.parseInt( request.getParameter( "countryval" ), -1 );
    int    regionVal       = NumberUtils.parseInt( request.getParameter( "regionval" ), -1 );
    int    countyVal       = NumberUtils.parseInt( request.getParameter( "countyval" ), -1 );
    String keyword         = StringUtils.nullString( request.getParameter( "keyword" ) );
    String nameFirstLetter = StringUtils.nullString( request.getParameter( "namefirstletter" ) );
    if( keyword.equals( "  KEYWORD" ) )
    {
      keyword = "";
    }
    keyword = keyword.toUpperCase().trim();

    if( formName.equals( "search" ) )
    {
      //member search
      if( searchType.equals( "creativepeople" ) || searchType.equals( "creativecompanies" ) || searchType.equals( "recruit" ) || searchType.equals( "publications" ) || searchType.equals( "organisations" ) || searchType.equals( "courses" ) )
      {
        //find list of statusRefs to filter the search
        String statusRefIds = dataDictionary.getString( "search." + searchType + ".ids" );

        if( searchType.equals( "creativecompanies" ) )
        {
          if( compSizeVal == -1 )
          {
            //all company types
            statusRefIds += ", " + dataDictionary.getString( "search.creativepeople.ids" );
          }
          else if( compSizeVal == 0 )
          {
            //sole trader company types
            statusRefIds = dataDictionary.getString( "search.singlepeoplecompanies.ids" );
            compSizeVal = -1;
          }
        }

        ArrayList memberResults = MemberClient.memberSearch( statusRefIds,
            compSizeVal, categoryVal, disciplineVal, countryVal, regionVal, countyVal,
            keyword, nameFirstLetter
        );

        request.getSession().removeAttribute( "searchResults" );
        request.getSession().setAttribute( "searchResults", memberResults );

        redirectJsp( request, response, "/pages/srchResultsMembers.jsp" );

        return;
      }
      else if( searchType.equals( "jobs" ) )
      {
        ArrayList memberResults = MemberClient.memberJobSearch( jobTypeVal, categoryVal, disciplineVal, countryVal, regionVal, countyVal, keyword );

        request.getSession().removeAttribute( "searchResults" );
        request.getSession().setAttribute( "searchResults", memberResults );

        redirectJsp( request, response, "/pages/srchResultsMemberJobs.jsp" );

        return;
      }
      else if( searchType.equals( "imgs" ) )
      {
        String isImage = null;

        if( fileTypeVal != -1 )
        {
          isImage = fileTypeVal == 1 ? "t" : "f";
        }

        ArrayList memberResults = MemberClient.memberFileSearch( isImage, categoryVal, disciplineVal, keyword );

        request.getSession().removeAttribute( "searchResults" );
        request.getSession().setAttribute( "searchResults", memberResults );

        redirectJsp( request, response, "/pages/srchResultsMemberFiles.jsp" );

        return;
      }

      redirectJsp( request, response, redirectTo );

      return;
    }
    else if( formName.equals( "browse" ) )
    {
      String statusRefIds = null;

      if( nameFirstLetter.length() == 0 )
      {
        nameFirstLetter = "A";
      }

      ArrayList memberResults = MemberClient.memberSearch( statusRefIds,
          compSizeVal, categoryVal, disciplineVal, countryVal, regionVal, countyVal,  //all bar category and discipline will be -1, and keywords will be empty string.
          keyword, nameFirstLetter
      );

      request.getSession().removeAttribute( "searchResults" );
      request.getSession().setAttribute( "searchResults", memberResults );

      redirectJsp( request, response, "/pages/srchResultsMembers.jsp" );

      return;
    }

    redirectJsp( request, response, redirectTo );

    return;
  }

}
