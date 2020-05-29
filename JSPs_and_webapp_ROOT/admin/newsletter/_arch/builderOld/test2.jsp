<%@ page language="java" import="
  com.extware.asset.AssetTypePostProcess,
  com.extware.extsite.lists.ListItem,
  com.extware.extsite.lists.ListItemFile,
  com.extware.extsite.lists.ListType,
  com.extware.newsletter.Newsletter,
  com.extware.newsletter.NewsletterBuilder,
  com.extware.newsletter.NewsletterStory,
  com.extware.newsletter.NewsletterStoryTemplate,
  com.extware.newsletter.NewsletterTypeSection,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.FileUtils,
  com.extware.utils.NumberUtils,
  com.extware.utils.PropertyFile,
  com.extware.utils.StringUtils,
  java.sql.Connection,
  java.sql.SQLException,
  java.text.SimpleDateFormat,
  java.util.ArrayList,
  java.util.Enumeration,
  java.util.Hashtable,
  org.apache.regexp.RE,
  org.apache.regexp.RESyntaxException
" %><%

  PropertyFile conf = new PropertyFile( "com.extware.properties.Newsletter" );
  conf.refresh();

  Connection conn = DatabaseUtils.getDatabaseConnection();

  String root = getServletContext().getRealPath( "/" );

  String mode = StringUtils.nullString( request.getParameter( "mode" ) );

  boolean admin = true;
  String format = "h";
  String handle = "default";

  Newsletter newsletter = (Newsletter)session.getAttribute( "newsletter" );

  if( newsletter == null )
  {
    newsletter = new Newsletter( -1, -1, "default", "default template", "n", "daryl@eleventeenth.com", new ArrayList(), "htmlHeader", "htmlFooter", "textHeader", "textFooter" );
  }

  String formatName = conf.getString( "newsletter.formats.name."+format );
  String formatHandle = conf.getString( "newsletter.formats.handle."+format );
  String formatExtension = conf.getString( "newsletter.formats.extension."+format );
  String template = getNewsletterTemplate( root, newsletter.newsletterTypeHandle, format );

  ArrayList sections = getNewsletterSections( template, newsletter.newsletterTypeId );
  ArrayList storytemplates = NewsletterStoryTemplate.getNewsletterStoryTemplates( conn );

  if( mode.equals( "addstory" ) )
  {
    int itemId = NumberUtils.parseInt( request.getParameter( "itemId" ), -1 );
    String section = request.getParameter( "section" );
    String storyTemplateHandle = request.getParameter( "template" );

    if( itemId > 0 && section!=null )
    {
      ListItem item = ListItem.getListItem( itemId );
      newsletter.stories.add( new NewsletterStory( -1, section, storyTemplateHandle, item.listItemId, item.listTypeId, 999999 ) );
    }
  }
  else if( mode.equals( "removestory" ) )
  {
    String section = StringUtils.nullString( request.getParameter( "section" ) );
    int removeIndex = NumberUtils.parseInt( request.getParameter( "index" ), -1 );
    int itemId = NumberUtils.parseInt( request.getParameter( "itemId" ), -1 );

    for( int j=0; newsletter.stories!=null && j<newsletter.stories.size(); j++ )
    {
      NewsletterStory story = ( NewsletterStory )newsletter.stories.get( j );

      if( story.listItemId==itemId && story.index==removeIndex && section.equals( story.newsletterSectionHandle ) )
      {
        newsletter.stories.remove( j );
        break;
      }
    }
  }

  ArrayList stories = new ArrayList();

  for( int i=0; sections!=null && i<sections.size(); i++ )
  {
    NewsletterTypeSection section = ( NewsletterTypeSection )sections.get( i );
    int index = 0;

    for( int j=0; newsletter.stories!=null && j<newsletter.stories.size(); j++ )
    {
      NewsletterStory story = ( NewsletterStory )newsletter.stories.get( j );

      if( section.sectionHandle.equals( story.newsletterSectionHandle ) )
      {
        index++;
        story.index = index;
        stories.add( story );
      }
    }
  }

  newsletter.stories = stories;
  session.setAttribute( "newsletter",newsletter );
  conn.close();

  Hashtable templates = getStoryTemplates( root, newsletter.newsletterTypeHandle, formatHandle, formatExtension, storytemplates, sections );
  templates.put( formatHandle, template );

  Enumeration keys = templates.keys();

  String output = ( String )templates.get( formatHandle );

  for( int i=0; sections!=null && i<sections.size(); i++ )
  {
    NewsletterTypeSection section = ( NewsletterTypeSection )sections.get( i );
    String sectioncontents = getSection( admin, templates, formatHandle, section.sectionHandle, newsletter.stories );

    String adminSectionCodeHead = "";
    String adminSectionCodeFoot = "";

    if( admin )
    {
      adminSectionCodeHead = StringUtils.replace( conf.getString( "newsletter.section.admin.head" ),
                                                          "<section.handle>",
                                                          section.sectionHandle );
      adminSectionCodeFoot = StringUtils.replace( conf.getString( "newsletter.section.admin.foot" ),
                                                          "<section.handle>",
                                                          section.sectionHandle );
    }

    output = StringUtils.replace( output, "<section\\W*?handle=\""+section.sectionHandle+"\"\\W*?name=\""+section.sectionName+"\"\\W*?itemTypeHandles=\".*?\"\\W*?>", adminSectionCodeHead );
    output = StringUtils.replace( output, "<\\/section\\W*?handle=\""+section.sectionHandle+"\"\\W*?>", adminSectionCodeFoot );
    output = StringUtils.replace( output, "<section\\W*?content=\""+section.sectionHandle+"\"\\W*?>", sectioncontents );
  }

  out.println( output );

