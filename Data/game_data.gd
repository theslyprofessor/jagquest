extends Node
# JagQuest Game Data - Converted from acdm-school-game
# Auto-generated from schools.js, programs.js, directory.json

# =============================================================================
# ENTITY TYPES (for icons and JagGenie filtering)
# =============================================================================
enum EntityType {
	BUILDING,
	PROGRAM,
	PERSON,
	OFFICE,
	DEPARTMENT
}

# =============================================================================
# CAMPUS BUILDINGS - Geographic positions on SWC Chula Vista campus map
# Based on: https://www.swccd.edu/about-swc/campus-maps-and-directions/chula-vista-campus/_files/chula-vista-campus-map.pdf
# =============================================================================
# Coordinates are normalized (0-1) relative to campus map image
# Will be scaled to actual pixel positions in Overworld scene

const BUILDINGS: Dictionary = {
	# === ACDM BUILDINGS ===
	"87": {
		"id": "87",
		"name": "ACDM Building",
		"full_name": "Arts, Communication, Design & Media",
		"map_position": Vector2(0.72, 0.45),  # East-central campus
		"description": "Home of the School of Arts, Communication, Design & Media",
		"programs": ["architecture", "art", "cad", "graphic-design"],
		"offices": ["87-109A", "87-110"],
		"entity_type": EntityType.BUILDING
	},
	"84": {
		"id": "84",
		"name": "Recording Arts Building",
		"full_name": "Recording Arts & Technology",
		"map_position": Vector2(0.68, 0.42),
		"description": "Recording studios and audio production facilities",
		"programs": ["recording-arts"],
		"offices": ["84-110"],
		"entity_type": EntityType.BUILDING
	},
	"57A": {
		"id": "57A",
		"name": "Journalism Building",
		"full_name": "Communication Arts",
		"map_position": Vector2(0.55, 0.50),
		"description": "Journalism and communication studies",
		"programs": ["journalism", "communication"],
		"offices": ["57A-104"],
		"entity_type": EntityType.BUILDING
	},
	"35": {
		"id": "35",
		"name": "Performing Arts Building",
		"full_name": "Mayan Hall - Performing Arts",
		"map_position": Vector2(0.45, 0.55),
		"description": "Theatre, dance, and performance spaces",
		"programs": ["theatre", "dance"],
		"offices": [],
		"entity_type": EntityType.BUILDING
	},
	"83": {
		"id": "83",
		"name": "Music Building",
		"full_name": "Music Department",
		"map_position": Vector2(0.70, 0.48),
		"description": "Music practice rooms, ensemble halls, and studios",
		"programs": ["music"],
		"offices": [],
		"entity_type": EntityType.BUILDING
	},
	"85": {
		"id": "85",
		"name": "Film & Media Building",
		"full_name": "Film, Television & Media Arts",
		"map_position": Vector2(0.66, 0.44),
		"description": "Film production studios and editing suites",
		"programs": ["film"],
		"offices": [],
		"entity_type": EntityType.BUILDING
	},
	# === OTHER CAMPUS BUILDINGS ===
	"68": {
		"id": "68",
		"name": "Student Services",
		"full_name": "Student Services Building",
		"map_position": Vector2(0.40, 0.35),
		"description": "Counseling, admissions, financial aid",
		"programs": [],
		"offices": ["68-204", "68-205D", "68-206"],
		"entity_type": EntityType.BUILDING
	},
	"24": {
		"id": "24",
		"name": "Humanities Building",
		"full_name": "Education, Humanities, Social & Behavioral Sciences",
		"map_position": Vector2(0.35, 0.45),
		"description": "Liberal arts and humanities programs",
		"programs": ["liberal-arts", "mexican-american-studies"],
		"offices": ["24-217"],
		"entity_type": EntityType.BUILDING
	},
	"25": {
		"id": "25",
		"name": "Business Building",
		"full_name": "School of Business",
		"map_position": Vector2(0.38, 0.40),
		"description": "Business and economics programs",
		"programs": [],
		"offices": ["25-115"],
		"entity_type": EntityType.BUILDING
	},
	"60": {
		"id": "60",
		"name": "Science Building",
		"full_name": "Mathematics, Science & Engineering",
		"map_position": Vector2(0.50, 0.30),
		"description": "STEM programs and laboratories",
		"programs": [],
		"offices": ["60-125"],
		"entity_type": EntityType.BUILDING
	}
}

