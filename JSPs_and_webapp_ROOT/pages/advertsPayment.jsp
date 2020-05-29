<%@ page language="java"
  import="com.extware.advert.Advert,
          com.extware.utils.StringUtils,
          com.extware.utils.PropertyFile,
          java.net.URLEncoder"
%><%

request.getSession().setAttribute( "inworldpay", "true" );

//hold the details of the objects used to populate the form.
Advert advert = (Advert)request.getAttribute( "paymentadvert" );

//property file for prices and durations of adverts
PropertyFile dataDictionary = PropertyFile.getDataDictionary();

int adOptionNumber = StringUtils.parseInt( (String)request.getAttribute( "optionnumber" ), -1 );

float adAmmount = ( advert.premierePosition ? dataDictionary.getInt( "advertising.option." + adOptionNumber + ".permiereCostPounds" ) : dataDictionary.getInt( "advertising.option." + adOptionNumber + ".standardCostPounds" ) ) * 100.0F / 100.0F;

String description = advert.premierePosition ? advert.durationMonths + " months Premier advertising" : advert.durationMonths + " months Standard advertising";

String address = advert.address1;

if( advert.address2!=null && advert.address2.length() > 0 )
{
  address += "&#10;" + advert.address2;
}

if( advert.city!=null && advert.city.length() > 0 )
{
  address += "&#10;" + advert.city;
}

String urlParams = "cartId=AD_" + advert.advertId + "&amount=" + adAmmount + "&desc=" + URLEncoder.encode( description ) + "&address=" + URLEncoder.encode( StringUtils.nullString( address ) ) + "&postcode=" + URLEncoder.encode( advert.postcode ) + "&isUK=" + ( advert.countryRef==1 ) + "&tel=" + URLEncoder.encode( advert.telephone ) + "&fax=" + URLEncoder.encode( advert.fax ) + "&email=" + URLEncoder.encode( advert.email ) + "&adFile=" + URLEncoder.encode( advert.getPostProcessAssetHtml( "Advert" ) );

%>
<jsp:include page="/inc/pageHead.jsp" flush="true">
  <jsp:param name="wideForWorldpay" value="true" />
</jsp:include>
<iframe src="/pages/worldpay/advertsToFrame.jsp?<%= urlParams %>" width="432" height="1050" border="0" frameborder="0" ></iframe>
<jsp:include page="/inc/pageFoot.jsp" flush="true">
  <jsp:param name="wideForWorldpay" value="true" />
</jsp:include>