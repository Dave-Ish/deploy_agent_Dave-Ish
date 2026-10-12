#!/usr/bin/env bash

# ==============================================================================
# ALU STUDENT ATTENDANCE DEPLOYMENT AGENT
# Features: 1. Deploy & Verify | 2. Run App | 3. Archive Operational Logs
# Signal Handling: Traps SIGINT and SIGTSTP during deployment phase
# ==============================================================================

# Global Configurations
TEMPLATES_DIR ="tamplates"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

#Declaring the signal trap function

interruptor_fu(){
	echo -e "\n\n/!\The system interrupted by the user (SIGINT/SIGSTP)"
	if [ -not -z "$PROJECT_DIR"] && [ -d "$PROJECT_DIR" ]; then
		echo "Wait.., Creating safety archive of incomplete workspace"
		zip -r "${PROJECT_DIR}_archive.zip" "$PROJECT_DIR"> /dev/null 2>$1
		echo "Cleaning up incomplete files to prevent clutter: $PROJECT_DIR"
		rm -rf "$PROJECT_DIR"
	fi
	echo "successfully cleaned, session closed. Exiting"
	exit 1 
}

# feature 1: deploy the application 

deploy_app(){
	echo "Running environment pre-flight validation..."
	# the checker

	if ! command -v python3 &> /dev/null; then
		echo "error: Python3 is not installed or valialbe in PATH. Abortring. " >&2
		exit 1
	fi
	
	if  ! command -v zip &> /dell/null; then 
		echo "error: Zip utility not installed. Aborting"
		exit 1
	fi
	echo "Environment validation passed successfully ($(python3 --version))"
	

#The project directory definition
	read -p "Enter a unique name for your project directory: " DIR_INPUT
	if [ -z "$DIR_INPUT"]; then
		echo "error: Directory name cannot be empty." &2
		exit 1
	fi
	
	PROJECT_DIR = "attendance_tracker_${DIR_INPUT}"
	
	#handling redundance and conflic
	if [ -d "$PROJECT_DIR" ]; then
		read -p "/!\ given directory already exists. Overwrite it? (Y/N): " OVERWRITE

		if [[ ! "$OVERWRITE" =~ ^[yY]$ ]]
; then
			echo " Aborting deployment by user to prevent the file loss.
			exit 1
		fi
		rm -rf "$PROJECT_DIR"
	fi

# activating traps for the build segment
	
	
	trap interruptor_fu SIGINT SIGSTP
	
	echo "Initializing project filesystem structure..."
	mkdir -p"$PROJECT_DIR"
	mkdir -p"$PROJECT_DIR/Helpers"
	mkdir -p"$PROJECT_DIR/reports"
	mkdir -p"$PROJECT_DIR/archives/attendance"
	mkdir -p"$PROJECT_DIR/arhives/abasent" 
	
# the simulated  5sec delay to test trap mechnism
	echo "Copying engine components (press Ctrl+C now to test signal clean up frame work)..."
	sleep 5
#copying the engine base files
	cp "$TEMPLATES_DIR/attendance_checker.py" "$PROJECT_DIR/"
	cp "$TEMPLATES_DIR/ config.json" "$PROJECT_DIR/Helpers/"
#Creating the roster logic

	echo "Select a Roster Generation Strategy: "
	echo "  A) Import and slice from existing information"
	echo "  B) Generate clear start datasete (0 historical counts)"
	read -p "Selection (A/B): " ROSTER_OPT
	if [[ "$ROSTER_OPT" =~ ^[Aa]$ ]]; then
		read -p "How many student records do you like to import (1 - 10)?" ROSTER_COUNT

		if ! [[ "$ROSTER_COUNT" =~ ^[0-9]+$ ]] || [ "$ROSTER_COUNT" -lt 1 ] || [ "$ROSTER_COUNT" -gt 10 ]; then
        	    echo "[-] Invalid integer. Defaulting import slice to 5."
            	    ROSTER_COUNT=5
	        fi
# Keep header row, then append selected row limit
	        head -n 1 "$TEMPLATES_DIR/assets.csv" > "$PROJECT_DIR/Helpers/assets.csv"
        	tail -n +2 "$TEMPLATES_DIR/assets.csv" | head -n "$ROSTER_COUNT" >> "$PROJECT_DIR/Helpers/assets.csv"
        
# Set template total sessions default logic
        	sed -i 's/"total_sessions": [0-9]*/"total_sessions": 5/g' "$PROJECT_DIR/Helpers/config.json"
	elif [[ "$ROSTER_OPT" =~ ^[Bb]$ ]]; then
        	read -p "How many students to generate? " GEN_COUNT
        	if ! [[ "$GEN_COUNT" =~ ^[0-9]+$ ]] || [ "$GEN_COUNT" -lt 1 ]; then
            		echo "[-] Invalid configuration value. Defaulting generation to 3."
            		GEN_COUNT=3
        	fi
        
        # Fresh array mappings
        	NAMES=("Alex Mwangi" "Bella Keza" "Chris Ntaganda" "Diana Umutoni" "Eric Simba")
        	EMAILS=("alex@example.com" "bella@example.com" "chris@example.com" "diana@example.com" "eric@example.com")
        
		echo "Email,Names,Attendance Count,Absence Count" > "$PROJECT_DIR/Helpers/assets.csv"
        	for ((i=0; i<GEN_COUNT; i++)); do
            		idx=$((i % 5))
        # Append unique identifiers if exceeding static array bounds
            		if [ $i -ge 5 ]; then
                	echo "${i}_${EMAILS[$idx]},${NAMES[$idx]} $i,0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
            		else
                	echo "${EMAILS[$idx]},${NAMES[$idx]},0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
            		fi
        	done
        # Fresh system starts at target session 1
        sed -i 's/"total_sessions": [0-9]*/"total_sessions": 1/g' "$PROJECT_DIR/Helpers/config.json"
    	else
        echo "[-] Unrecognized pipeline path selected. Aborting installation."
        rm -rf "$PROJECT_DIR"
        exit 1
    fi

# tobe continued... (The applicatio permission & governancesection)