# =============================================================================
# ACDM PROGRAMS - With correct building assignments
# =============================================================================
const PROGRAMS: Dictionary = {
	"architecture": {
		"id": "architecture",
		"name": "Architecture",
		"department": "Visual Arts",
		"building_id": "87",
		"room": "87-201",
		"awards": 5,
		"degrees": [
			{"type": "Associate", "name": "Architecture - AS", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/architecture-as/"},
			{"type": "Certificate", "name": "Architectural Design Technology", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/architectural-design-technology/"},
			{"type": "Certificate", "name": "Building Information Modeling", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/building-information-modeling/"},
			{"type": "Certificate", "name": "Green Architecture", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/green-architecture/"},
			{"type": "Certificate", "name": "Sustainable Building Design & Construction", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/architecture/sustainable-building-design-construction/"}
		],
		"description": "Explore architectural design, drafting, and building technology. Learn to create innovative designs that shape our built environment.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/architecture/",
		"theme_color": Color(0.2, 0.4, 0.6),  # Blueprint blue
		"icon": "architecture",
		"entity_type": EntityType.PROGRAM
	},
	"art": {
		"id": "art",
		"name": "Art",
		"department": "Visual Arts",
		"building_id": "87",
		"room": "87-202",
		"awards": 5,
		"degrees": [
			{"type": "Associate", "name": "Art - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/art-aa/"},
			{"type": "Associate", "name": "Art History - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/art-history-aa/"},
			{"type": "Certificate", "name": "Ceramics", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/ceramics/"},
			{"type": "Certificate", "name": "Drawing & Painting", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/drawing-painting/"},
			{"type": "Certificate", "name": "Sculpture", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/art/sculpture/"}
		],
		"description": "Develop your artistic vision through drawing, painting, sculpture, and digital media. Express yourself through various artistic mediums.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/art/",
		"theme_color": Color(0.8, 0.2, 0.4),  # Artistic magenta
		"icon": "art",
		"entity_type": EntityType.PROGRAM
	},
	"communication": {
		"id": "communication",
		"name": "Communication",
		"department": "Communication",
		"building_id": "57A",
		"room": "57A-101",
		"awards": 2,
		"degrees": [
			{"type": "Associate", "name": "Communication - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/communication/communication-aa/"}
		],
		"description": "Master the art of effective communication in interpersonal, organizational, and mass media contexts.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/communication/",
		"theme_color": Color(0.3, 0.6, 0.8),  # Communication blue
		"icon": "communication",
		"entity_type": EntityType.PROGRAM
	},
	"film": {
		"id": "film",
		"name": "Film, Television & Media Arts",
		"department": "Communication",
		"building_id": "85",
		"room": "85-101",
		"awards": 3,
		"degrees": [
			{"type": "Associate", "name": "Film, Television & Media Arts - AS", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/film-television-media-arts/film-television-media-arts-as/"},
			{"type": "Certificate", "name": "Cinematography", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/film-television-media-arts/cinematography/"},
			{"type": "Certificate", "name": "Video & Audio Production", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/film-television-media-arts/video-audio-production/"}
		],
		"description": "Learn filmmaking, video production, and media storytelling. Create compelling visual narratives for screen and digital platforms.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/film/",
		"theme_color": Color(0.1, 0.1, 0.1),  # Cinema black
		"icon": "film",
		"entity_type": EntityType.PROGRAM
	},
	"journalism": {
		"id": "journalism",
		"name": "Journalism",
		"department": "Communication",
		"building_id": "57A",
		"room": "57A-104",
		"awards": 2,
		"degrees": [
			{"type": "Associate", "name": "Journalism - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/journalism/journalism-aa/"}
		],
		"description": "Develop reporting, writing, and multimedia storytelling skills for print and digital journalism.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/journalism/",
		"theme_color": Color(0.2, 0.2, 0.3),  # Newsprint gray
		"icon": "journalism",
		"entity_type": EntityType.PROGRAM,
		"program_lead": {
			"name": "Max Branscomb",
			"title": "Professor",
			"email": "mbranscomb@swccd.edu",
			"phone": "(619) 421-6700 x5701",
			"office": "57A-104"
		}
	},
	"recording-arts": {
		"id": "recording-arts",
		"name": "Recording Arts & Technology",
		"department": "Communication",
		"building_id": "84",
		"room": "84-110",
		"awards": 2,
		"degrees": [
			{"type": "Associate", "name": "Recording Arts & Technology - AS", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/recording-arts-technology/recording-arts-technology-as/"},
			{"type": "Certificate", "name": "Recording Arts & Technology", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/recording-arts-technology/recording-arts-technology/"}
		],
		"description": "Master audio recording, mixing, production, and sound design in professional studio environments.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/recording-arts/",
		"theme_color": Color(0.6, 0.2, 0.8),  # Audio purple
		"icon": "recording-arts",
		"entity_type": EntityType.PROGRAM,
		"program_lead": {
			"name": "Nakul Tiruviluamala",
			"title": "Assistant Professor",
			"email": "ntiruviluamala@swccd.edu",
			"phone": "(619) 421-6700 x5377",
			"office": "84-110"
		}
	},
	"dance": {
		"id": "dance",
		"name": "Dance",
		"department": "Performing Arts",
		"building_id": "35",
		"room": "35-101",
		"awards": 1,
		"degrees": [
			{"type": "Associate", "name": "Dance - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/dance/dance-aa/"}
		],
		"description": "Explore movement, choreography, and performance through various dance styles and techniques.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/dance/",
		"theme_color": Color(0.9, 0.5, 0.6),  # Dance pink
		"icon": "dance",
		"entity_type": EntityType.PROGRAM
	},
	"music": {
		"id": "music",
		"name": "Music",
		"department": "Performing Arts",
		"building_id": "83",
		"room": "83-101",
		"awards": 6,
		"degrees": [
			{"type": "Associate", "name": "Music - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/music-aa/"},
			{"type": "Associate", "name": "Music Performance - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/music-performance-aa/"},
			{"type": "Certificate", "name": "Applied Music: Instrumental", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/applied-music-instrumental/"},
			{"type": "Certificate", "name": "Applied Music: Piano", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/applied-music-piano/"},
			{"type": "Certificate", "name": "Applied Music: Voice", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/applied-music-voice/"},
			{"type": "Certificate", "name": "Music Technology", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/music/music-technology/"}
		],
		"description": "Study music theory, performance, composition, and music history. Develop your musical skills and artistic expression.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/music/",
		"theme_color": Color(0.8, 0.6, 0.2),  # Golden music
		"icon": "music",
		"entity_type": EntityType.PROGRAM
	},
	"theatre": {
		"id": "theatre",
		"name": "Theatre Arts",
		"department": "Performing Arts",
		"building_id": "35",
		"room": "35-102",
		"awards": 3,
		"degrees": [
			{"type": "Associate", "name": "Theatre Arts - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/theatre-arts/theatre-arts-aa/"},
			{"type": "Certificate", "name": "Acting", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/theatre-arts/acting/"},
			{"type": "Certificate", "name": "Technical Theatre", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/theatre-arts/technical-theatre/"}
		],
		"description": "Explore acting, directing, stagecraft, and theatrical production. Bring stories to life on stage.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/theatre/",
		"theme_color": Color(0.5, 0.1, 0.2),  # Theatre red
		"icon": "theatre",
		"entity_type": EntityType.PROGRAM
	},
	"cad": {
		"id": "cad",
		"name": "Computer Aided Design & Drafting",
		"department": "Applied Technologies",
		"building_id": "87",
		"room": "87-203",
		"awards": 3,
		"degrees": [
			{"type": "Associate", "name": "Computer Aided Design & Drafting - AS", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/computer-aided-design-drafting/computer-aided-design-drafting-as/"},
			{"type": "Certificate", "name": "Architectural Drafting", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/computer-aided-design-drafting/architectural-drafting/"},
			{"type": "Certificate", "name": "Civil Drafting Technology", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/computer-aided-design-drafting/civil-drafting-technology/"}
		],
		"description": "Learn industry-standard CAD software and technical drafting techniques for engineering and design applications.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/cad/",
		"theme_color": Color(0.3, 0.5, 0.3),  # CAD green
		"icon": "cad",
		"entity_type": EntityType.PROGRAM
	},
	"liberal-arts": {
		"id": "liberal-arts",
		"name": "Liberal Arts Areas of Emphasis",
		"department": "Humanities",
		"building_id": "24",
		"room": "24-101",
		"awards": 3,
		"degrees": [
			{"type": "Associate", "name": "Liberal Arts: Arts & Humanities - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/liberal-arts/liberal-arts-arts-humanities-aa/"},
			{"type": "Associate", "name": "Liberal Arts: General Studies - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/liberal-arts/liberal-arts-general-studies-aa/"},
			{"type": "Associate", "name": "Liberal Arts: Language & Rationality - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/liberal-arts/liberal-arts-language-rationality-aa/"}
		],
		"description": "Pursue a broad-based education with emphasis areas aligned with your interests and transfer goals.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/liberal-arts/",
		"theme_color": Color(0.4, 0.3, 0.5),  # Liberal arts purple
		"icon": "liberal-arts",
		"entity_type": EntityType.PROGRAM
	},
	"mexican-american-studies": {
		"id": "mexican-american-studies",
		"name": "Mexican American Studies",
		"department": "Humanities",
		"building_id": "24",
		"room": "24-102",
		"awards": 1,
		"degrees": [
			{"type": "Associate", "name": "Mexican American Studies - AA", "url": "https://catalog.swccd.edu/associate-degree-certificate-programs/mexican-american-studies/mexican-american-studies-aa/"}
		],
		"description": "Study Mexican American history, culture, and contributions to society.",
		"learn_more_url": "https://www.swccd.edu/academics/programs/mexican-american-studies/",
		"theme_color": Color(0.6, 0.3, 0.2),  # Terracotta
		"icon": "mexican-american-studies",
		"entity_type": EntityType.PROGRAM
	}
}

# =============================================================================
# ACDM STAFF - Key personnel
# =============================================================================
const STAFF: Dictionary = {
	"dean": {
		"id": "dean",
		"name": "Diana Arredondo",
		"title": "Interim Dean",
		"department": "School of Arts, Communication, Design & Media",
		"email": "darredondo@swccd.edu",
		"phone": "(619) 482-6371",
		"office": "87-110",
		"building_id": "87",
		"contact_url": "https://www.swccd.edu/_showcase/directory/person/diana-arredondo/",
		"entity_type": EntityType.PERSON
	},
	"counselor": {
		"id": "counselor",
		"name": "Adriana Garibay",
		"title": "Counselor",
		"department": "School of Arts, Communication, Design & Media",
		"email": "agaribay@swccd.edu",
		"phone": "(619) 421-6700 x5434",
		"office": "68-205D",
		"building_id": "68",
		"contact_url": "https://www.swccd.edu/_showcase/directory/person/adriana-garibay/",
		"entity_type": EntityType.PERSON
	},
	"success_coach": {
		"id": "success_coach",
		"name": "Omar Alvarez Espinosa",
		"title": "Field of Study Success Coach",
		"department": "School of Arts, Communication, Design & Media",
		"email": "oalvarez-espinosa@swccd.edu",
		"phone": "(619) 421-6700 x5136",
		"office": "68-206",
		"building_id": "68",
		"contact_url": "https://www.swccd.edu/_showcase/directory/person/omar-alvarez-espinosa/",
		"entity_type": EntityType.PERSON
	},
	"receptionist": {
		"id": "receptionist",
		"name": "Eileen Zwiereski",
		"title": "Administrative Secretary II",
		"department": "School of Arts, Communication, Design & Media",
		"email": "ezwierski@swccd.edu",
		"phone": "(619) 482-6441",
		"office": "87-109A",
		"building_id": "87",
		"contact_url": "https://www.swccd.edu/_showcase/directory/person/ewa-zwierski/",
		"entity_type": EntityType.PERSON
	}
}

# =============================================================================
# DEPARTMENTS
# =============================================================================
const DEPARTMENTS: Dictionary = {
	"visual-arts": {
		"id": "visual-arts",
		"name": "Visual Arts",
		"programs": ["architecture", "art"],
		"entity_type": EntityType.DEPARTMENT
	},
	"communication": {
		"id": "communication",
		"name": "Communication",
		"programs": ["communication", "film", "journalism", "recording-arts"],
		"entity_type": EntityType.DEPARTMENT
	},
	"performing-arts": {
		"id": "performing-arts",
		"name": "Performing Arts",
		"programs": ["dance", "music", "theatre"],
		"entity_type": EntityType.DEPARTMENT
	},
	"applied-technologies": {
		"id": "applied-technologies",
		"name": "Applied Technologies",
		"programs": ["cad"],
		"entity_type": EntityType.DEPARTMENT
	},
	"humanities": {
		"id": "humanities",
		"name": "Humanities",
		"programs": ["liberal-arts", "mexican-american-studies"],
		"entity_type": EntityType.DEPARTMENT
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
		var building = BUILDINGS[key].duplicate()
		building["search_type"] = "building"
		entities.append(building)
	
	# Add programs
	for key in PROGRAMS:
		var program = PROGRAMS[key].duplicate()
		program["search_type"] = "program"
		entities.append(program)
	
	# Add staff
	for key in STAFF:
		var person = STAFF[key].duplicate()
		person["search_type"] = "person"
		entities.append(person)
	
	return entities

# Get program by ID
static func get_program(program_id: String) -> Dictionary:
	if PROGRAMS.has(program_id):
		return PROGRAMS[program_id]
	return {}

# Get building by ID
static func get_building(building_id: String) -> Dictionary:
	if BUILDINGS.has(building_id):
		return BUILDINGS[building_id]
	return {}

# Get programs in a building
static func get_programs_in_building(building_id: String) -> Array:
	var programs: Array = []
	for key in PROGRAMS:
		if PROGRAMS[key]["building_id"] == building_id:
			programs.append(PROGRAMS[key])
	return programs

# Fuzzy search for JagGenie
static func fuzzy_search(query: String) -> Array:
	var results: Array = []
	var query_lower = query.to_lower()
	
	var all_entities = get_all_entities()
	for entity in all_entities:
		var name_lower = entity["name"].to_lower()
		if name_lower.contains(query_lower) or query_lower in name_lower:
			results.append(entity)
	
	# Sort by relevance (exact matches first)
	results.sort_custom(func(a, b):
		var a_exact = a["name"].to_lower() == query_lower
		var b_exact = b["name"].to_lower() == query_lower
		if a_exact and not b_exact:
			return true
		if b_exact and not a_exact:
			return false
		return a["name"] < b["name"]
	)
	
	return results
