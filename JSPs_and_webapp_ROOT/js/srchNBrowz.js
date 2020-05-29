//images to preload
preloadImagePaths = new Array( '/art/searchButton.gif', '/art/searchAnim.gif' );
preloadedImages = new Array( new Image(), new Image() );

//admin globals for js dropdowns
var IE = document.all?true:false;
if (!IE)
{
  document.captureEvents(Event.MOUSEMOVE)
}
document.onmousemove = getMouseXY;
var dropDownShowing = false;
var lastDropDownName = '';
var dropDownBottomCoord = -1;
var dropDownLeftCoord = -1;
var dropDownTopCoord = -1;
var dropDownScrollThresholdBottom = -1;
var dropDownScrollThresholdTop = -1;
var dropDownScrolling = false;
var scrollTimer=null;
var orphanTimer=null;
var tempX = -1;
var tempY = -1;
var scrollYAtDDCreate = -1;
var scrollY = -1;
var wheight = -1;


//drop down data
var compSizeSrc    = new Array ( '1-5', '6-15', '16-50', '51-100', '100+' );
var compSizeAny   = 'Any size'; var compSizeSlct   = 'COMPANY SIZE'; var compSizePrnt   = null; var compSizeChld    = null;

var jobTypeSrc     = new Array ( 'Full-time', 'Part-time', 'Contract / Comission', 'Hobbyist / Voluntary' );
var jobTypeAny   = 'Any type'; var jobTypeSlct   = 'TYPE OF WORK'; var jobTypePrnt    = null; var jobTypeChld    = null;

var fileTypeSrc     = new Array ( 'Images', 'Audio / Movie / Mixed media' );
var fileTypeAny   = 'Any file type'; var fileTypeSlct   = 'FILE TYPE'; var fileTypePrnt    = null; var fileTypeChld    = null;

var categorySrc    = new Array ( 'Art', 'Performance Art & Theatre', 'Design', 'Video / Film / Broadcast', 'Games / Interactive', 'Creative Services' );
var categoryAny   = null; var categorySlct   = 'SELECT CATEGORY'; var categoryPrnt   = null; var categoryChld   = 'discipline';

var BcategorySrc    = categorySrc;  //for browse stuff
var BcategoryAny   = null; var BcategorySlct   = 'SELECT CATEGORY'; var BcategoryPrnt   = null; var BcategoryChld   = 'Bdiscipline';

var disciplineSrc = new Array();
disciplineSrc[ '1' ] = new Array('Antiques / Restoration', 'Artisan / Crafts', 'Calligraphy / Lettering', 'Ceramics / Pottery', 'Collage / Murals', 'Comic art / Cartoonists', 'Computer generated / Digital', 'Ethnic / World art', 'Galleries', 'Glasswork', 'Installations', 'Jewellery', 'Leatherwork', 'Metalwork', 'Millinery / Costumes', 'Needlework / Knitting', 'Painting / Drawing', 'Paperwork', 'Photography', 'Print', 'Sculpture', 'Textiles', 'Video / Film', 'Woodcraft / Woodworker');
disciplineSrc[ '2' ] = new Array('Acrobats', 'Actors', 'Actresses', 'Agents: Actors / Extras', 'Circus performers', 'Clowns', 'Comedians', 'Composers', 'Costumes', 'Dance / Music & Dance', 'Magicians / Illusionists', 'Mime artists', 'Musicians / Bands', 'Performance artists', 'Producers / Directors', 'Puppeteers / Ventriloquists', 'Special FX / Pyrotechnics', 'Street performers', 'Theatrical lighting', 'Theatrical music / audio', 'Theatrical set design', 'Voice actors', 'Writers / Scriptwriters');
disciplineSrc[ '3' ] = new Array('Advertising / Marketing', 'Animation 2D', 'Animation 3D', 'Architecture', 'Art managers / Directors', 'Automotive / Transport', 'Computer graphics (general)', 'Consultancy (general)', 'Corporate ID / literature', 'Designer-maker', 'Display / Exhibition / Events', 'Fashion / Clothing', 'Furniture', 'Graphics / Packaging', 'Illustration', 'Interactive presentations', 'Interior / Retail', 'Landscape / Gardens', 'Lighting / Lamps', 'Printing services', 'Product / Industrial / 3D', 'Signage', 'Textiles', 'Typography', 'Web / New media');
disciplineSrc[ '4' ] = new Array('*CG Animators', '*CG Audio / Speech synch', '*CG Characters / Rigging', '*CG Environments', '*CG Lighting', '*CG Modellers', '*CG Post production', '*CG Rendering', '*CG Special effects', '*CG Technical director', '*CG Texture artist', 'Actors / Voice actors', 'Agents: Actors / Extras', 'Agents: Models', 'Animatronics / Robotics', 'Art directors / Managers', 'Audio equipment: Rental', 'Audio equipment: Sales', 'Camera crews', 'Cameramen / Assistants', 'Casting services', 'Costumes / Props', 'Distribution / Logistics', 'Duplication: Film / Video', 'Editing: Film / TV / Video', 'Electricians / Construction', 'Film equipment: Rental', 'Film equipment: Sales', 'Legal / Insurance services', 'Lighting services', 'Location services', 'MakeUp / Styling / Prosthet\'s', 'Marketing / PR', 'Motion capture/control', 'Music / Composers / Audio', 'Outside broadcast services', 'Production: Film', 'Production: TV / Video', 'Recording / Audio post', 'Set design / Construction', 'Storyboards / Concepts', 'Studio hire: Film / TV / Video', 'Subtitling / Captioning', 'TV stations', 'Video equipment: Rental', 'Video equipment: Sales', 'Writers / Scriptwriters');
disciplineSrc[ '5' ] = new Array('*CG Animators', '*CG Characters / Rigging', '*CG Environments / Levels', '*CG FMV / Post production', '*CG General artist', '*CG GUI designer', '*CG Lead artist / Director', '*CG Lighting', '*CG Modeller', '*CG Special effects', '*CG Sprite / Pixel artist', '*CG Technical artist', '*CG Texture artist', 'Actors / Voice actors', 'Designers (general)', 'Games developers', 'Games publishers', 'Marketing / PR', 'Motion capture/control', 'Music / Composers / Audio', 'Producers / Production', 'Programmers / IT', 'Storyboards / Concepts', 'Testers / QA', 'Video editing / Production', 'Writers / Scriptwriters');
disciplineSrc[ '6' ] = new Array('Agents: Models', 'Animal hire', 'Catering services', 'Computer equipment: Rental', 'Computer equipment: Sales', 'Copywriters / Translation', 'Courier / Despatch', 'Digital file handling / Storage', 'Digital image retouching', 'Digital printing / Display grfx', 'DVD / CD authoring', 'Exhibition / Gallery venues', 'Holographers', 'Libraries: Music / Audio', 'Libraries: Stills', 'Libraries: Video / Film', 'Media archiving / Storage', 'Model making', 'Motion capture/control', 'Mounting / Lamination', 'Photo equipment: Rental', 'Photo equipment: Sales', 'Photographic labs', 'Picture research', 'PR / Merchandising', 'Prepress bureaux', 'Printing / Copying services', 'Radio production / Stations', 'Recording studios', 'Security services', 'Software sales / Support', 'Trade shows / Expos', 'Vehicle rental', 'Web hosting / Maintenance');
var disciplineAny   = 'Any discipline'; var disciplineSlct   = 'SELECT DISCIPLINE'; var disciplinePrnt = 'category'; var disciplineChld = null;