%><%!

  public static String getNewsletterTemplate( String root, String handle, String format ) throws IOException
  {
    PropertyFile conf = new PropertyFile( "com.extware.properties.Newsletter" );
    String templateDir = root + StringUtils.replace( conf.getString( "newsletter.templates.dir" ),
                                                          "<newsletter.typehandle>",
                                                          handle );
    String defaultDir = root + StringUtils.replace( conf.getString( "newsletter.templates.dir" ),
                                                          "<newsletter.typehandle>",
                                                          conf.getString( "newsletter.type.default.handle" ) );
    String formatName = conf.getString( "newsletter.formats.name."+format );
    String formatHandle = conf.getString( "newsletter.formats.handle."+format );
    String formatExtension = conf.getString( "newsletter.formats.extension."+format );
    String template = conf.getString( "newsletter.templates.filename" );
    template = StringUtils.replace( template, "<format.handle>", formatHandle );
    template = StringUtils.replace( template, "<format.extension>", formatExtension );

    if( FileUtils.fileExists( templateDir + template ) )
    {
      return FileUtils.readFile( templateDir + template );
    }
    else
    if( FileUtils.fileExists( defaultDir + template ) )
    {
      return FileUtils.readFile( defaultDir + template );
    }
    return "";
  }

%><%!

  public static Hashtable getStoryTemplates( String root, String handle, String formatHandle, String formatExtension, ArrayList storytemplates, ArrayList sections ) throws IOException
  {
    PropertyFile conf = new PropertyFile( "com.extware.properties.Newsletter" );
    Hashtable templates = new Hashtable();
    String templateDir = root + StringUtils.replace( conf.getString( "newsletter.templates.dir" ),
                                                          "<newsletter.typehandle>",
                                                          handle );
    String defaultDir = root + StringUtils.replace( conf.getString( "newsletter.templates.dir" ),
                                                          "<newsletter.typehandle>",
                                                          conf.getString( "newsletter.type.default.handle" ) );

    for( int j=0; storytemplates!=null && j<storytemplates.size(); j++ )
    {
      NewsletterStoryTemplate storytemplate = ( NewsletterStoryTemplate )storytemplates.get( j );
      String fname = formatHandle + "_" + storytemplate.storyTemplateHandle + "." + formatExtension;
      String hand = formatHandle + "_" + storytemplate.storyTemplateHandle;

      if( FileUtils.fileExists( templateDir + fname ) )
      {
        templates.put( hand, FileUtils.readFile( templateDir + fname ) );
      }
      else if( FileUtils.fileExists( defaultDir + fname ) )
      {
        templates.put( hand, FileUtils.readFile( defaultDir + fname ) );
      }

      for( int i=0; sections!=null && i<sections.size(); i++ )
      {
        NewsletterTypeSection section = ( NewsletterTypeSection )sections.get( i );
        String fname2 = formatHandle + "_" + storytemplate.storyTemplateHandle + "_" + section.sectionHandle + "." + formatExtension;
        String hand2 = formatHandle + "_" + storytemplate.storyTemplateHandle + "_" + section.sectionHandle;

        if( FileUtils.fileExists( templateDir + fname2 ) )
        {
          templates.put( hand2, FileUtils.readFile( templateDir + fname2 ) );
        }
        else if( FileUtils.fileExists( defaultDir + fname2 ) )
        {
          templates.put( hand2, FileUtils.readFile( defaultDir + fname2 ) );
        }
      }
    }

    return templates;
  }

