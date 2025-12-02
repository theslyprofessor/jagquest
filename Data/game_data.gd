extends Node
# JagQuest Game Data - SWC Chula Vista Campus
# Based on official campus map: https://www.swccd.edu/about-swc/campus-maps-and-directions/chula-vista-campus/_files/chula-vista-campus-map.pdf
# Grid system: A-H (columns), 1-8 (rows)

# =============================================================================
# ENUMS
# =============================================================================
enum EntityType {
	BUILDING,
	PROGRAM,
	PERSON,
	DEPARTMENT,
	RESOURCE
}

enum ActionType {
	NAVIGATE,      # Move player to location in overworld (default for all)
	TELEPORT,      # Teleport inside a room/building interior
	SHOW_INFO      # Just show info panel (resources, URLs)
}

# =============================================================================
# GRID COORDINATE SYSTEM
# The campus map uses a grid: columns A-H, rows 1-8
# We convert to normalized coordinates (0-1) for flexible positioning
# =============================================================================
const GRID_COLUMNS = ["A", "B", "C", "D", "E", "F", "G", "H"]
const GRID_ROWS = [1, 2, 3, 4, 5, 6, 7, 8]

# Convert grid location (e.g., "C5") to normalized Vector2 (0-1 range)
static func grid_to_position(grid: String) -> Vector2:
	if grid.length() < 2:
		return Vector2(0.5, 0.5)
	
	var col = grid[0].to_upper()
	var row_str = grid.substr(1)
	var row = int(row_str) if row_str.is_valid_int() else 5
	
	var col_index = GRID_COLUMNS.find(col)
	if col_index == -1:
		col_index = 3  # Default to middle
	
	# Map to 0-1 range with some padding
	var x = (col_index + 0.5) / float(GRID_COLUMNS.size())
	var y = (row - 0.5) / float(GRID_ROWS.size())
	
	return Vector2(x, y)

# =============================================================================
# SCHOOLS (SWC has 7 schools)
# =============================================================================
const SCHOOLS: Dictionary = {
	"acdm": {
		"id": "acdm",
		"name": "School of Arts, Communication, Design and Media",
		"short_name": "ACDM",
		"grid_location": "C5",
		"building_id": "87",
		"office": "87-109",
		"phone": "(619) 482-6372",
		"website": "https://www.swccd.edu/academics/schools-centers-departments/school-of-arts-communication-design-media/"
	},
	"applied-tech": {
		"id": "applied-tech",
		"name": "School of Applied Technology & Hospitality Management",
		"short_name": "Applied Tech",
		"grid_location": "E5",
		"building_id": "59A",
		"office": "59A-101F",
		"phone": "",
		"website": ""
	},
	"business": {
		"id": "business",
		"name": "School of Business",
		"short_name": "Business",
		"grid_location": "B7",
		"building_id": "25",
		"office": "25-115",
		"phone": "",
		"website": ""
	},
	"counseling": {
		"id": "counseling",
		"name": "School of Counseling and Student Support Programs",
		"short_name": "Counseling",
		"grid_location": "C6",
		"building_id": "68",
		"office": "68-204",
		"phone": "",
		"website": ""
	},
	"education": {
		"id": "education",
		"name": "School of Education, Humanities, Social and Behavioral Sciences",
		"short_name": "Education & Humanities",
		"grid_location": "B7",
		"building_id": "24",
		"office": "24-217",
		"phone": "",
		"website": ""
	},
	"languages": {
		"id": "languages",
		"name": "School of Languages and Literature",
		"short_name": "Languages & Literature",
		"grid_location": "D7",
		"building_id": "28",
		"office": "28-107",
		"phone": "",
		"website": ""
	},
	"math-science": {
		"id": "math-science",
		"name": "School of Mathematics, Science and Engineering",
		"short_name": "Math & Science",
		"grid_location": "D4",
		"building_id": "60",
		"office": "60-125",
		"phone": "",
		"website": ""
	},
	"wellness": {
		"id": "wellness",
		"name": "School of Wellness, Exercise Science and Athletics",
		"short_name": "Wellness & Athletics",
		"grid_location": "C3",
		"building_id": "71",
		"office": "71-401",
		"phone": "",
		"website": ""
	}
}

