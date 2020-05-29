//			  Name     Menu Orient		width	table class	style per cell?

var menu1 = new mainMenu( "menu1", menuTypeHoriz,	-1,	"mainMenu",	1 );

//       Menu Object    ID              Text                    URI                     On Class        Off Class      Size Fade% Table Class

addItem( menu1,		"home",		"Homepage",		"/",			"mainMenuOn",	"mainMenuOff", 100, null, "subMenu" );
addItem( menu1,		"about",	"About Us",		"/?c=/about/",		"mainMenuOn",	"mainMenuOff", 100, null, "subMenu" );
addItem( menu1,		"clients",	"Client Portfolio",	"/?c=/clients/",	"mainMenuOn",	"mainMenuOff", 100, null, "subMenu" );
addItem( menu1,		"invest",	"Investor Information",	"/?c=/invest/",		"mainMenuOn",	"mainMenuOff", 100, null, "subMenu" );
addItem( menu1,		"forum",	"Forum",		"/?c=/forum/",		"mainMenuOn",	"mainMenuOff", 100, null, "subMenu" );
addItem( menu1,		"logout",	"Log Out",		"/servlet/Logout",	"mainMenuOn",	"mainMenuOff", 100, null, "subMenu" );

aboutMenu = findItem( menu1, "about" );

addItem( aboutMenu,	"team",		"The Team",		"/?c=/about/team/",	"subMenuOn",	"subMenuOff", 50, 70, "subMenu" );
addItem( aboutMenu,	"location",	"Find Us",		"/?c=/about/location/",	"subMenuOn",	"subMenuOff", 50, 70, "subMenu" );
addItem( aboutMenu,	"contact",	"Contact Us",		"/?c=/about/contact/",	"subMenuOn",	"subMenuOff", 50, 70, "subMenu" );

clientsMenu = findItem( menu1, "clients" );

addItem( clientsMenu,	"ypo",		"YPO",			"/?c=/clients/ypo/",	"subMenuOn",	"subMenuOff", 50, 70, "subMenu" );
addItem( clientsMenu,	"dhl",		"DHL",			"/?c=/clients/dhl/",	"subMenuOn",	"subMenuOff", 50, 70, "subMenu" );
addItem( clientsMenu,	"lms",		"LetMeShip",		"/?c=/clients/lms/",	"subMenuOn",	"subMenuOff", 50, 70, "subMenu" );

dhlMenu = findItem( clientsMenu, "dhl" );

addItem( dhlMenu,	"ngw",		"NGW",			"/?c=/clients/dhl/ngw/",	"subMenuOn",	"subMenuOff" );
addItem( dhlMenu,	"dpwn",		"DPWN",			"/?c=/clients/dhl/dpwn/",	"subMenuOn",	"subMenuOff" );