%>

<%!
  public static ArrayList getNewsletterSections( String contents, int newsletterTypeId )
  {
    ArrayList ret = new ArrayList();

    try
    {
      String match = "<section\\W*?handle=\"( .*? )\"\\W*?name=\"( .*? )\"\\W*?itemTypeHandles=\"( .*? )\"\\W*?>";
      RE regexp = new RE( match );
      regexp.setMatchFlags( RE.MATCH_SINGLELINE );
      int index = 0;

      if( regexp.match( contents ) )
      {
        while( regexp.match( contents, index ) )
        {
          String handle = regexp.getParen( 1 );
          String name = regexp.getParen( 2 );
          String itemTypeHandlesString = regexp.getParen( 3 );
          String[] itemTypeHandles = null;

          if( itemTypeHandlesString.indexOf( "|" )!=-1 )
          {
            itemTypeHandles = StringUtils.split( itemTypeHandlesString, "\\|" );
          }
          else if( itemTypeHandlesString.indexOf( "," )!=-1 )
          {
            itemTypeHandles = StringUtils.split( itemTypeHandlesString, "," );
          }
          else if( !itemTypeHandlesString.trim().equals( "" ) )
          {
            itemTypeHandles = new String[] { itemTypeHandlesString };
          }

          index = regexp.getParenEnd( 3 );
          ret.add( new NewsletterTypeSection( -1, newsletterTypeId, handle, name, itemTypeHandles ) );
        }
      }
      else
      {
      }
    }
    catch( RESyntaxException ex )
    {
      ex.printStackTrace();
    }

    return ret;
  }
%>