# =============================================================================
# CAMPUS BUILDINGS (from official map)
# Only includes actual buildings from the PDF, not fake ones
# =============================================================================
const BUILDINGS: Dictionary = {
	# === STUDENT SERVICES ===
	"68": {
		"id": "68",
		"name": "Cesar E. Chavez Student Services Center",
		"short_name": "Student Services (68)",
		"grid_location": "C6",
		"description": "Main student services hub: Admissions, Financial Aid, Counseling, Career Center, and more.",
		"departments": ["Admissions and Records", "Financial Aid", "Counseling", "Career Center", "DSS", "EOPS", "CalWORKs"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"67": {
		"id": "67",
		"name": "Student Union",
		"short_name": "Student Union (67)",
		"grid_location": "C5",
		"description": "Student activities, health services, food hall, meditation space, and veterans services.",
		"departments": ["ASO", "Health and Wellness", "Food Hall", "Veterans Services", "SWC Cares"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	
	# === LIBRARY & ACADEMIC SUPPORT ===
	"64": {
		"id": "64",
		"name": "Learning Resource Center / Library",
		"short_name": "Library (64)",
		"grid_location": "C4",
		"description": "Library, tutoring, online learning center, and instructional support.",
		"departments": ["Library", "Online Learning Center", "Instructional Support"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"26": {
		"id": "26",
		"name": "Academic Success Center",
		"short_name": "Success Center (26)",
		"grid_location": "D7",
		"description": "Reading lab, writing center, tutoring, Dreamer Center, and DSS High Tech Center.",
		"departments": ["Reading Lab", "Writing Center", "Dreamer Center", "DSS High Tech Center"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	
	# === ACDM SCHOOL BUILDINGS ===
	"87": {
		"id": "87",
		"name": "ACDM Building",
		"short_name": "ACDM (87)",
		"grid_location": "C5",
		"description": "School of Arts, Communication, Design and Media main office. Visual arts programs.",
		"school_id": "acdm",
		"programs": ["architecture", "art", "cad"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"88": {
		"id": "88",
		"name": "Art Gallery",
		"short_name": "Art Gallery (88)",
		"grid_location": "C5",
		"description": "SWC Art Gallery featuring student and professional exhibitions.",
		"school_id": "acdm",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"84": {
		"id": "84",
		"name": "Recording Arts & Technology",
		"short_name": "Recording Arts (84)",
		"grid_location": "C5",
		"description": "Professional recording studios, control rooms, and audio production facilities for the RA&T program.",
		"school_id": "acdm",
		"programs": ["recording-arts"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"80": {
		"id": "80",
		"name": "Performing Arts Center",
		"short_name": "Performing Arts (80)",
		"grid_location": "A3",
		"description": "Main performance venue for theatre, dance, and music concerts.",
		"school_id": "acdm",
		"programs": ["theatre", "dance", "music"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"57A": {
		"id": "57A",
		"name": "Communication Building",
		"short_name": "Communication (57A)",
		"grid_location": "E5",
		"description": "Communication studies, journalism, and The SWC Sun student newspaper.",
		"school_id": "acdm",
		"programs": ["communication", "journalism"],
		"departments": ["The SWC Sun"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	
	# === SCIENCE & MATH ===
	"60": {
		"id": "60",
		"name": "Math & Science Building",
		"short_name": "Math & Science (60)",
		"grid_location": "D4",
		"description": "STEM programs, laboratories, Math Center, and MESA Center.",
		"school_id": "math-science",
		"departments": ["Math Center", "MESA Center"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	
	# === BUSINESS & EDUCATION ===
	"24": {
		"id": "24",
		"name": "Instructional & Discovery Complex - West",
		"short_name": "IDC West (24)",
		"grid_location": "B7",
		"description": "Education, Humanities, and Social Sciences. University Center.",
		"school_id": "education",
		"departments": ["University Center"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"25": {
		"id": "25",
		"name": "Instructional & Discovery Complex - East",
		"short_name": "IDC East (25)",
		"grid_location": "B7",
		"description": "School of Business, Language Acquisition Center, Planetarium.",
		"school_id": "business",
		"departments": ["Language Acquisition Center", "Planetarium"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"28": {
		"id": "28",
		"name": "Languages & Literature Building",
		"short_name": "Languages (28)",
		"grid_location": "D7",
		"description": "School of Languages and Literature main office.",
		"school_id": "languages",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	
	# === ATHLETICS & WELLNESS ===
	"70": {
		"id": "70",
		"name": "Jaguar Aquatics Wellness and Sports (JAWS)",
		"short_name": "JAWS / Gymnasium (70)",
		"grid_location": "B3",
		"description": "Gymnasium, aquatics center, fitness facilities.",
		"school_id": "wellness",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"71": {
		"id": "71",
		"name": "DeVore Stadium / Athletics",
		"short_name": "Athletics (71)",
		"grid_location": "C3",
		"description": "DeVore Stadium and School of Wellness, Exercise Science and Athletics.",
		"school_id": "wellness",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"79": {
		"id": "79",
		"name": "Tennis Center",
		"short_name": "Tennis (79)",
		"grid_location": "G5",
		"description": "Tennis courts and facilities.",
		"school_id": "wellness",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	
	# === APPLIED TECHNOLOGY ===
	"59A": {
		"id": "59A",
		"name": "Applied Technology Building",
		"short_name": "Applied Tech (59A)",
		"grid_location": "E5",
		"description": "School of Applied Technology, Continuing Education, Traffic School, Youth Programs.",
		"school_id": "applied-tech",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"47A": {
		"id": "47A",
		"name": "Automotive Technology",
		"short_name": "Automotive (47A)",
		"grid_location": "E6",
		"description": "Automotive technology program facilities.",
		"school_id": "applied-tech",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"56A": {
		"id": "56A",
		"name": "Bookstore",
		"short_name": "Bookstore (56A)",
		"grid_location": "D5",
		"description": "Campus bookstore for textbooks, supplies, and SWC merchandise.",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	
	# === ADMINISTRATION ===
	"12": {
		"id": "12",
		"name": "Administration Building",
		"short_name": "Administration (12)",
		"grid_location": "B6",
		"description": "Academic Affairs, Foundation, Advancement and Community Engagement.",
		"departments": ["Academic Affairs", "Foundation"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"22": {
		"id": "22",
		"name": "College Police",
		"short_name": "Police (22)",
		"grid_location": "C8",
		"description": "Campus police and lost & found.",
		"departments": ["College Police", "Lost and Found"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"46A": {
		"id": "46A",
		"name": "Financial Services",
		"short_name": "Financial Services (46A)",
		"grid_location": "F6",
		"description": "Financial Services and Payroll.",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"46B": {
		"id": "46B",
		"name": "Business and Operations",
		"short_name": "Business Ops (46B)",
		"grid_location": "E7",
		"description": "Business and Operations, Human Resources.",
		"departments": ["Human Resources"],
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	"99": {
		"id": "99",
		"name": "Child Development Center",
		"short_name": "Child Dev (99)",
		"grid_location": "H6",
		"description": "Child Development Center for students with children.",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	},
	
	# === BOTANICAL GARDEN ===
	"40-46": {
		"id": "40-46",
		"name": "SWC Botanical Garden",
		"short_name": "Botanical Garden",
		"grid_location": "F6",
		"description": "Southwestern College Botanical Garden and Landscape/Nursery Technology program.",
		"entity_type": EntityType.BUILDING,
		"action_type": ActionType.NAVIGATE
	}
}

# =============================================================================
# ACDM PROGRAMS - All 12 programs with accurate naming
# =============================================================================
const PROGRAMS: Dictionary = {
	# =========================================================================
	# VISUAL ARTS DEPARTMENT
	# =========================================================================
	"architecture": {
		"id": "architecture",
		"name": "Architecture",
		"department": "Visual Arts",
		"department_id": "visual-arts",
		"building_id": "87",
		"default_room": "87-201",
		"awards": 5,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/architecture/index.aspx",
		"catalog_pages": [
			{"name": "Architecture - AS", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/architecture-as/"},
			{"name": "Architectural Design Technology", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/architectural-design-technology/"},
			{"name": "Building Information Modeling", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/building-information-modeling/"},
			{"name": "Green Architecture", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/green-architecture/"},
			{"name": "Sustainable Building Design & Construction", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/sustainable-building-design-construction/"}
		],
		"description": "Explore architectural design, drafting, and building technology. Learn to create innovative designs that shape our built environment.",
		"theme_color": Color(0.2, 0.4, 0.6),
		"program_lead": null,
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	"art": {
		"id": "art",
		"name": "Art",
		"department": "Visual Arts",
		"department_id": "visual-arts",
		"building_id": "87",
		"default_room": "87-202",
		"awards": 5,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/art/index.aspx",
		"catalog_pages": [
			{"name": "Art - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/art-aa/"},
			{"name": "Art History - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/art-history-aa/"},
			{"name": "Ceramics", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/ceramics/"},
			{"name": "Drawing & Painting", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/drawing-painting/"},
			{"name": "Sculpture", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/sculpture/"}
		],
		"description": "Develop your artistic vision through drawing, painting, sculpture, ceramics, and digital media.",
		"theme_color": Color(0.8, 0.2, 0.4),
		"program_lead": null,
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	"cad": {
		"id": "cad",
		"name": "Computer Aided Design & Drafting (CADD)",
		"department": "Visual Arts",
		"department_id": "visual-arts",
		"building_id": "87",
		"default_room": "87-203",
		"awards": 3,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/computer-aided-design-and-drafting/index.aspx",
		"catalog_pages": [
			{"name": "Computer Aided Design & Drafting - AS", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/computer-aided-design-drafting/computer-aided-design-drafting-as/"},
			{"name": "Architectural Drafting", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/computer-aided-design-drafting/architectural-drafting/"},
			{"name": "Civil Drafting Technology", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/computer-aided-design-drafting/civil-drafting-technology/"}
		],
		"description": "Learn industry-standard CAD software and technical drafting for engineering and design applications.",
		"theme_color": Color(0.3, 0.5, 0.3),
		"program_lead": null,
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	
	# =========================================================================
	# COMMUNICATION DEPARTMENT
	# =========================================================================
	"communication": {
		"id": "communication",
		"name": "Communication",
		"department": "Communication",
		"department_id": "communication",
		"building_id": "57A",
		"default_room": "57A-101",
		"awards": 1,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/communication/index.aspx",
		"catalog_pages": [
			{"name": "Communication - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/communication/communication-aa/"}
		],
		"description": "Master effective communication in interpersonal, organizational, and mass media contexts.",
		"theme_color": Color(0.3, 0.6, 0.8),
		"program_lead": null,
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	"film": {
		"id": "film",
		"name": "Film, Television & Media Arts (FTMA)",
		"department": "Communication",
		"department_id": "communication",
		"building_id": "84",
		"default_room": "84-101",
		"awards": 3,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/film-television-and-media-arts/index.aspx",
		"catalog_pages": [
			{"name": "Film, Television & Media Arts - AS", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/film-television-media-arts/film-television-media-arts-as/"},
			{"name": "Cinematography", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/film-television-media-arts/cinematography/"},
			{"name": "Video & Audio Production", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/film-television-media-arts/video-audio-production/"}
		],
		"description": "Learn filmmaking, video production, and media storytelling for screen and digital platforms.",
		"theme_color": Color(0.1, 0.1, 0.1),
		"program_lead": null,
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	"journalism": {
		"id": "journalism",
		"name": "Journalism",
		"department": "Communication",
		"department_id": "communication",
		"building_id": "57A",
		"default_room": "57A-104",
		"awards": 1,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/journalism/index.aspx",
		"catalog_pages": [
			{"name": "Journalism - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/journalism/journalism-aa/"}
		],
		"description": "Develop reporting, writing, and multimedia storytelling skills for print and digital journalism.",
		"theme_color": Color(0.2, 0.2, 0.3),
		"program_lead": {
			"id": "max-branscomb",
			"name": "Max Branscomb",
			"title": "Professor",
			"email": "mbranscomb@swccd.edu",
			"phone": "(619) 421-6700 x5701",
			"office": "57A-104",
			"contact_url": "https://go.swccd.edu/contact/person/33a8f74bdb7fa6005e33f8fdae9619f5"
		},
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	"recording-arts": {
		"id": "recording-arts",
		"name": "Recording Arts & Technology (RA&T)",
		"department": "Communication",
		"department_id": "communication",
		"building_id": "84",
		"default_room": "84-110",
		"awards": 2,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/recording-arts-and-technology/index.aspx",
		"catalog_pages": [
			{"name": "Recording Arts & Technology - AS", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/recording-arts-technology/recording-arts-technology-as/"},
			{"name": "Recording Arts & Technology Certificate", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/recording-arts-technology/recording-arts-technology/"}
		],
		"description": "Master audio recording, mixing, production, and sound design in professional studio environments.",
		"theme_color": Color(0.6, 0.2, 0.8),
		"program_lead": {
			"id": "nakul-tiruviluamala",
			"name": "Nakul Tiruviluamala",
			"title": "Assistant Professor",
			"email": "ntiruviluamala@swccd.edu",
			"phone": "(619) 421-6700 x5377",
			"office": "84-110",
			"contact_url": "https://go.swccd.edu/contact/person/8a27ea911b4a741036c0a685624bcb5a"
		},
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	
	# =========================================================================
	# PERFORMING ARTS DEPARTMENT
	# =========================================================================
	"dance": {
		"id": "dance",
		"name": "Dance",
		"department": "Performing Arts",
		"department_id": "performing-arts",
		"building_id": "80",
		"default_room": "80-101",
		"awards": 1,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/dance/index.aspx",
		"catalog_pages": [
			{"name": "Dance - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/dance/dance-aa/"}
		],
		"description": "Explore movement, choreography, and performance through various dance styles.",
		"theme_color": Color(0.9, 0.5, 0.6),
		"program_lead": null,
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	"music": {
		"id": "music",
		"name": "Music",
		"department": "Performing Arts",
		"department_id": "performing-arts",
		"building_id": "80",
		"default_room": "80-201",
		"awards": 6,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/music/index.aspx",
		"catalog_pages": [
			{"name": "Music - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/music-aa/"},
			{"name": "Music Performance - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/music-performance-aa/"},
			{"name": "Applied Music: Instrumental", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/applied-music-instrumental/"},
			{"name": "Applied Music: Piano", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/applied-music-piano/"},
			{"name": "Applied Music: Voice", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/applied-music-voice/"},
			{"name": "Music Technology", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/music-technology/"}
		],
		"description": "Study music theory, performance, composition, and music history.",
		"theme_color": Color(0.8, 0.6, 0.2),
		"program_lead": null,
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	"theatre": {
		"id": "theatre",
		"name": "Theatre Arts",
		"department": "Performing Arts",
		"department_id": "performing-arts",
		"building_id": "80",
		"default_room": "80-301",
		"awards": 3,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/theatre-arts/index.aspx",
		"catalog_pages": [
			{"name": "Theatre Arts - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/theatre-arts/theatre-arts-aa/"},
			{"name": "Acting", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/theatre-arts/acting/"},
			{"name": "Technical Theatre", "type": "Certificate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/theatre-arts/technical-theatre/"}
		],
		"description": "Explore acting, directing, stagecraft, and theatrical production.",
		"theme_color": Color(0.5, 0.1, 0.2),
		"program_lead": {
			"id": "erika-behrmann",
			"name": "Erika Behrmann",
			"title": "Professor",
			"email": "ebehrmann@swccd.edu",
			"phone": "(619) 421-6700 x5585",
			"office": "35-125",
			"contact_url": "https://go.swccd.edu/contact/person/df39038bdb86109074e1d411ce961901"
		},
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	
	# =========================================================================
	# HUMANITIES (Part of ACDM)
	# =========================================================================
	"liberal-arts": {
		"id": "liberal-arts",
		"name": "Liberal Arts Areas of Emphasis",
		"department": "Humanities",
		"department_id": "humanities",
		"building_id": "24",
		"default_room": "24-101",
		"awards": 3,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/liberal-arts/index.aspx",
		"catalog_pages": [
			{"name": "Liberal Arts: Arts & Humanities - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/liberal-arts/liberal-arts-arts-humanities-aa/"},
			{"name": "Liberal Arts: General Studies - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/liberal-arts/liberal-arts-general-studies-aa/"},
			{"name": "Liberal Arts: Language & Rationality - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/liberal-arts/liberal-arts-language-rationality-aa/"}
		],
		"description": "Pursue a broad-based education with emphasis areas aligned with your interests and transfer goals.",
		"theme_color": Color(0.4, 0.3, 0.5),
		"program_lead": null,
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	},
	"mexican-american-studies": {
		"id": "mexican-american-studies",
		"name": "Mexican American Studies",
		"department": "Humanities",
		"department_id": "humanities",
		"building_id": "24",
		"default_room": "24-102",
		"awards": 1,
		"program_page": "https://www.swccd.edu/programs-and-academics/programs/mexican-american-studies/index.aspx",
		"catalog_pages": [
			{"name": "Mexican American Studies - AA", "type": "Associate", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/mexican-american-studies/mexican-american-studies-aa/"}
		],
		"description": "Study Mexican American history, culture, literature, and contributions to society.",
		"theme_color": Color(0.6, 0.3, 0.2),
		"program_lead": null,
		"entity_type": EntityType.PROGRAM,
		"action_type": ActionType.NAVIGATE
	}
}

# =============================================================================
# ACDM STAFF - Key Personnel
# =============================================================================
const STAFF: Dictionary = {
	"dean": {
		"id": "dean",
		"name": "Diana Arredondo",
		"title": "Interim Dean",
		"role": "dean",
		"department": "School of Arts, Communication, Design & Media",
		"email": "darredondo@swccd.edu",
		"phone": "(619) 482-6371",
		"office": "87-110",
		"building_id": "87",
		"grid_location": "C5",
		"contact_url": "https://go.swccd.edu/contact/person/8cb83b4bdb7fa6005e33f8fdae961955",
		"entity_type": EntityType.PERSON,
		"action_type": ActionType.NAVIGATE
	},
	"counselor": {
		"id": "counselor",
		"name": "Adriana Garibay",
		"title": "ACDM Counselor",
		"role": "counselor",
		"department": "School of Arts, Communication, Design & Media",
		"email": "agaribay@swccd.edu",
		"phone": "(619) 421-6700 x5434",
		"office": "68-205D",
		"building_id": "68",
		"grid_location": "C6",
		"contact_url": "https://www.swccd.edu/_showcase/directory/person/adriana-garibay/",
		"entity_type": EntityType.PERSON,
		"action_type": ActionType.NAVIGATE
	},
	"success_coach": {
		"id": "success_coach",
		"name": "Omar Alvarez Espinosa",
		"title": "Field of Study Success Coach",
		"role": "success_coach",
		"department": "School of Arts, Communication, Design & Media",
		"email": "oalvarez-espinosa@swccd.edu",
		"phone": "(619) 421-6700 x5136",
		"office": "68-206",
		"building_id": "68",
		"grid_location": "C6",
		"contact_url": "https://go.swccd.edu/contact/person/ebf8b1361b103150e253ece5624bcb66",
		"entity_type": EntityType.PERSON,
		"action_type": ActionType.NAVIGATE
	},
	"receptionist": {
		"id": "receptionist",
		"name": "Eileen Zwiereski",
		"title": "Administrative Secretary II",
		"role": "admin",
		"department": "School of Arts, Communication, Design & Media",
		"email": "ezwierski@swccd.edu",
		"phone": "(619) 482-6441",
		"office": "87-109A",
		"building_id": "87",
		"grid_location": "C5",
		"contact_url": "https://www.swccd.edu/_showcase/directory/person/ewa-zwierski/",
		"entity_type": EntityType.PERSON,
		"action_type": ActionType.NAVIGATE
	}
}

# =============================================================================
# DEPARTMENTS (ACDM internal organization)
# =============================================================================
const DEPARTMENTS: Dictionary = {
	"visual-arts": {
		"id": "visual-arts",
		"name": "Visual Arts",
		"programs": ["architecture", "art", "cad"],
		"chair": null,
		"entity_type": EntityType.DEPARTMENT
	},
	"communication": {
		"id": "communication",
		"name": "Communication",
		"programs": ["communication", "film", "journalism", "recording-arts"],
		"chair": null,
		"entity_type": EntityType.DEPARTMENT
	},
	"performing-arts": {
		"id": "performing-arts",
		"name": "Performing Arts",
		"programs": ["dance", "music", "theatre"],
		"chair": null,
		"entity_type": EntityType.DEPARTMENT
	},
	"humanities": {
		"id": "humanities",
		"name": "Humanities",
		"programs": ["liberal-arts", "mexican-american-studies"],
		"chair": null,
		"entity_type": EntityType.DEPARTMENT
	}
}

# =============================================================================
# CAMPUS RESOURCES
# =============================================================================
const RESOURCES: Dictionary = {
	"personal-wellness": {
		"id": "personal-wellness",
		"name": "Personal Wellness & Mental Health",
		"building_id": "67",
		"office": "67-153",
		"grid_location": "C5",
		"phone": "(619) 421-6700 x5495",
		"url": "https://www.swccd.edu/student-support/health-services/personal-wellness-mental-health/index.aspx",
		"description": "Free confidential mental health counseling and wellness resources for all SWC students.",
		"entity_type": EntityType.RESOURCE,
		"action_type": ActionType.SHOW_INFO
	}
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Get all searchable entities for JagGenie
static func get_all_entities() -> Array:
	var entities: Array = []
	
	# Add buildings
	for key in BUILDINGS:
		var building = BUILDINGS[key].duplicate(true)
		building["search_type"] = "building"
		# Calculate position from grid
		building["map_position"] = grid_to_position(building.get("grid_location", "D4"))
		entities.append(building)
	
	# Add programs
	for key in PROGRAMS:
		var program = PROGRAMS[key].duplicate(true)
		program["search_type"] = "program"
		# Get position from building
		var building_id = program.get("building_id", "")
		if BUILDINGS.has(building_id):
			program["map_position"] = grid_to_position(BUILDINGS[building_id].get("grid_location", "D4"))
			program["grid_location"] = BUILDINGS[building_id].get("grid_location", "")
		entities.append(program)
	
	# Add staff
	for key in STAFF:
		var person = STAFF[key].duplicate(true)
		person["search_type"] = "person"
		person["map_position"] = grid_to_position(person.get("grid_location", "D4"))
		entities.append(person)
	
	# Add resources
	for key in RESOURCES:
		var resource = RESOURCES[key].duplicate(true)
		resource["search_type"] = "resource"
		resource["map_position"] = grid_to_position(resource.get("grid_location", "D4"))
		entities.append(resource)
	
	return entities

# Get entities at a specific grid location (for shared location handling)
static func get_entities_at_grid(grid_location: String) -> Array:
	var entities: Array = []
	var all_entities = get_all_entities()
	
	for entity in all_entities:
		if entity.get("grid_location", "") == grid_location:
			entities.append(entity)
	
	return entities

# Get program by ID
static func get_program(program_id: String) -> Dictionary:
	if PROGRAMS.has(program_id):
		var program = PROGRAMS[program_id].duplicate(true)
		var building_id = program.get("building_id", "")
		if BUILDINGS.has(building_id):
			program["map_position"] = grid_to_position(BUILDINGS[building_id].get("grid_location", "D4"))
			program["grid_location"] = BUILDINGS[building_id].get("grid_location", "")
		return program
	return {}

# Get building by ID
static func get_building(building_id: String) -> Dictionary:
	if BUILDINGS.has(building_id):
		var building = BUILDINGS[building_id].duplicate(true)
		building["map_position"] = grid_to_position(building.get("grid_location", "D4"))
		return building
	return {}

# Get staff member by ID
static func get_staff(staff_id: String) -> Dictionary:
	if STAFF.has(staff_id):
		return STAFF[staff_id].duplicate(true)
	return {}

# Get programs in a building
static func get_programs_in_building(building_id: String) -> Array:
	var programs: Array = []
	for key in PROGRAMS:
		if PROGRAMS[key]["building_id"] == building_id:
			programs.append(PROGRAMS[key].duplicate(true))
	return programs

# Get programs in a department
static func get_programs_in_department(department_id: String) -> Array:
	var programs: Array = []
	for key in PROGRAMS:
		if PROGRAMS[key]["department_id"] == department_id:
			programs.append(PROGRAMS[key].duplicate(true))
	return programs

# Get the map position for an entity
static func get_entity_position(entity: Dictionary) -> Vector2:
	# First check if entity has direct grid_location
	var grid = entity.get("grid_location", "")
	if not grid.is_empty():
		return grid_to_position(grid)
	
	# Then check building
	var building_id = entity.get("building_id", "")
	if not building_id.is_empty() and BUILDINGS.has(building_id):
		return grid_to_position(BUILDINGS[building_id].get("grid_location", "D4"))
	
	return Vector2(0.5, 0.5)

# Fuzzy search for JagGenie
static func fuzzy_search(query: String) -> Array:
	var results: Array = []
	var query_lower = query.to_lower()
	
	var all_entities = get_all_entities()
	for entity in all_entities:
		var name_lower = entity.get("name", "").to_lower()
		var short_name_lower = entity.get("short_name", "").to_lower()
		var matches = false
		
		# Check name and short name
		if name_lower.contains(query_lower) or short_name_lower.contains(query_lower):
			matches = true
		
		# Check building ID for buildings
		if entity.get("id", "").to_lower().contains(query_lower):
			matches = true
		
		# Check department name for programs
		if entity.get("department", "").to_lower().contains(query_lower):
			matches = true
		
		# Check title for people
		if entity.get("title", "").to_lower().contains(query_lower):
			matches = true
		
		# Check grid location
		if entity.get("grid_location", "").to_lower() == query_lower:
			matches = true
		
		if matches:
			results.append(entity)
	
	# Sort by relevance
	results.sort_custom(func(a, b):
		var a_name = a.get("name", "").to_lower()
		var b_name = b.get("name", "").to_lower()
		var a_exact = a_name == query_lower or a.get("short_name", "").to_lower() == query_lower
		var b_exact = b_name == query_lower or b.get("short_name", "").to_lower() == query_lower
		
		if a_exact and not b_exact:
			return true
		if b_exact and not a_exact:
			return false
		
		# Priority: programs > buildings > people > resources
		var type_priority = {"program": 0, "building": 1, "person": 2, "resource": 3}
		var a_priority = type_priority.get(a.get("search_type", ""), 4)
		var b_priority = type_priority.get(b.get("search_type", ""), 4)
		if a_priority != b_priority:
			return a_priority < b_priority
		
		return a_name < b_name
	)
	
	return results

# Get catalog pages for a program
static func get_program_catalog_pages(program_id: String) -> Array:
	var program = get_program(program_id)
	return program.get("catalog_pages", [])

# Get program lead info
static func get_program_lead(program_id: String) -> Dictionary:
	var program = get_program(program_id)
	var lead = program.get("program_lead", null)
	if lead != null:
		return lead
	return {}