var BdisciplineSrc = disciplineSrc;  //for browse stuff
var BdisciplineAny   = 'Any discipline'; var BdisciplineSlct   = 'SELECT DISCIPLINE'; var BdisciplinePrnt = 'Bcategory'; var BdisciplineChld = null;

var regionSrc      = new Array ( 'South West England', 'South East England', 'Greater London', 'Eastern England', 'West Midlands', 'East Midlands', 'Wales', 'Yorkshire & the Humber', 'North West England', 'North East England', 'Scotland', 'Northern Ireland' );
var regionAny   = 'Any region'; var regionSlct   = 'SELECT UK REGION'; var regionPrnt    = null; var regionChld    = 'county';

var countySrc = new Array();
countySrc[ '1' ]  = new Array('Bath & NE Somerset', 'Bournemouth', 'Bristol', 'Cornwall', 'Devon', 'Dorset', 'Gloucestershire', 'Isles of Scilly', 'North Somerset', 'Plymouth', 'Poole', 'Somerset', 'South Gloucestershire', 'Swindon', 'Torbay', 'Wiltshire');
countySrc[ '2' ]  = new Array('Bracknell Forest', 'Brighton & Hove', 'Buckinghamshire', 'East Sussex', 'Hampshire', 'Isle of Wight', 'Kent', 'Medway', 'Milton Keynes', 'Oxfordshire', 'Portsmouth', 'Reading', 'Slough', 'Southampton', 'Southend-on-Sea', 'Surrey', 'Thurrock', 'West Berkshire', 'West Sussex', 'Windsor & Maidenhead', 'Wokingham');
countySrc[ '3' ]  = new Array('Barking & Dagenham', 'Barnet', 'Bexley', 'Brent', 'Bromley', 'Camden', 'City of London', 'City of Westminster', 'Croydon', 'Ealing', 'Enfield', 'Greenwich', 'Hackney', 'Hammersmith & Fulham', 'Haringey', 'Harrow', 'Havering', 'Hillingdon', 'Hounslow', 'Islington', 'Kensington & Chelsea', 'Kingston upon Thames', 'Lambeth', 'Lewisham', 'Merton', 'Newham', 'Redbridge', 'Richmond upon Thames', 'Southwark', 'Sutton', 'Tower Hamlets', 'Waltham Forest', 'Wandsworth');
countySrc[ '4' ]  = new Array('Bedfordshire', 'Cambridgeshire', 'Essex', 'Hertfordshire', 'Luton', 'Norfolk', 'Peterborough', 'Suffolk');
countySrc[ '5' ]  = new Array('Birmingham', 'Coventry', 'Dudley', 'Herefordshire', 'Sandwell', 'Shropshire', 'Solihull', 'Staffordshire', 'Stoke-on-Trent', 'Telford & Wrekin', 'Walsall', 'Warwickshire', 'Wolverhampton', 'Worcestershire');
countySrc[ '6' ]  = new Array('Derby', 'Derbyshire', 'Leicester', 'Leicestershire', 'Lincolnshire', 'Northamptonshire', 'Nottingham', 'Nottinghamshire', 'Rutland');
countySrc[ '7' ]  = new Array('Blaenau Gwent', 'Bridgend', 'Caerphilly', 'Cardiff', 'Carmarthenshire', 'Ceredigion', 'Conwy', 'Denbighshire', 'Flintshire', 'Gwynedd', 'Isle of Anglesey', 'Merthyr Tydfil', 'Monmouthshire', 'Neath/Port Talbot', 'Newport', 'Pembrokeshire', 'Powys', 'Rhondda', 'Swansea', 'Torfaen', 'Vale of Glamorgan', 'Wrexham');
countySrc[ '8' ]  = new Array('Barnsley', 'Bradford', 'Calderdale', 'Doncaster', 'East Riding of Yorkshire', 'Kingston upon Hull', 'Kirklees', 'Leeds', 'North East Lincolnshire', 'North Lincolnshire', 'North Yorkshire', 'Rotherham', 'Sheffield', 'Wakefield', 'York');
countySrc[ '9' ]  = new Array('Blackburn with Darwen', 'Blackpool', 'Bolton', 'Bury', 'Cheshire', 'Cumbria', 'Halton', 'Knowsley', 'Lancashire', 'Manchester', 'Oldham', 'Rochdale', 'Salford', 'Sefton', 'St Helens', 'Stockport', 'Tameside', 'Trafford', 'Warrington', 'Wigan', 'Wirral');
countySrc[ '10' ] = new Array('Darlington', 'Durham', 'Gateshead', 'Hartlepool', 'Middlesbrough', 'Newcastle-upon-Tyne', 'North Tyneside', 'Northumberland', 'Redcar & Cleveland', 'South Tyneside', 'Stockton-on-Tees', 'Sunderland');
countySrc[ '11' ] = new Array('Aberdeen', 'Aberdeenshire', 'Angus', 'Argyll & Bute', 'Clackmannanshire', 'Dumfries & Galloway', 'Dundee', 'East Ayrshire', 'East Dunbartonshire', 'East Lothian', 'East Renfrewshire', 'Edinburgh', 'Falkirk', 'Fife', 'Glasgow', 'Highlands', 'Inverclyde', 'Midlothian', 'Moray', 'North Ayrshire', 'North Lanarkshire', 'Orkney Isles', 'Perth & Kinross', 'Renfrewshire', 'Scottish Borders', 'Shetland Isles', 'South Ayrshire', 'South Lanarkshire', 'Stirling', 'West Dunbartonshire', 'West Lothian', 'Western Isles');
countySrc[ '12' ] = new Array('Antrim', 'Armagh', 'Belfast', 'Derry/Londonderry', 'Down', 'Fermanagh', 'Tyrone');
var countyAny   = 'Any county / unitary'; var countySlct   = 'SELECT COUNTY / UNITARY'; var countyPrnt    = 'region'; var countyChld    = null;

