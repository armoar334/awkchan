function set_grabber() {
	if ( system("command -v curl") == 0 ) { grabber = "curl " }
	else if ( system("command -v wget") == 0 ) { grabber = "wget -O " }
	else if ( system("ape/sh -c 'command -v hget'") == 0 ) ( grabber = "hget " )
	else {
		print("No web grabber installed!")
		print("Get wget or curl and come back then")
		exit 1;
	}
}

function newline(		temp) {
	#temp = sprintf("%*s", depth, "")
	#gsub(" ", "\t", temp)
	printf("\n%*s", depth * 2, "")
}

function json_parse() {
	raw = ""
	cmd = grabber url
	while ( ( cmd | getline record ) > 0 ) {
		raw = raw record
	}
	close(cmd)
	#print(length(raw))
	split(raw, all, "")
	depth = 0
	done = ""
	for ( number in all ) {
		if ( all[number] == "{" ) { depth += 1; done = done "{" }
		else if ( all[number] == "[" ) { depth += 1; done = done "[" }
		else if ( all[number] == "}" ) { depth -= 1; done = done "}" }
		else if ( all[number] == "]" ) { depth -= 1; done = done "]" }
		else if ( depth >= 5 ) { printf("") } # So we dont get any replies, just parents
		else if ( all[number] == "," ) { done = done "," }
		else { done = done all[number] }
	}
	gsub(/},{/, "}\n{", done)
	printf("%s\n", done)
}

BEGIN {
	set_grabber()
	printf("%s", "Enter a board (g/b/an, etc): ")
	getline board
	printf("%s", "Enter a thread, or leave empty for catalog")
	getline thread

	if ( board == "" ) {
		print("You gotta put a board in")
		exit 1;
	}
	else if ( thread == "" ) {
		url = "https://a.4cdn.org/" board "/catalog.json"
	}
	else {
		url = "https://a.4cdn.org/" board "/thread/" thread ".json"
	}
	json_parse()
}
