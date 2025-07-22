Generate a Git commit message using the Conventional Commits format. Then, include three --trailer fields:

Assistant-model: The name of the AI model (e.g., GPT-4o)

LLM-Contrib: An estimated percentage of contribution from the AI (e.g., 60%)

Prompt: A brief human instruction or goal (e.g., "Refactor for readability")

Format the final output like this:

bash
Copy
Edit
git commit --message "type(scope): concise description" \
  --trailer "Assistant-model: GPT-4o" \
  --trailer "LLM-Contrib: 60%" \
  --trailer "Prompt: <short description of prompt>"
Use an appropriate Conventional Commit type (like feat, fix, refactor, docs, etc.) and optionally include a scope if relevant.