var countrySrc = new Array   ( 'United Kingdom' , 'Afghanistan' , 'Albania' , 'Algeria' , 'American Samoa' , 'Andorra' , 'Angola' , 'Anguilla' , 'Antarctica' , 'Antigua And Barbuda' , 'Argentina' , 'Armenia' , 'Aruba' , 'Australia' , 'Austria' , 'Azerbaijan' , 'Bahamas' , 'Bahrain' , 'Bangladesh' , 'Barbados' , 'Belarus' , 'Belgium' , 'Belize' , 'Benin' , 'Bermuda' , 'Bhutan' , 'Bolivia' , 'Bosnia And Herzegowina' , 'Botswana' , 'Bouvet Island' , 'Brazil' , 'British Indian Oc\'n Territory' , 'Brunei Darussalam' , 'Bulgaria' , 'Burkina Faso' , 'Burundi' , 'Cambodia' , 'Cameroon' , 'Canada' , 'Cape Verde' , 'Cayman Islands' , 'Central African Republic' , 'Chad' , 'Chile' , 'China' , 'Christmas Island' , 'Cocos (Keeling) Islands' , 'Colombia' , 'Comoros' , 'Congo' , 'Congo, Democratic Repub\'c' , 'Cook Islands' , 'Costa Rica' , 'Cote D\'ivoire' , 'Croatia (Hrvatska)' , 'Cuba' , 'Cyprus' , 'Czech Republic' , 'Denmark' , 'Djibouti' , 'Dominica' , 'Dominican Republic' , 'East Timor' , 'Ecuador' , 'Egypt' , 'El Salvador' , 'Equatorial Guinea' , 'Eritrea' , 'Estonia' , 'Ethiopia' , 'Falkland Islands (Malvinas)' , 'Faroe Islands' , 'Fiji' , 'Finland' , 'France' , 'French Guiana' , 'French Polynesia' , 'French Southern Territories' , 'Gabon' , 'Gambia' , 'Georgia' , 'Germany' , 'Ghana' , 'Gibraltar' , 'Greece' , 'Greenland' , 'Grenada' , 'Guadeloupe' , 'Guam' , 'Guatemala' , 'Guinea' , 'Guinea-Bissau' , 'Guyana' , 'Haiti' , 'Heard & Mc Donald Islands' , 'Holy See, Vatican City State' , 'Honduras' , 'Hong Kong' , 'Hungary' , 'Iceland' , 'India' , 'Indonesia' , 'Iran (Islamic Republic Of)' , 'Iraq' , 'Ireland' , 'Israel' , 'Italy' , 'Jamaica' , 'Japan' , 'Jordan' , 'Kazakhstan' , 'Kenya' , 'Kiribati' , 'Korea, People\'s Rep\'c' , 'Korea, Republic Of' , 'Kuwait' , 'Kyrgyzstan' , 'Lao Democr\'c Republic' , 'Latvia' , 'Lebanon' , 'Lesotho' , 'Liberia' , 'Libyan Arab Jamahiriya' , 'Liechtenstein' , 'Lithuania' , 'Luxembourg' , 'Macau' , 'Macedonia' , 'Madagascar' , 'Malawi' , 'Malaysia' , 'Maldives' , 'Mali' , 'Malta' , 'Marshall Islands' , 'Martinique' , 'Mauritania' , 'Mauritius' , 'Mayotte' , 'Mexico' , 'Micronesia, Federated States' , 'Moldova, Republic Of' , 'Monaco' , 'Mongolia' , 'Montserrat' , 'Morocco' , 'Mozambique' , 'Myanmar' , 'Namibia' , 'Nauru' , 'Nepal' , 'Netherlands' , 'Netherlands Antilles' , 'New Caledonia' , 'New Zealand' , 'Nicaragua' , 'Niger' , 'Nigeria' , 'Niue' , 'Norfolk Island' , 'Northern Mariana Islands' , 'Norway' , 'Oman' , 'Pakistan' , 'Palau' , 'Palestinian Territory', 'Panama' , 'Papua New Guinea' , 'Paraguay' , 'Peru' , 'Philippines' , 'Pitcairn' , 'Poland' , 'Portugal' , 'Puerto Rico' , 'Qatar' , 'Reunion' , 'Romania' , 'Russian Federation' , 'Rwanda' , 'Saint Kitts And Nevis' , 'Saint Lucia' , 'Saint Vincent & Grenadines' , 'Samoa' , 'San Marino' , 'Sao Tome And Principe' , 'Saudi Arabia' , 'Senegal' , 'Seychelles' , 'Sierra Leone' , 'Singapore' , 'Slovakia (Slovak Republic)' , 'Slovenia' , 'Solomon Islands' , 'Somalia' , 'South Africa' , 'South Georgia' , 'Spain' , 'Sri Lanka' , 'St. Helena' , 'St. Pierre And Miquelon' , 'Sudan' , 'Suriname' , 'Svalbard & Jan Mayen' , 'Swaziland' , 'Sweden' , 'Switzerland' , 'Syrian Arab Republic' , 'Taiwan, Province Of China' , 'Tajikistan' , 'Tanzania, United Republic Of' , 'Thailand' , 'Togo' , 'Tokelau' , 'Tonga' , 'Trinidad And Tobago' , 'Tunisia' , 'Turkey' , 'Turkmenistan' , 'Turks And Caicos Islands' , 'Tuvalu' , 'Uganda' , 'Ukraine' , 'United Arab Emirates' , 'United States' , 'U.S. Outlying Islands' , 'Uruguay' , 'Uzbekistan' , 'Vanuatu' , 'Venezuela' , 'Viet Nam' , 'Virgin Islands (British)' , 'Virgin Islands (U.S.)' , 'Wallis And Futuna Islands' , 'Western Sahara' , 'Yemen' , 'Yugoslavia' , 'Zambia' , 'Zimbabwe' );
var countryAny   = 'Any country'; var countrySlct   = 'SELECT COUNTRY'; var countryPrnt    = null; var countryChld    = null;

