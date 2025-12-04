#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔄 Updating git subtrees..."

# Check if .gitmodules exists
if [ ! -f .gitmodules ]; then
    echo -e "${RED}Error: .gitmodules file not found${NC}"
    exit 1
fi

# Parse .gitmodules and extract submodule information
# This awk script extracts path, url, and branch for each submodule
submodules=$(awk '
    /^\[submodule/ { 
        if (path != "") {
            print path "|" url "|" branch
        }
        path = ""
        url = ""
        branch = ""
    }
    /path = / { path = $3 }
    /url = / { url = $3 }
    /branch = / { branch = $3 }
    END {
        if (path != "") {
            print path "|" url "|" branch
        }
    }
' .gitmodules)

# Check if we found any submodules
if [ -z "$submodules" ]; then
    echo -e "${YELLOW}No submodules found in .gitmodules${NC}"
    exit 0
fi

# Counter for statistics
total=0
updated=0
failed=0

# Process each submodule
while IFS='|' read -r path url branch; do
    # Skip if not in resources directory
    if [[ ! "$path" =~ ^resources/ ]]; then
        continue
    fi
    
    total=$((total + 1))
    
    echo ""
    echo -e "${YELLOW}Processing: $path${NC}"
    
    # Check if the directory exists
    if [ ! -d "$path" ]; then
        echo -e "${RED}  ✗ Directory not found, skipping${NC}"
        failed=$((failed + 1))
        continue
    fi
    
    # Use branch from .gitmodules
    if [ -z "$branch" ]; then
        echo -e "${RED}  ✗ No branch specified in .gitmodules${NC}"
        failed=$((failed + 1))
        continue
    fi
    
    echo -e "  Branch: ${GREEN}$branch${NC}"
    
    # Pull the latest changes
    echo "  Pulling latest changes..."
    if git -C "$path" pull origin "$branch" --ff-only; then
        echo -e "${GREEN}  ✓ Successfully updated${NC}"
        updated=$((updated + 1))
    else
        echo -e "${RED}  ✗ Failed to pull (you may have local changes)${NC}"
        failed=$((failed + 1))
    fi
    
done <<< "$submodules"

# Print summary
echo ""
echo "================================"
echo "Summary:"
echo "  Total processed: $total"
echo -e "  ${GREEN}Successfully updated: $updated${NC}"
if [ $failed -gt 0 ]; then
    echo -e "  ${RED}Failed: $failed${NC}"
fi
echo "================================"

# Exit with error if any updates failed
if [ $failed -gt 0 ]; then
    exit 1
fi
