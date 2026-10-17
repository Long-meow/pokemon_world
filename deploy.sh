#!/usr/bin/env bash
# ==============================================================================
# Assignment: DBI202 - Assignment 2 (Pokémon World Database )
# File:       deploy.sh
# Purpose:    Production-grade automated deployment runner script.
#             Sequentially deploys the complete 9-file SQL suite against the
#             Docker SQL Server container 'sqlserver' and validates test_all.sql.
# Target:     Docker SQL Server 2022 (Container: sqlserver)
# Author:     Automated Verification & Deployment Specialist (Worker M3)
# ==============================================================================

set -Eeuo pipefail

# ------------------------------------------------------------------------------
# 1. ENVIRONMENT CONFIGURATION & SAFE DEFAULTS
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONTAINER_NAME="${CONTAINER_NAME:-sqlserver}"
DB_HOST="${DB_HOST:-localhost}"
DB_USER="${DB_USER:-sa}"
DB_PASSWORD="${DB_PASSWORD:-YourPassword@123}"
SQLCMD_BIN="${SQLCMD_BIN:-/opt/mssql-tools18/bin/sqlcmd}"

# Color codes for terminal output
if [[ -t 1 ]]; then
    COLOR_RESET="\033[0m"
    COLOR_BOLD="\033[1m"
    COLOR_GREEN="\033[32m"
    COLOR_CYAN="\033[36m"
    COLOR_YELLOW="\033[33m"
    COLOR_RED="\033[31m"
else
    COLOR_RESET=""
    COLOR_BOLD=""
    COLOR_GREEN=""
    COLOR_CYAN=""
    COLOR_YELLOW=""
    COLOR_RED=""
fi