ctryLyr =  ddRow( 'sctOtpn( 1   )'  , 'United Kingdom' );
ctryLyr += ddRow( 'sctOtpn( 225 )'  , 'United States' );
ctryLyr += ddRow( 'sctOtpn( 14  )'  , 'Australia' );
ctryLyr += ddRow( 'sctOtpn( 15  )'  , 'Austria' );
ctryLyr += ddRow( 'sctOtpn( 22  )'  , 'Belgium' );
ctryLyr += ddRow( 'sctOtpn( 39  )'  , 'Canada' );
ctryLyr += ddRow( 'sctOtpn( 59  )'  , 'Denmark' );
ctryLyr += ddRow( 'sctOtpn( 74  )'  , 'Finland' );
ctryLyr += ddRow( 'sctOtpn( 75  )'  , 'France' );
ctryLyr += ddRow( 'sctOtpn( 82  )'  , 'Germany' );
ctryLyr += ddRow( 'sctOtpn( 101 )'  , 'India' );
ctryLyr += ddRow( 'sctOtpn( 105 )'  , 'Ireland' );
ctryLyr += ddRow( 'sctOtpn( 107 )'  , 'Italy' );
ctryLyr += ddRow( 'sctOtpn( 126 )'  , 'Luxembourg' );
ctryLyr += ddRow( 'sctOtpn( 152 )'  , 'Netherlands' );
ctryLyr += ddRow( 'sctOtpn( 155 )'  , 'New Zealand' );
ctryLyr += ddRow( 'sctOtpn( 162 )'  , 'Norway' );
ctryLyr += ddRow( 'sctOtpn( 174 )'  , 'Portugal' );
ctryLyr += ddRow( 'sctOtpn( 198 )'  , 'Spain' );
ctryLyr += ddRow( 'sctOtpn( 206 )'  , 'Sweden' );
ctryLyr += ddRow( 'sctOtpn( 207 )'  , 'Switzerland' );
ctryLyr += ddRow( 'sctCtry( \'A\' )', 'List all \'<em>A</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'B\' )', 'List all \'<em>B</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'C\' )', 'List all \'<em>C</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'D\' )', 'List all \'<em>D</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'E\' )', 'List all \'<em>E</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'F\' )', 'List all \'<em>F</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'G\' )', 'List all \'<em>G</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'H\' )', 'List all \'<em>H</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'I\' )', 'List all \'<em>I</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'J\' )', 'List all \'<em>J</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'K\' )', 'List all \'<em>K</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'L\' )', 'List all \'<em>L</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'M\' )', 'List all \'<em>M</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'N\' )', 'List all \'<em>N</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'O\' )', 'List all \'<em>O</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'P\' )', 'List all \'<em>P</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'Q\' )', 'List all \'<em>Q</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'R\' )', 'List all \'<em>R</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'S\' )', 'List all \'<em>S</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'T\' )', 'List all \'<em>T</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'U\' )', 'List all \'<em>U</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'V\' )', 'List all \'<em>V</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'W\' )', 'List all \'<em>W</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'X\' )', 'List all \'<em>X</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'Y\' )', 'List all \'<em>Y</em>\' countries' );
ctryLyr += ddRow( 'sctCtry( \'Z\' )', 'List all \'<em>Z</em>\' countries' );

function ddRow( onclick, desc )
{
  return '<tr><td onclick="' + onclick + ';" onmouseover="this.className=\'dgOn\';" onmouseout="this.className=\'dgOff\';" class="dgOff">' + desc + '</td></tr>';
}


//display logic for drop downs
//browse
var Bcategory =     '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="Bcategory"><tr><td height="19" width="159" class="menuOption" id="BcategoryCell">' + BcategorySlct + '</td><td><a href="javascript:popmenu( \'Bcategory\' );"><img src="/art/searchOra.gif" border="0"></a></td></tr></table></td></tr>';
var Bdiscipline =   '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="Bdiscipline"><tr><td height="19" width="159" class="menuOption" id="BdisciplineCell">' + BdisciplineSlct + '</td><td><a href="javascript:popmenu( \'Bdiscipline\' );"><img src="/art/searchOra.gif"></a></td></tr></table></td></tr>';  //for browse drop down
//search
var textFill =      '<table border="0" cellpadding="0" cellspacing="0"><tr><td class="searchPanelTop"><a href="javascript:killDropDown(); restartSearch();">new search<a></td></tr>';
var compSize =      '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="compSize"><tr><td height="19" width="159" class="menuOption" id="compSizeCell">' + compSizeSlct + '</td><td><a href="javascript:popmenu( \'compSize\' );"><img src="/art/searchOra.gif"></a></td></tr></table></td></tr>';
var jobType =       '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="jobType" ><tr><td height="19" width="159" class="menuOption" id="jobTypeCell" >' + jobTypeSlct + '</td><td><a href="javascript:popmenu( \'jobType\' );"><img src="/art/searchOra.gif"></a></td></tr></table></td></tr>';
var fileType =      '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="fileType" ><tr><td height="19" width="159" class="menuOption" id="fileTypeCell" >' + fileTypeSlct + '</td><td><a href="javascript:popmenu( \'fileType\' );"><img src="/art/searchOra.gif"></a></td></tr></table></td></tr>';
var category =      '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="category"><tr><td height="19" width="159" class="menuOption" id="categoryCell">' + categorySlct + '</td><td><a href="javascript:popmenu( \'category\' );"><img src="/art/searchOra.gif" border="0"></a></td></tr></table></td></tr>';
var discipline =    '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="discipline"><tr><td height="19" width="159" class="menuOption" id="disciplineCell">' + disciplineSlct + '</td><td><a href="javascript:popmenu( \'discipline\' );"><img src="/art/searchOra.gif"></a></td></tr></table></td></tr>';
var country =       '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="country" ><tr><td height="19" width="159" class="menuOption" id="countryCell" >' + countrySlct + '</td><td><a href="javascript:popmenu( \'country\' );"><img src="/art/searchOra.gif"></a></td></tr></table></td></tr>';  //for browse drop down
var region =        '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="region"  ><tr><td height="19" width="159" class="menuOption" id="regionCell"  >' + regionSlct + '</td><td><a href="javascript:popmenu( \'region\' );"><img src="/art/searchOra.gif"></a></td></tr></table></td></tr>';
var county =        '<tr><td height="1px"></td></tr><tr><td><table cellpadding="0" cellspacing="0" id="county"  ><tr><td height="19" width="159" class="menuOption" id="countyCell"  >' + countySlct + '</td><td><a href="javascript:popmenu( \'county\' );"><img src="/art/searchOra.gif"></a></td></tr></table></td></tr>';
var keywordSearch = '<tr><td height="1px"></td></tr>' +
                    '<tr><td><form name="search" onsubmit="populateSrchHiddens( this ); return true;" action="/servlet/Search" method="post">' +
                            '<input type="hidden" name="formname" value="search" />' +
                            '<input type="hidden" name="searchtype" value="" />' +
                            '<input type="hidden" name="compsizeval" value="" />' +
                            '<input type="hidden" name="jobtypeval" value="" />' +
                            '<input type="hidden" name="filetypeval" value="" />' +
                            '<input type="hidden" name="categoryval" value="" />' +
                            '<input type="hidden" name="disciplineval" value="" />' +
                            '<input type="hidden" name="countryval" value="" />' +
                            '<input type="hidden" name="regionval" value="" />' +
                            '<input type="hidden" name="countyval" value="" />' +
                            '<table cellpadding="0" cellspacing="0">' +
                              '<tr><td id="srcTxtCell" height="19" width="175" class="textInputCell" colspan="2"><input onfocus="if( this.value == \'  KEYWORD\' ) { this.value = \'\'; document.getElementById( \'srcTxtCell\' ).className = \'textInputCellSelected\' }" onblur="if( this.value == \'\' ) { this.value = \'  KEYWORD\'; document.getElementById( \'srcTxtCell\' ).className = \'textInputCell\'; }" "type="text" class="textInput" name="keyword" value="  KEYWORD"></td></tr>' +
                              '<tr><td height="1px" colspan="2"></td></tr>' +
                              '<tr><td height="19" width="159" class="searchText">search</td><td><img src="/art/searchButton.gif" onclick="submitsearchform();"/></td></tr>' +
                            '</table>' +
                            '</form>' +
                    '</td></tr>' +
                    '</table>';

