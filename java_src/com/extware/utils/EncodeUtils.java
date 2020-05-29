package com.extware.utils;

/**
 * For encoding / unencoding text to be displayed in a html page. Soon will contain URLEncode and URLDecode methods
 *
 * @author   John Milner
 */
public class EncodeUtils
{

/**
 * For encoding text to be displayed in a html page.
 *
 * @param string  text to encode
 * @return        encoded text
 */
  public static String HTMLEncode( String string )
  {
    string = StringUtils.replace( string, "&", "&amp;", true, false );  //must be first
    string = StringUtils.replace( string, "<", "&lt;", true, false );
    string = StringUtils.replace( string, ">", "&gt;", true, false );
    string = StringUtils.replace( string, "\"", "&quot;", true, false );
    string = StringUtils.replace( string, "\\", "\\\\", true, false );
    return string;
  }

/**
 * For decoding text that's been encoded to find out what the original text was
 *
 * @param string  text to decode
 * @return        decoded text
 */
  public static String HTMLUnEncode( String string )
  {
    string = StringUtils.replace( string, "\\\\", "\\", true, false );
    string = StringUtils.replace( string, "&quot;", "\"", true, false );
    string = StringUtils.replace( string, "&gt;", ">", true, false );
    string = StringUtils.replace( string, "&lt;", "<", true, false );
    string = StringUtils.replace( string, "&amp;", "&", true, false );  //must be last
    return string;
  }

}

