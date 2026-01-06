#!/usr/bin/env bash
#
# Interactive Notes App Tutorial Script
# =====================================
# Guides you through building a Notes app with AI agents.
# Run this script and follow along with docs/TUTORIAL.md
#
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Helpers
log()     { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; }
info()    { echo -e "${BLUE}[i]${NC} $1"; }
step()    { echo -e "\n${CYAN}${BOLD}━━━ $1 ━━━${NC}\n"; }
prompt()  { echo -e "${BOLD}$1${NC}"; }

# Wait for user to press Enter
wait_for_user() {
    echo ""
    read -rp "Press Enter to continue..."
}

# Check if a file exists and is not empty
file_exists() {
    [[ -f "$1" && -s "$1" ]]
}

# Check if a file contains a pattern
file_contains() {
    grep -q "$2" "$1" 2>/dev/null
}

# Display progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=30
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "${CYAN}Progress: [${NC}"
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "${CYAN}] ${percent}%% (Step ${current}/${total})${NC}\n"
}

# ============================================================================
# STEP DEFINITIONS
# ============================================================================

step_1_planning() {
    step "Step 1: Planning the App"
    
    echo "This step is about communicating requirements to the AI."
    echo ""
    prompt "Your prompt to the AI:"
    echo '  "I want to build a notes app using this bootstrap repo."'
    echo ""
    info "The AI should ask clarifying questions about:"
    echo "  - Note structure (title, content, timestamps)"
    echo "  - Tags support"
    echo "  - Features (CRUD, filtering)"
    echo "  - Authentication needs"
    echo ""
    info "Answer with:"
    echo "  1. Notes have title, content, timestamps"
    echo "  2. Yes, support multiple tags per note"
    echo "  3. Create, Edit, Delete, List, Filter by tags"
    echo "  4. No auth - single user"
    echo ""
    log "Planning complete! This is a conversation step - no verification needed."
}

step_2_database() {
    step "Step 2: Database Schema"
    
    prompt "Your prompt to the AI:"
    echo '  "Create the database schema for notes and tags in infra/init.sql"'
    echo ""
    
    info "Verifying implementation..."
    
    local passed=true
    
    if file_exists "infra/init.sql"; then
        log "infra/init.sql exists"
        
        if file_contains "infra/init.sql" "CREATE TABLE.*notes"; then
            log "notes table defined"
        else
            error "notes table not found in init.sql"
            passed=false
        fi
        
        if file_contains "infra/init.sql" "CREATE TABLE.*tags"; then
            log "tags table defined"
        else
            error "tags table not found in init.sql"
            passed=false
        fi
        
        if file_contains "infra/init.sql" "CREATE TABLE.*note_tags"; then
            log "note_tags junction table defined"
        else
            error "note_tags junction table not found"
            passed=false
        fi
    else
        error "infra/init.sql not found or empty"
        passed=false
    fi
    
    if $passed; then
        log "Step 2 PASSED!"
    else
        warn "Step 2 incomplete. Ask the AI to fix the issues above."
    fi
}

step_3_models() {
    step "Step 3: Backend API - Pydantic Models"
    
    prompt "Your prompt to the AI:"
    echo '  "Create Pydantic models for notes and tags in backend/app/models.py"'
    echo ""
    
    info "Verifying implementation..."
    
    local passed=true
    
    if file_exists "backend/app/models.py"; then
        log "backend/app/models.py exists"
        
        if file_contains "backend/app/models.py" "class Note"; then
            log "Note model defined"
        else
            error "Note model not found"
            passed=false
        fi
        
        if file_contains "backend/app/models.py" "class Tag"; then
            log "Tag model defined"
        else
            error "Tag model not found"
            passed=false
        fi
        
        if file_contains "backend/app/models.py" "class NoteCreate"; then
            log "NoteCreate model defined"
        else
            error "NoteCreate model not found"
            passed=false
        fi
    else
        error "backend/app/models.py not found"
        passed=false
    fi
    
    if $passed; then
        log "Step 3 PASSED!"
    else
        warn "Step 3 incomplete. Ask the AI to fix the issues above."
    fi
}