//values for drop downs
//browse
var BcategoryVal = -1;
var BdisciplineVal = -1;
//search
var compSizeVal = -1;
var jobTypeVal = -1;
var fileTypeVal = -1;
var categoryVal = -1;
var disciplineVal = -1;
var countryVal = -1;
var regionVal = -1;
var countyVal = -1;
var searchType = 'NONE';

function submitsearchform()
{
  populateSrchHiddens( document.forms[ 'search' ] );
  document.forms[ 'search' ].submit();
  hideSearchAnim();
  showSearchAnim();
}

function populateSrchHiddens( frm )
{
  frm.compsizeval.value = compSizeVal;
  frm.searchtype.value = searchType;
  frm.jobtypeval.value = jobTypeVal;
  frm.filetypeval.value = fileTypeVal;
  frm.categoryval.value = categoryVal;
  frm.disciplineval.value = disciplineVal;
  frm.countryval.value = countryVal;
  frm.regionval.value = regionVal;
  frm.countyval.value = countyVal;
}


//functions defining different search forms
function creativepeople()
{
  document.getElementById("searchPanel").innerHTML = textFill + '<tr><td height="1px"></td></tr><tr><td class="menuHeader">CREATIVE PEOPLE</td></tr>' + category + discipline + country + region + county + keywordSearch;
  searchType = 'creativepeople';
}
function creativecompanies()
{
  document.getElementById("searchPanel").innerHTML = textFill + '<tr><td height="1px"></td></tr><tr><td class="menuHeader">CREATIVE COMPANIES</td></tr>' + compSize + category + discipline + country + region + county + keywordSearch;
  searchType = 'creativecompanies';
}
function recruit()
{
  document.getElementById("searchPanel").innerHTML = textFill + '<tr><td height="1px"></td></tr><tr><td class="menuHeader">RECRUITMENT AGENCIES</td></tr>' + category + discipline + country + keywordSearch;
  searchType = 'recruit';
}
function jobs()
{
  document.getElementById("searchPanel").innerHTML = textFill + '<tr><td height="1px"></td></tr><tr><td class="menuHeader">JOB VACANCIES</td></tr>' + jobType + category + discipline + country + region + county + keywordSearch;
  searchType = 'jobs';
}
function publications()
{
  document.getElementById("searchPanel").innerHTML = textFill + '<tr><td height="1px"></td></tr><tr><td class="menuHeader">CREATIVE PUBLICATIONS</td></tr>' + category + discipline + country + keywordSearch;
  searchType = 'publications';
}
function organisations()
{
  document.getElementById("searchPanel").innerHTML = textFill + '<tr><td height="1px"></td></tr><tr><td class="menuHeader" style="font-size: 9px; padding-top: 4px">ART GROUPS / BODIES</td></tr>' + category + discipline + country + keywordSearch;
  searchType = 'organisations';
}
function courses()
{
  document.getElementById("searchPanel").innerHTML = textFill + '<tr><td height="1px"></td></tr><tr><td class="menuHeader">ART EDUCATION COURSES</td></tr>' + category + discipline + country + region + county + keywordSearch;
  searchType = 'courses';
}
function imgs()
{
  document.getElementById("searchPanel").innerHTML = textFill + '<tr><td height="1px"></td></tr><tr><td class="menuHeader">IMAGES / FILES</td></tr>' + fileType + category + discipline + keywordSearch;
  searchType = 'imgs';
}