<%!
  public static String getSection( boolean admin, Hashtable templates, String formatHandle, String sectionHandle, ArrayList stories ) throws SQLException
  {
    PropertyFile conf = new PropertyFile( "com.extware.properties.Newsletter" );
    String adminStoryCodeHead = "";
    String adminStoryCodeFoot = "";
    String ret = "";

    if( admin )
    {
      adminStoryCodeHead = StringUtils.replace( conf.getString( "newsletter.story.admin.head" ),
                                                          "<section.handle>",
                                                          sectionHandle );;
      adminStoryCodeFoot = StringUtils.replace( conf.getString( "newsletter.story.admin.foot" ),
                                                          "<section.handle>",
                                                          sectionHandle );;
    }

    SimpleDateFormat format = new SimpleDateFormat( "dd MMM yyyy" );

    for( int i=0; stories!=null && i<stories.size(); i++ )
    {
      NewsletterStory story = ( NewsletterStory )stories.get( i );
//System.out.println( story.newsletterSectionHandle + "=" + sectionHandle );

      if( !story.newsletterSectionHandle.equals( sectionHandle ) )
      {
        continue;
      }
      String storyTemplateHandle = story.newsletterStoryTemplateHandle;
      String template = "";

      if( templates.get( formatHandle+"_"+storyTemplateHandle+"_"+sectionHandle ) != null )
      {
        template = ( String )templates.get( formatHandle+"_"+storyTemplateHandle+"_"+sectionHandle );
      }
      else if( templates.get( formatHandle+"_"+storyTemplateHandle ) != null )
      {
        template = ( String )templates.get( formatHandle+"_"+storyTemplateHandle );
      }

      String thisadminhead = StringUtils.replace( adminStoryCodeHead, "<story.id>", String.valueOf( story.newsletterStoryId ) );
      String thisadminfoot = StringUtils.replace( adminStoryCodeFoot, "<story.id>", String.valueOf( story.newsletterStoryId ) );

      thisadminhead = StringUtils.replace( thisadminhead, "<item.id>",     String.valueOf( story.listItemId ) );
      thisadminfoot = StringUtils.replace( thisadminfoot, "<item.id>",     String.valueOf( story.listItemId ) );
      thisadminhead = StringUtils.replace( thisadminhead, "<story.index>", String.valueOf( story.index ) );
      thisadminfoot = StringUtils.replace( thisadminfoot, "<story.index>", String.valueOf( story.index ) );

      ListItem item = ListItem.getListItem( story.listItemId );
      item.files = item.getListItemFiles();
      ListType listType = ListType.getListType( item.listTypeId );
      String thistemplate = template;

      thistemplate = StringUtils.replace( thistemplate, "<story.id>",         StringUtils.nullString( String.valueOf( item.listItemId ) ) );
      thistemplate = StringUtils.replace( thistemplate, "<story.title>",      StringUtils.nullString( item.title ) );
      thistemplate = StringUtils.replace( thistemplate, "<story.standfirst>", StringUtils.nullString( item.standfirst ) );
      thistemplate = StringUtils.replace( thistemplate, "<story.body>",       StringUtils.nullString( item.body ) );
      thistemplate = StringUtils.replace( thistemplate, "<story.fromdate>",   item.fromDate!=null ? StringUtils.nullString( format.format( item.fromDate ) ) : "" );
      thistemplate = StringUtils.replace( thistemplate, "<story.todate>",     item.toDate!=null ? StringUtils.nullString( format.format( item.toDate ) ) : "" );

      ListItemFile primaryImage = item.getFile( listType.defaultAssetTypeName );

      if( primaryImage != null && primaryImage.asset != null )
      {
        for( int p=0; primaryImage.asset.postProcesses!=null && p<primaryImage.asset.postProcesses.size(); p++ )
        {
          AssetTypePostProcess proc = ( AssetTypePostProcess )primaryImage.asset.postProcesses.get( p );
          //System.out.println( proc.processName );
          String src = primaryImage.getImagePath( proc.processName );
          thistemplate = StringUtils.replace( thistemplate, "<storyimage postprocess=\""+proc.processName+"\">", "" );
          thistemplate = StringUtils.replace( thistemplate, "</storyimage postprocess=\""+proc.processName+"\">", "" );
          thistemplate = StringUtils.replace( thistemplate, "<storyimage.src postprocess=\""+proc.processName+"\">", src );
        }
      }

      thistemplate = StringUtils.replace( thistemplate, "<storyimage postprocess=\".*\">.*</storyimage postprocess=\".*\">", "" );
      thistemplate = StringUtils.replace( thistemplate, "<story>", thisadminhead );
      thistemplate = StringUtils.replace( thistemplate, "</story>", thisadminfoot );
      ret += thistemplate;
    }

    return ret;
  }

%>