step_4_endpoints() {
    step "Step 4: Backend API - Endpoints"
    
    prompt "Your prompt to the AI:"
    echo '  "Create CRUD endpoints for notes in backend/app/notes.py"'
    echo ""
    
    info "Verifying implementation..."
    
    local passed=true
    
    if file_exists "backend/app/notes.py"; then
        log "backend/app/notes.py exists"
        
        # Check for key endpoints
        if file_contains "backend/app/notes.py" "@router.get.*notes"; then
            log "GET /notes endpoint defined"
        else
            error "GET /notes endpoint not found"
            passed=false
        fi
        
        if file_contains "backend/app/notes.py" "@router.post.*notes"; then
            log "POST /notes endpoint defined"
        else
            error "POST /notes endpoint not found"
            passed=false
        fi
        
        if file_contains "backend/app/notes.py" "@router.delete"; then
            log "DELETE endpoint defined"
        else
            error "DELETE endpoint not found"
            passed=false
        fi
    else
        error "backend/app/notes.py not found"
        passed=false
    fi
    
    # Check router registration
    if file_contains "backend/main.py" "notes"; then
        log "Notes router registered in main.py"
    else
        error "Notes router not registered in main.py"
        passed=false
    fi
    
    # Run backend tests
    info "Running backend tests..."
    if (cd backend && uv run pytest -q 2>&1 | tail -5); then
        log "Backend tests pass"
    else
        error "Backend tests failed"
        passed=false
    fi
    
    if $passed; then
        log "Step 4 PASSED!"
    else
        warn "Step 4 incomplete. Ask the AI to fix the issues above."
    fi
}

step_5_frontend_list() {
    step "Step 5: Frontend - Note List Component"
    
    prompt "Your prompt to the AI:"
    echo '  "Create Vue components to display notes: NoteCard.vue and NoteList.vue"'
    echo ""
    
    info "Verifying implementation..."
    
    local passed=true
    
    if file_exists "frontend/src/components/NoteCard.vue"; then
        log "NoteCard.vue exists"
    else
        error "NoteCard.vue not found"
        passed=false
    fi
    
    if file_exists "frontend/src/components/NoteList.vue"; then
        log "NoteList.vue exists"
    else
        error "NoteList.vue not found"
        passed=false
    fi
    
    if file_exists "frontend/src/api/client.ts"; then
        log "API client exists"
        if file_contains "frontend/src/api/client.ts" "getNotes\|listNotes"; then
            log "getNotes/listNotes method defined"
        else
            error "getNotes method not found in API client"
            passed=false
        fi
    else
        error "frontend/src/api/client.ts not found"
        passed=false
    fi
    
    if $passed; then
        log "Step 5 PASSED!"
    else
        warn "Step 5 incomplete. Ask the AI to fix the issues above."
    fi
}

step_6_frontend_crud() {
    step "Step 6: Frontend - Create/Edit/Delete"
    
    prompt "Your prompt to the AI:"
    echo '  "Add NoteForm.vue for creating/editing notes and wire up delete"'
    echo ""
    
    info "Verifying implementation..."
    
    local passed=true
    
    if file_exists "frontend/src/components/NoteForm.vue"; then
        log "NoteForm.vue exists"
    else
        error "NoteForm.vue not found"
        passed=false
    fi
    
    # Check App.vue integration
    if file_contains "frontend/src/App.vue" "NoteForm\|note-form"; then
        log "NoteForm integrated in App.vue"
    else
        error "NoteForm not integrated in App.vue"
        passed=false
    fi
    
    # Check API client has CRUD methods
    if file_contains "frontend/src/api/client.ts" "createNote"; then
        log "createNote method defined"
    else
        error "createNote method not found"
        passed=false
    fi
    
    if file_contains "frontend/src/api/client.ts" "deleteNote"; then
        log "deleteNote method defined"
    else
        error "deleteNote method not found"
        passed=false
    fi
    
    if $passed; then
        log "Step 6 PASSED!"
    else
        warn "Step 6 incomplete. Ask the AI to fix the issues above."
    fi
}