var schTim = null;
function restartSearch()
{
  if( schTim != null )
  {
    clearTimeout( schTim );
  }

  hideSearchAnim();

  newSrcHtml  = '<table cellpadding="0" cellspacing="0">';
  newSrcHtml += '<tr><td class="searchPanelTop"></td></tr>';
  newSrcHtml += mkSrchBtn( 'creativepeople', 'CREATIVE PEOPLE' );
  newSrcHtml += mkSrchBtn( 'creativecompanies', 'CREATIVE COMPANIES' );
  newSrcHtml += mkSrchBtn( 'recruit', 'RECRUITMENT AGENCIES' );
  newSrcHtml += mkSrchBtn( 'jobs', 'JOB VACANCIES' );
  newSrcHtml += mkSrchBtn( 'publications', 'CREATIVE PUBLICATIONS' );
  newSrcHtml += mkSrchBtn( 'organisations', 'ART GROUPS / BODIES' );
  newSrcHtml += mkSrchBtn( 'courses', 'ART EDUCATION COURSES' );
  newSrcHtml += mkSrchBtn( 'imgs', 'IMAGES / FILES' );
//	newSrcHtml += '<tr><td height="1px"></td></tr>';
//	newSrcHtml += '<tr><td>';
//	newSrcHtml += '  <table cellpadding="0" cellspacing="0">';
//	newSrcHtml += '  <tr><td height="19" width="175" class="textInputCell" colspan="2">';
//	newSrcHtml += '  <input type="text" class="textInput"></td></tr>';
//	newSrcHtml += '  <tr><td height="19" width="159" class="searchText">SEARCH</td>';
//	newSrcHtml += '  <td><img SRC="/art/searchButton.gif">';
//	newSrcHtml += '  </td></tr>';
//	newSrcHtml += '  </table>';
//	newSrcHtml += '</td></tr>';
//	newSrcHtml += '</table>';

  var panel = document.getElementById("searchPanel");

  if( panel != null && typeof( panel ) != "undefined" )
  {
    panel.innerHTML = newSrcHtml;
  }
  else
  {
    schTim = setTimeout( 1000, "restartSearch()" );
  }

  compSizeVal = -1;
  jobTypeVal = -1;
  fileTypeVal = -1;
  categoryVal = -1;
  disciplineVal = -1;
  countryVal = -1;
  regionVal = -1;
  countyVal = -1;
  searchType = 'NONE';
}

function mkSrchBtn( srchFn, srchDesc )
{
  return '<tr><td height="1px"></td></tr><tr><td height="19" width="175" class="menuOption" onmouseover="this.className=\'menuOptionSelected\';" onmouseout="this.className=\'menuOption\';" onclick="' + srchFn + '();">' + srchDesc + '</td></tr>';
}









//DROPDOWN MENUS

function popmenu( menuName )
{

  if( dropDownShowing && lastDropDownName==menuName )
  {
    killDropDown();
  }
  else
  {

    //bespoke code for region and county
    if( ( menuName=='region' || menuName=='county' ) && countryVal != 1 )
    {
      if( countryVal == -1 )
        dispTxt = 'SELECT COUNTRY FIRST';
      else
      {
        if( menuName=='region' )
          dispTxt = 'NOT APPLICABLE';
        else
          dispTxt = 'NOT APPLICABLE';
      }

      if( dropDownShowing )
      {
        killDropDown();
      }
      orphanDisplay( menuName, dispTxt );
      return;
    }

    x=getlayerleft( menuName );
    y=getlayertop( menuName );
    dropDownBottomCoord = y;
    dropDownTopCoord = y;
    dropDownLeftCoord = x;
    dropDownRightCoord = x + 158;
    scrollYAtDDCreate = getpagescrolly();
    theArray = eval( menuName + 'Src' );
    parentNme = eval( menuName + 'Prnt' );

    if( !( typeof( parentNme ) == 'undefined' || parentNme==null ) )
    {

      parentVal = eval( parentNme + 'Val' );
      if( parentVal == -1 )
      {
        if( dropDownShowing )
        {
          killDropDown();
        }
        orphanDisplayText = parentNme.toUpperCase();
        if( orphanDisplayText == 'BCATEGORY' )
          orphanDisplayText = 'CATEGORY';  //botch cos all all browse identifiers are prefixed with a 'B'
        orphanDisplay( menuName, 'SELECT ' + orphanDisplayText + ' FIRST' );
        return;
      }
      theArray = theArray[ parentVal ];
    }

    dropDownCode =  '<table border="0" width="158" cellpadding="0" cellspacing="0" style="border-width:1px; border-color:#000000; border-style:solid;">';
    anyVal = eval( menuName + 'Any' );
    if( anyVal != null )
    {
      dropDownCode += ddRow( 'sctOtpn( -1 )', anyVal );
    }

    //company size specific code
    if( menuName=='compSize' )
    {
      dropDownCode += ddRow( 'sctOtpn( 0 )', 'Sole trader/Freelancer' );
    }

    if( menuName=='country' )
    { //company specific code
      dropDownCode += ctryLyr;
      dropDownBottomCoord += 47 * 13;
    }
    else
    {
      for( i=0 ; i < theArray.length ; i++ )
      {
        dropDownCode += ddRow( 'sctOtpn( ' + ( i + 1 ) + ' )', theArray[ i ] );
        dropDownBottomCoord += 13;
      }
    }
    dropDownCode += '</table>';

    movelayer(  'dropdownoptions', x , y+18 );
    dropDownBottomCoord += 18
    writelayer( 'dropdownoptions', dropDownCode );
    showlayer( 'dropdownoptions' );
    dropDownShowing = true;
    lastDropDownName = menuName;
    setDropDownScrollThreshold();

  }
}


function sctOtpn( idx )
{
  oldVal = eval( lastDropDownName + 'Val' );
  eval( lastDropDownName + 'Val = ' + idx );
  valArray    = eval( lastDropDownName + 'Src' );
  parentNme   = eval( lastDropDownName + 'Prnt' );
  if( !( typeof( parentNme ) == 'undefined' || parentNme==null ) )
  {
    parentVal = eval( parentNme + 'Val' );
    valArray  = valArray[ parentVal ];
  }
  childNme   = eval( lastDropDownName + 'Chld' );
  if( !( typeof( childNme ) == 'undefined' || childNme==null ) && oldVal != idx )
  {
    if( eval( childNme + 'Val' ) != -1 )
    {
      childVal  = eval( childNme + 'Slct' );
      writelayer( childNme + 'Cell', childVal );
      valElement  = document.getElementById( childNme + 'Cell' );
      valElement.className='menuOption';
      eval( childNme + 'Val = -1' );
    }
  }

  //country specific code
  if( lastDropDownName=='country' && oldVal != idx && idx != 1 )
  {
    if( countyVal != -1 )
    {
      writelayer( 'countyCell', 'SELECT COUNTY / UNIRATY' );
      valElement  = document.getElementById( 'countyCell' ).className='menuOption';
      countyVal = -1;
    }
    if( regionVal != -1 )
    {
      writelayer( 'regionCell', 'SELECT UK REGION' );
      valElement  = document.getElementById( 'regionCell' ).className='menuOption';
      regionVal = -1;
    }
  }

  desc='';
  clsNme='menuOption';
  if( idx > 0 )
  {
    desc   = valArray[ ( idx - 1 ) ];
    clsNme ='menuOptionOrange';
  }
  else
  {
    //used to be this code
    //desc = eval( lastDropDownName + 'Slct' );

    //now this code
    desc = eval( lastDropDownName + 'Any' );
    clsNme ='menuOptionOrange';
  }

  //company size specific code
  if( idx == 0 )
  {
    desc = 'Sole trader/Freelancer';
    clsNme ='menuOptionOrange';
  }


  writelayer( lastDropDownName + 'Cell', desc );
  valElement  = document.getElementById( lastDropDownName + 'Cell' );
  valElement.className=clsNme;

  killDropDown();

}