# ------------------------------------------------------------------------------
# 2. LOGGING & ERROR TRAPPING UTILITIES
# ------------------------------------------------------------------------------
log_info() {
    printf "${COLOR_CYAN}[INFO] %s | %s${COLOR_RESET}\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

log_step() {
    printf "${COLOR_BOLD}${COLOR_YELLOW}[STEP %s/%s] %s | %s${COLOR_RESET}\n" "$1" "$2" "$(date +'%Y-%m-%d %H:%M:%S')" "$3"
}

log_success() {
    printf "${COLOR_GREEN}[SUCCESS] %s | %s${COLOR_RESET}\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$*"
}

log_error() {
    printf "${COLOR_RED}[ERROR] %s | %s${COLOR_RESET}\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$*" >&2
}

error_trap() {
    local exit_code=$?
    local line_num=$1
    local command="${2:-unknown}"
    log_error "Deployment failed with exit code ${exit_code} at line ${line_num} while executing: '${command}'"
    exit "${exit_code}"
}

trap 'error_trap $LINENO "$BASH_COMMAND"' ERR

# ------------------------------------------------------------------------------
# 3. PRE-FLIGHT VALIDATION CHECKS
# ------------------------------------------------------------------------------
log_info "=================================================="
log_info " Pokémon World Database Automated Deployment "
log_info " Container: ${CONTAINER_NAME} | Host: ${DB_HOST}:${DB_USER}"
log_info " Directory: ${SCRIPT_DIR}"
log_info "=================================================="

# Check 1: Docker CLI availability
if ! command -v docker >/dev/null 2>&1; then
    log_error "Command 'docker' not found on host. Please install or add Docker to PATH."
    exit 1
fi

# Check 2: Docker container running status
if ! docker inspect -f '{{.State.Running}}' "${CONTAINER_NAME}" 2>/dev/null | grep -q "true"; then
    log_error "Docker container '${CONTAINER_NAME}' is not running or does not exist."
    exit 1
fi
log_info "Docker container '${CONTAINER_NAME}' is active and running."

# Check 3: SQL Server readiness check
log_info "Verifying SQL Server database engine connectivity..."
docker exec -i "${CONTAINER_NAME}" \
    "${SQLCMD_BIN}" \
    -S "${DB_HOST}" \
    -U "${DB_USER}" \
    -P "${DB_PASSWORD}" \
    -C -b \
    -d master \
    -Q "SET NOCOUNT ON; SELECT 'CONNECT_OK' AS Status;" >/dev/null

log_info "SQL Server connectivity confirmed."

# Check 4: Verify existence and non-zero size of all 9 SQL scripts
declare -a REQUIRED_FILES=(
    "createDB.sql"
    "constraints.sql"
    "insert.sql"
    "views.sql"
    "function.sql"
    "trigger.sql"
    "procedure.sql"
    "queries.sql"
    "test_all.sql"
)

for file in "${REQUIRED_FILES[@]}"; do
    file_path="${SCRIPT_DIR}/${file}"
    if [[ ! -f "${file_path}" ]]; then
        log_error "Required script '${file_path}' does not exist!"
        exit 1
    fi
    if [[ ! -s "${file_path}" ]]; then
        log_error "Required script '${file_path}' is empty (0 bytes)!"
        exit 1
    fi
done
log_info "All 9 deployment script files verified in ${SCRIPT_DIR}."

# ------------------------------------------------------------------------------
# 4. SEQUENTIAL DEPLOYMENT EXECUTION
# ------------------------------------------------------------------------------
TOTAL_STEPS=9

# Helper function to execute a SQL script via containerized sqlcmd
execute_step() {
    local step_num="$1"
    local db_name="$2"
    local sql_file="$3"
    local description="$4"
    local sql_path="${SCRIPT_DIR}/${sql_file}"

    log_step "${step_num}" "${TOTAL_STEPS}" "Deploying ${sql_file} (${description}) -> Database: [${db_name}]"
    
    docker exec -i "${CONTAINER_NAME}" \
        "${SQLCMD_BIN}" \
        -S "${DB_HOST}" \
        -U "${DB_USER}" \
        -P "${DB_PASSWORD}" \
        -C -b \
        -d "${db_name}" \
        < "${sql_path}"

    log_success "Step ${step_num}/${TOTAL_STEPS} completed: ${sql_file} applied cleanly."
    printf "\n"
}

START_TIME=$(date +%s)

# Step 1: createDB.sql on database 'master'
execute_step 1 "master" "createDB.sql" "Recreates database pokemon_world & 7 tables with PKs"

# Step 2: constraints.sql on database 'pokemon_world'
execute_step 2 "pokemon_world" "constraints.sql" "Applies 8 FKs, 4 CHECKs, 5 UNIQUEs"

# Step 3: insert.sql on database 'pokemon_world'
execute_step 3 "pokemon_world" "insert.sql" "Seeds 50 Pokemon and >= 10 rows per table"

# Step 4: views.sql on database 'pokemon_world'
execute_step 4 "pokemon_world" "views.sql" "Creates vw_TrainerParty & vw_PokedexProgress"

# Step 5: function.sql on database 'pokemon_world'
execute_step 5 "pokemon_world" "function.sql" "Creates scalar function fn_GetPokemonTotalStats"

# Step 6: trigger.sql on database 'pokemon_world'
execute_step 6 "pokemon_world" "trigger.sql" "Creates AFTER trigger TR_OwnedPokemon_CheckLevel"

# Step 7: procedure.sql on database 'pokemon_world'
execute_step 7 "pokemon_world" "procedure.sql" "Creates transactional procedure usp_CatchPokemon"

# Step 8: queries.sql on database 'pokemon_world'
execute_step 8 "pokemon_world" "queries.sql" "Executes 10 functional business queries"

# Step 9: test_all.sql on database 'pokemon_world'
execute_step 9 "pokemon_world" "test_all.sql" "Executes end-to-end automated verification suite"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# ------------------------------------------------------------------------------
# 5. FINAL DEPLOYMENT REPORT & SUMMARY
# ------------------------------------------------------------------------------
log_info "=================================================="
log_success "ALL 9 DEPLOYMENT STEPS COMPLETED SUCCESSFULLY!"
log_info "Total Deployment & Verification Duration: ${DURATION}s"
log_info "=================================================="

exit 0