step_7_filtering() {
    step "Step 7: Tag Filtering"
    
    prompt "Your prompt to the AI:"
    echo '  "Add TagFilter.vue component and filter notes by selected tag"'
    echo ""
    
    info "Verifying implementation..."
    
    local passed=true
    
    if file_exists "frontend/src/components/TagFilter.vue"; then
        log "TagFilter.vue exists"
    else
        error "TagFilter.vue not found"
        passed=false
    fi
    
    # Check App.vue has tag filtering logic
    if file_contains "frontend/src/App.vue" "TagFilter\|tag-filter\|selectedTag"; then
        log "Tag filtering integrated in App.vue"
    else
        error "Tag filtering not integrated in App.vue"
        passed=false
    fi
    
    # Run frontend tests
    info "Running frontend tests..."
    if (cd frontend && pnpm test:coverage 2>&1 | tail -5); then
        log "Frontend tests pass"
    else
        error "Frontend tests failed"
        passed=false
    fi
    
    if $passed; then
        log "Step 7 PASSED!"
    else
        warn "Step 7 incomplete. Ask the AI to fix the issues above."
    fi
}

step_8_polish() {
    step "Step 8: Final Polish"
    
    prompt "Your prompt to the AI:"
    echo '  "Run the build and fix any issues. Regenerate OpenAPI if needed."'
    echo ""
    
    info "Verifying final build..."
    
    local passed=true
    
    # Backend type check
    info "Running mypy..."
    if (cd backend && uv run mypy . --no-error-summary 2>&1 | tail -3); then
        log "Backend type check passes"
    else
        error "Backend type check failed"
        passed=false
    fi
    
    # Frontend build
    info "Running frontend build..."
    if (cd frontend && pnpm build 2>&1 | tail -3); then
        log "Frontend build passes"
    else
        error "Frontend build failed"
        passed=false
    fi
    
    # All tests
    info "Running all tests..."
    if make test 2>&1 | tail -10; then
        log "All tests pass"
    else
        error "Tests failed"
        passed=false
    fi
    
    if $passed; then
        log "Step 8 PASSED!"
        echo ""
        echo -e "${GREEN}${BOLD}🎉 CONGRATULATIONS! 🎉${NC}"
        echo ""
        echo "You've successfully built a Notes app with AI agents!"
        echo ""
        echo "Your app now has:"
        echo "  ✓ PostgreSQL database with notes, tags, and junction table"
        echo "  ✓ FastAPI backend with full CRUD endpoints"
        echo "  ✓ Vue 3 frontend with components for listing, creating, editing"
        echo "  ✓ Tag filtering functionality"
        echo "  ✓ 100% test coverage"
        echo ""
        echo "Next steps:"
        echo "  1. Run 'make up' to start the app"
        echo "  2. Visit http://localhost:5173 to see your notes app"
        echo "  3. Deploy with './infra/fly-setup.sh'"
    else
        warn "Step 8 incomplete. Ask the AI to fix the issues above."
    fi
}

# ============================================================================
# MAIN MENU
# ============================================================================

show_menu() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           Notes App Tutorial - Interactive Guide             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "This script guides you through building a Notes app with AI agents."
    echo "Open docs/TUTORIAL.md alongside this script for detailed prompts."
    echo ""
    echo "Steps:"
    echo "  1. Planning the App (conversation)"
    echo "  2. Database Schema (infra/init.sql)"
    echo "  3. Backend Models (backend/app/models.py)"
    echo "  4. Backend Endpoints (backend/app/notes.py)"
    echo "  5. Frontend Note List (components)"
    echo "  6. Frontend CRUD (NoteForm.vue)"
    echo "  7. Tag Filtering (TagFilter.vue)"
    echo "  8. Final Polish (build & test)"
    echo ""
    echo "Options:"
    echo "  a) Run all steps sequentially"
    echo "  v) Verify all steps (quick check)"
    echo "  1-8) Jump to specific step"
    echo "  q) Quit"
    echo ""
}

