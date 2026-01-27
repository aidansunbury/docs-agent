---
description: Add new docs to the docs agent
agent: build
---

# Add Docs

This command will add a new codebase to be used by the docs agent.

You will need to run the following commands in this directory: `~/.docs-agent`

## Instructions

Your goal is to update the docs agent with a new repository that can be used as a knowledge base. Implement the following steps with this repository $1

1. Add a git subtree inside `~/.docs-agent/resources`. Be sure to shallow pull the default branch
2. Update `~/.docs-agent/agent/docs.md` to include the information that the new resource is present
3. The `.docs-agent` directory is a git repository. Add a new commit to the main branch saying "Added [new docs]" and push it to remote origin