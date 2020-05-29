<%@ page language="java"
  import="com.extware.advert.Advert,
          com.extware.utils.BooleanUtils,
          com.extware.utils.PropertyFile,
          java.text.SimpleDateFormat,
          java.util.ArrayList,
          java.util.Date"
%><%

//get Adverts
PropertyFile dataDictionary = PropertyFile.getDataDictionary();
ArrayList premiereLiveAds = Advert.getPremiereLiveAds();
ArrayList standardLiveAds = Advert.getStandardLiveAds();
int maxPremiereAds = dataDictionary.getInt( "advertising.maxPremiereRight" );
int maxStandardAds = dataDictionary.getInt( "advertising.maxStandardRight" );

//date for news section
SimpleDateFormat sdf = new SimpleDateFormat( "EEE dd:MM:yy" );
Date now = new Date();
String nowString = sdf.format( now );

%>
           </td>
          </tr>
          </table>
<%

if( BooleanUtils.isTrue( request.getParameter( "wideForWorldpay" ) ) )
{

%>        </td>
      </tr>
      <tr>
        <td width="100%" height="1" ><img width="430" height="1" src="/art/blank.gif" /></td>
      </tr>
<%

}
else
{

%>        </td>
        <td><img width="3" height="1" src="/art/blank.gif" /></td>
      </tr>
      <tr>
        <td height="1"><img width="3" height="1" src="/art/blank.gif" /></td>
        <td height="1"><img width="3" height="1" src="/art/blank.gif" /></td>
        <td width="406" height="1" ><img width="406" height="1" src="/art/blank.gif" /></td>
        <td height="1"><img width="3" height="1" src="/art/blank.gif" /></td>
      </tr>
<%

}

%>
      </table>
    </td>
    <td align="right" valign="top" width="178">
      <table cellpadding="0" cellspacing="0" border="0" width="178">
      <tr>
        <td valign="top" width="178" height="56" style="background: url( '/art/logo3Small.gif' ) no-repeat; padding-top: 27px">
          <table cellpadding="0" cellspacing="0" width="178" border="0">
          <tr>
            <td style="padding-left: 16px";><h4>News</h4></td>
            <td width="100%" style="color: #000000; padding-top: 2px; text-align: right; padding-right: 12px;"><%= nowString %></td>
          </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td align="right">
          <table cellpadding="0" cellspacing="0" width="176" border="0">
          <tr>
            <td rowspan="2" valign="top" bgcolor="#D0D0D0" width="1" id="sep3"><img width="1" height="84" src="/art/greyFade.gif"></td>
            <td colspan="2" width="174"></td><td rowspan="2" valign="top" bgcolor="#D0D0D0" width="1" id="sep4"><img width="1" height="84" src="/art/greyFade.gif"></td>
          </tr>
          <tr>
            <td colspan="2" class="colPad1" valign="top">
              <table cellpadding="0" cellspacing="0" border="0" width="152">
              <tr>
                <td height="226px">
                  <table cellpadding="0" width="100%" height="226px" cellspacing="0" border="0">
                  <tr>
                    <td height="27" width="100%" style="text-align: right"><img onmouseover="newsUpFast();" onmouseout="newsNormal();" width="22" height="22" src="/art/newsUpArrow.gif" border="0" /></td>
                  </tr>
                  <tr>
                    <td width="100%" height="100%" id="newsHanger"></td>
                  </tr>
                  <tr>
                    <td valign="top" swidth="100%" style="padding-bottom: 17px">
                      <table cellpadding="0" cellspacing="0" border="0" width="100%">
                      <tr>
                        <td nowrap="nowrap" class="newsAddAnArticle"><a href="/pages/contactUs.jsp?type=news">Send in a news item</a></td>
                        <td style="text-align: right;"><img onmouseover="newsDownFast();" onmouseout="newsNormal();" width="22" height="22" src="/art/newsDownArrow.gif" border="0" /></td>
                      </tr>
                      </table>
                    </td>
                  </tr>
                  </table>
                </td>
              </tr>
<%
Advert tempAd;

for( int i = 0 ; i < (maxPremiereAds*2) ; i += 2 )
{
  if( i < premiereLiveAds.size() )
  {
    tempAd = (Advert)premiereLiveAds.get( i );

%>              <tr>
                <td class="premAd"><%= tempAd.getPostProcessAssetHtml( "Advert" ) %></td>
              </tr>
<%

  }
  else
  {

%>              <tr>
                <td class="premAdUnused">Premier Advertising<BR>From £<%= Advert.lowestPremierMonthlyCost %> per month</td>
              </tr>
<%

  }

%>              <tr>
                <td height="4px"></td>
              </tr>
<%

}

for( int i = 1 ; i < (maxStandardAds*2) ; i += 2 )
{
  if( i < standardLiveAds.size() )
  {
    tempAd = (Advert)standardLiveAds.get( i );

%>              <tr>
                <td class="standAd"><%= tempAd.getPostProcessAssetHtml( "Advert" ) %></td>
              </tr>
<%

  }
  else
  {

%>              <tr>
                <td class="standAdUnused">Standard Advertising<BR>From £<%= Advert.lowestStandardMonthlyCost %> per month</td>
              </tr>
<%

  }

%>              <tr>
                <td height="4px"></td>
              </tr>
<%

}

%>
              </table>
            </td>
          </tr>
          </table>
        </td>
      </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td id="footer" colspan="4" height="1px" bgcolor="#B2B2B2"></td>
  </tr>
  <tr>
    <td colspan="4" align="right">
      <table border="0" cellpadding="0" cellspacing="0" height="53" width="100%" class="footerLeft">
      <tr>
        <td>
          <table border="0" cellpadding="0" cellspacing="0" height="53" width="100%" class="footerRight">
          <tr>
            <td align="center"><img src="/art/footerText.gif" /><br />Use of this website constitutes acceptance of the Nextface <a href="/pages/list.jsp?l=terms">Terms & Conditions</a> and <a href="/pages/list.jsp?l=privacy">Privacy Policy</a>.<br /> &copy; 2003-2004 Nextface Ltd (all rights reserved)</td>
          </tr>
          </table>
        </td>
      </tr>
      </table>
    </td>
  </tr>
  </table>
</td>
<script type="text/javascript">
if( getwindowwidth() > 845 )
{
  document.write( '<td width="21" align="left"><table border="0" cellpadding="0" cellspacing="0">' );
  document.write( '<tr><td width="21" height="176" align="left"><img width="21" height="176" src="/art/logo2SmileCutoff.gif" /></td><td width="100%"></td></tr>' );
  document.write( '</table></td>' );
}
</script>
</tr>
</table>

<div id="dropdownoptions"></div>
<div id="pulldownoptions"></div>
<div id="newsScrollLayer">
<jsp:include page="/lists/list.jsp" flush="true" >
  <jsp:param name="l" value="news"/>
</jsp:include>
</div>

<div id="sepLyr1"></div>
<div id="sepLyr2"></div>
<div id="sepLyr3"></div>
<div id="sepLyr4"></div>

<div id="searchinganim"><table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%"><tr><td valign="middle" style="text-align: center; background-color: #888888; vertical-align: middle"><img id="srchFrmAnimGif" width="96" height="96" src="/art/searchAnim.gif" /></td></tr></table></div>

</body>
</html>