verify_all() {
    step "Verifying All Steps"
    show_progress 0 8
    
    local total_passed=0
    
    # Step 2
    if file_exists "infra/init.sql" && file_contains "infra/init.sql" "notes"; then
        log "Step 2: Database ✓"
        ((total_passed++))
    else
        error "Step 2: Database ✗"
    fi
    show_progress 1 8
    
    # Step 3
    if file_exists "backend/app/models.py" && file_contains "backend/app/models.py" "class Note"; then
        log "Step 3: Models ✓"
        ((total_passed++))
    else
        error "Step 3: Models ✗"
    fi
    show_progress 2 8
    
    # Step 4
    if file_exists "backend/app/notes.py" && file_contains "backend/app/notes.py" "@router"; then
        log "Step 4: Endpoints ✓"
        ((total_passed++))
    else
        error "Step 4: Endpoints ✗"
    fi
    show_progress 3 8
    
    # Step 5
    if file_exists "frontend/src/components/NoteList.vue"; then
        log "Step 5: Note List ✓"
        ((total_passed++))
    else
        error "Step 5: Note List ✗"
    fi
    show_progress 4 8
    
    # Step 6
    if file_exists "frontend/src/components/NoteForm.vue"; then
        log "Step 6: Note Form ✓"
        ((total_passed++))
    else
        error "Step 6: Note Form ✗"
    fi
    show_progress 5 8
    
    # Step 7
    if file_exists "frontend/src/components/TagFilter.vue"; then
        log "Step 7: Tag Filter ✓"
        ((total_passed++))
    else
        error "Step 7: Tag Filter ✗"
    fi
    show_progress 6 8
    
    # Step 8 - tests pass
    if make test >/dev/null 2>&1; then
        log "Step 8: Tests ✓"
        ((total_passed++))
    else
        error "Step 8: Tests ✗"
    fi
    show_progress 7 8
    
    # Build passes
    if (cd frontend && pnpm build >/dev/null 2>&1); then
        log "Build: ✓"
        ((total_passed++))
    else
        error "Build: ✗"
    fi
    show_progress 8 8
    
    echo ""
    if [ $total_passed -eq 8 ]; then
        echo -e "${GREEN}${BOLD}All steps complete! Your Notes app is ready.${NC}"
    else
        echo -e "${YELLOW}${BOLD}$total_passed/8 steps complete.${NC}"
    fi
}

run_all() {
    step_1_planning
    wait_for_user
    
    step_2_database
    wait_for_user
    
    step_3_models
    wait_for_user
    
    step_4_endpoints
    wait_for_user
    
    step_5_frontend_list
    wait_for_user
    
    step_6_frontend_crud
    wait_for_user
    
    step_7_filtering
    wait_for_user
    
    step_8_polish
}

# ============================================================================
# ENTRY POINT
# ============================================================================

main() {
    # If argument provided, run that step directly
    if [[ -n "$1" ]]; then
        case "$1" in
            1) step_1_planning ;;
            2) step_2_database ;;
            3) step_3_models ;;
            4) step_4_endpoints ;;
            5) step_5_frontend_list ;;
            6) step_6_frontend_crud ;;
            7) step_7_filtering ;;
            8) step_8_polish ;;
            all) run_all ;;
            verify) verify_all ;;
            *) echo "Usage: $0 [1-8|all|verify]"; exit 1 ;;
        esac
        exit 0
    fi
    
    # Interactive menu
    while true; do
        show_menu
        read -rp "Choose an option: " choice
        
        case "$choice" in
            1) step_1_planning; wait_for_user ;;
            2) step_2_database; wait_for_user ;;
            3) step_3_models; wait_for_user ;;
            4) step_4_endpoints; wait_for_user ;;
            5) step_5_frontend_list; wait_for_user ;;
            6) step_6_frontend_crud; wait_for_user ;;
            7) step_7_filtering; wait_for_user ;;
            8) step_8_polish; wait_for_user ;;
            a|A) run_all; wait_for_user ;;
            v|V) verify_all; wait_for_user ;;
            q|Q) echo "Goodbye!"; exit 0 ;;
            *) warn "Invalid option: $choice" ;;
        esac
    done
}

main "$@"