function sctCtry( letter )
{
    theArray = countrySrc;
    dropDownCode = '<table border="0" width="158" cellpadding="0" cellspacing="0" style="border-width:1px; border-color:#000000; border-style:solid;">';
    for( i=0 ; i < theArray.length ; i++ )
    {
      if( theArray[ i ].substring( 0, 1 ) == letter )
      {
        dropDownCode += ddRow( 'sctOtpn( ' + ( i + 1 ) + ' )', theArray[ i ] );
      }
    }
    dropDownCode += '</table>';
    writelayer( 'dropdownoptions', dropDownCode );
    window.scrollBy(0, scrollYAtDDCreate - scrollY );
}

var inFunc = false;

function getMouseXY(e)
{
//alert( 'move, x=' + e.pageX + ', y=' + e.pageY, 'dropDownBottomCoord=' + dropDownBottomCoord );
  //alert( dropDownShowing );
  if( dropDownShowing && !inFunc )
  {
    //alert( 'start' );
    if (IE)
    {
      tempX = event.clientX + document.body.scrollLeft;
      tempY = event.clientY + document.body.scrollTop;
    }
    else
    {
      tempX = e.pageX;
      tempY = e.pageY;
    }

    //see if mouse is no longer over drop down
    if( tempX > dropDownRightCoord + 35 || tempY > ( dropDownBottomCoord + 80 ) )
    {
//alert( 'gunnaKill, x=' + tempX + ', y=' + tempY, 'dropDownBottomCoord=' + dropDownBottomCoord );
      killDropDown();
      return;
    }

    //see if mouse is in scroll zone while not scrolling!
    if( !dropDownScrolling && tempY > dropDownScrollThresholdBottom && ( scrollY + wheight ) < ( dropDownBottomCoord + 1 ) )
    {
      dropDownScrolling = true;
      down( true, true );
    }

    if( !dropDownScrolling && tempY < dropDownScrollThresholdTop && scrollY > ( dropDownTopCoord + 1 ) )
    {
      dropDownScrolling = true;
      down( false, true );
    }
    //alert( 'end' );
  }

}

function killDropDown()
{
  hidelayer( 'dropdownoptions' );
  dropDownShowing = false;
  dropDownScrolling = false;
  //scroll back up to top of window if user has scrolled down
  window.scrollBy(0, scrollYAtDDCreate - scrollY );
}


function setDropDownScrollThreshold()
{
  scrollY = getpagescrolly();
  if( scrollY < 0 )
  {
    scrollY = 0;
  }
  wheight = getwindowheight();
  scrollAreaSize = 50;
  if( wheight < 110 )
  {
    scrollAreaSize = ( wheight - 10 ) / 2;
  }
  dropDownScrollThresholdBottom = scrollY + wheight - scrollAreaSize;
  dropDownScrollThresholdTop = scrollY + scrollAreaSize;

}

function dropDownScrollingChecks( v )
{
  if( dropDownScrolling )
  {
    setDropDownScrollThreshold();

    //see if mouse is in scroll zone!
    if( tempY > dropDownScrollThresholdBottom && tempY < dropDownBottomCoord )
    {
      //alert( 'calling down( true )' );
      down( v, true );
      dropDownScrolling = true;
      return;
    }
    if( tempY < dropDownScrollThresholdTop && tempY > dropDownTopCoord )
    {
      down( v, true );
      dropDownScrolling = true;
      return;
    }
    else
    {
      //end scrolling
      down( v, false );
      dropDownScrolling = false;
    }
  }
}


//scroll code
function scrollIt(v)
{
  //alert( v );
  if( scrollTimer && !dropDownScrolling )
  {
    clearInterval( scrollTimer );
    scrollTimer = null;
  }
  else
  {
    var direction=v?1:-1;
    var distance=13*direction;
    tempY += 13*direction;;
    window.scrollBy(0,distance);
    dropDownScrollingChecks( v );
  }
}

function down( directionDown, goNotStop )
{
  //alert( scrollTimer );
  if( scrollTimer )
  {
    clearInterval( scrollTimer );
    scrollTimer = null;
  }
  if( directionDown && dropDownScrolling && goNotStop )
   scrollTimer=setInterval("scrollIt(true)", 60 );
  if( !directionDown && dropDownScrolling && goNotStop )
   scrollTimer=setInterval("scrollIt(false)", 60 );
}

function orphanDisplay( menuName, menuDesc, stop )
{
//alert( 'menuName = ' + menuName + ', menuDesc = ' + menuDesc + ', stop = ' + stop );
  if( typeof( stop ) != 'undefined' )
  {
    clearInterval( orphanTimer );
    orphanTimer = null;
    writelayer( menuName + 'Cell', menuDesc );
  }
  else if( orphanTimer == null )
  {
    orphCell = document.getElementById( menuName + 'Cell' );
    //alert( "orphanDisplay('" + menuName + "', '" + orphCell.innerHTML + "' )" );
    orphanTimer = setInterval( "orphanDisplay('" + menuName + "', '" + orphCell.innerHTML + "', true )", 1000 );
    writelayer( menuName + 'Cell', menuDesc );
  }
}













//browse
function startBrowse()
{
  document.getElementById("browsePanel").innerHTML = '<table border="0" cellpadding="0" cellspacing="0">' + Bcategory + Bdiscipline + '</table>' +
  '<form name="browse" onsubmit="populateBrowseHiddens( this ); return true;" action="/servlet/Search" method="post">' +
  '<input type="hidden" name="formname" value="browse" />' +
  '<input type="hidden" name="categoryval" value="" />' +
  '<input type="hidden" name="disciplineval" value="" />' +
  '<table cellpadding="0" cellspacing="0">' +
  '<tr><td height="1px" colspan="2"></td></tr>' +
  '<tr><td height="19" width="159" class="searchText">go</td><td><input type="image" onclick="this.form.submit();" src="/art/searchButton.gif" /></td></tr>' +
  '</table>' +
  '</form>';
}


function populateBrowseHiddens( frm )
{
  frm.categoryval.value = BcategoryVal;
  frm.disciplineval.value = BdisciplineVal;
}



//search anim gif layer
function showSearchAnim()
{
  var srchAnim = getElt( 'searchinganim' );

  if( srchAnim != null && typeof( srchAnim ) != "undefined" && typeof( srchAnim.style ) != "undefined" )
  {
    getElt( 'searchinganim' ).style.display = "block";
  }
}

function hideSearchAnim()
{
  var srchAnim = getElt( 'searchinganim' );

  if( srchAnim != null && typeof( srchAnim ) != "undefined" && typeof( srchAnim.style ) != "undefined" )
  {
    srchAnim.style.display = "none";
  }
  //hidelayer( 'searchinganim' );
}




//news
var newsHangerX;
var newsHangerY;
var newsOffset=0;
var newsScrollPix;
var newsScrollFreq;
var newsTimer = null;
var newsHeight;
var newsWindowWidth = 146;
var newsWindowHeight = 155;
var newsScrolling = true;



function initialise( reasonForCall )
{

  newsHangerX = getlayerleft( 'newsHanger' );
  if( reasonForCall=='load' )
  {
    newsHeight = getlayerheight( 'newsScrollLayer' );
    newsLayer = getElt( 'newsScrollLayer' );
    newsLayer.innerHTML = newsLayer.innerHTML + newsLayer.innerHTML;
    newsHangerY = getlayertop( 'newsHanger' );
    newsOffset=0;

    specialOfferLayer = getElt( 'specialOffer' )
    if( typeof( specialOfferLayer ) != 'undefined' && specialOfferLayer != null )
    {
      //show special offer banner if there is one for 5 seconds
      movelayer( 'specialOffer', getlayerleft( 'mainPage' ) + 72, 300 );
      showlayer( 'specialOffer' );
      killOffer = setTimeout( "hidelayer( 'specialOffer' );", 8000 );
    }
  }

  movelayer(  'newsScrollLayer', newsHangerX , newsHangerY-newsOffset );

  if( reasonForCall=='load' )
  {
//alert( 'about to show news layer' );
    showlayer(  'newsScrollLayer' );
//alert( 'showed news layer' );
    newsNormal();
  }

  if( reasonForCall=='load' && typeof( startSlideshow ) != 'undefined' && fadeimages.length > 0 )
  {
    startSlideshow();
  }

  positionSeperatorBottoms();

  if( reasonForCall=='load' )
  {
    //preload Images
    for( i=0 ; i < preloadImagePaths.length ; i++ )
    {
      preloadedImages[ i ].src = preloadImagePaths[ i ];
    }

    x=getlayerleft( "searchPanel" );
    y=getlayertop( "searchPanel" ) + 30;
    w=getlayerwidth( "searchPanel" );
    h=getlayerheight( "searchPanel" ) - 30;

    sizelayer( 'searchinganim', w, h );
    //writelayer( 'searchinganim', '<table border="0" cellpadding="0" cellspacing="0" width="' + w + '" height="' + h + '"><tr><td valign="middle" style="text-align: center; background-color: #888888; vertical-align: middle"><img id="srchFrmAnimGif" width="96" height="96" src="' + preloadedImages[ 1 ].src + '" /></td></tr></table>' );
    movelayer( 'searchinganim', x, y );
    //getElt( 'srchFrmAnimGif' ).src = preloadedImages[ 1 ].src;


  }

}

function positionNews()
{
//alert( 'starting function, newsTimer = ' + newsTimer );
  if( newsTimer )
  {
    clearInterval( newsTimer );
    newsTimer = null;
  }
//  alert( 'killed timer , newsTimer = ' + newsTimer );

  newsOffset += newsScrollPix;
//  alert( 'increased offset; newsHeight = ' + newsHeight + ', newsOffset = ' + newsOffset +', newsScrollPix = ' + newsScrollPix + ', newsHeight = ' + newsHeight );
  if( newsOffset > newsHeight )
    newsOffset -= newsHeight;
  else if( newsOffset < 0 )
    newsOffset += newsHeight;
//  alert( 'after resetscrollcheck newsOffset = ' + newsOffset );


//alert( 'about to move to offset of' + newsOffset );
  movelayer(  'newsScrollLayer', newsHangerX , newsHangerY-newsOffset );
//alert( 'moved, about to clip to 0, ' + newsWindowWidth + ', ' + newsOffset + ', ' + (newsOffset+newsWindowHeight) );
  cliplayer( 'newsScrollLayer', 0, newsWindowWidth, newsOffset, newsOffset+newsWindowHeight );
//alert( 'clipped, about to set next interval' );

  newsTimer = setInterval("positionNews()", newsScrollFreq );
//alert( 'set next interval' );

}



function newsUpFast( )
{
  newsScrollPix = 3;
  newsScrollFreq = 30;
  positionNews();
}

function newsDownFast( )
{
  newsScrollPix = -3;
  newsScrollFreq = 30;
  positionNews();
}


function newsNormal( )
{
  newsScrollPix = 1;
  newsScrollFreq = 200;
  positionNews();
}

function newsStop( )
{
  clearInterval( newsTimer );
  newsTimer = null;
}





function checkLoginForm()
{
  if( document.forms[ 'login' ].elements[ 'email' ].value == '' || document.forms[ 'login' ].elements[ 'passwd' ].value == '' )
  {
    alert( 'Please enter your username and password to login' );
    return false;
  }
  else
  {
    return true;
  }
}



function positionSeperatorBottoms()
{
  y=getlayertop( "footer" );
  sepLyrCntt = '<table cellpadding="0" cellspacing="0" width="1" height="600"><tr><td width="1" height="600" bgcolor="#D0D0D0"></td></tr></table>';

  for( i=1 ; i<=4 ; i++ )
  {
    x=getlayerleft( 'sep' + i );
    movelayer( 'sepLyr' + i, x, y-600 );
    writelayer( 'sepLyr' + i, sepLyrCntt );
    showlayer( 'sepLyr' + i );
  }
}