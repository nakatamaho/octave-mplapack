#!/usr/bin/env bash
set -euo pipefail

# Static GitHub-Markdown math policy checks for the tiered documentation.
# This intentionally does not parse TeX or execute numerical examples.
# GitHub renders inline math with dollar delimiters and multiline math with
# fenced `math` blocks.  The checker also permits legacy standalone $$ blocks
# so that older pages remain source-compatible during migration.

repo_root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

fail=0
mapfile -t documents < <(find docs/examples/tiered -maxdepth 2 -type f -name '*.md' |
  LC_ALL=C sort)

if [[ "${#documents[@]}" -eq 0 ]]; then
  echo "FAIL: no tiered Markdown documents found" >&2
  exit 1
fi

for file in "${documents[@]}"; do
  if rg -n -F -e '\[' -e '\]' -e '\(' -e '\)' "$file" >/dev/null; then
    echo "FAIL: raw \\[...\\] or \\(...\\) delimiters: $file" >&2
    fail=1
  fi

  if rg -n '\\(RR|CC|eps|diagop|newcommand|renewcommand|def)[[:space:]]*([ {]|$)' "$file" >/dev/null; then
    echo "FAIL: custom preamble macro in GitHub Markdown: $file" >&2
    fail=1
  fi

  if rg -n '\\\\(lambda|begin|end|mathbb|operatorname|frac|sqrt|Sigma|pi|varepsilon)' "$file" >/dev/null; then
    echo "FAIL: doubled LaTeX backslash from string escaping: $file" >&2
    fail=1
  fi

  # Catch the small class of obvious mathematical identifiers that are easy
  # to leave behind as plain Markdown prose during a notation conversion.
  # This is deliberately conservative: code fences, legacy $$ blocks,
  # inline code, and inline dollar math are removed before matching.  It is
  # not intended to parse TeX or infer mathematical meaning from arbitrary
  # English.
  if ! awk '
    function report(line_number) {
      printf "FAIL: %s:%d: obvious mathematical notation is outside GitHub math delimiters\n", FILENAME, line_number > "/dev/stderr"
      bad = 1
    }
    {
      line = $0
      if (line ~ /^[[:space:]]*(```|~~~)/) {
        in_fence = !in_fence
        next
      }
      if (line ~ /^[[:space:]]*\$\$[[:space:]]*$/) {
        in_dollar_block = !in_dollar_block
        next
      }
      if (in_fence || in_dollar_block)
        next

      # Remove inline code and both GitHub inline-math forms before the
      # intentionally small list of raw-notation checks.
      gsub(/`[^`]*`/, "", line)
      gsub(/\$`[^`]*`\$/, "", line)
      gsub(/\$[^$]*\$/, "", line)

      if (line ~ /r_eig|r_svd|sigma_min|sigma_max/ ||
          line ~ /A\^H|A\^T|V\^H|U\^H|Q\^T|H\^T/ ||
          line ~ /XY[[:space:]]*=/ || line ~ /YX[[:space:]]*=/ ||
          line ~ /(^|[^[:alnum:]_])lambda[[:space:]]*=/ ||
          line ~ /(^|[^[:alnum:]_])eta[[:space:]]*=/ ||
          line ~ /(^|[^[:alnum:]_])epsilon[[:space:]]*=/ ||
          line ~ /(^|[^[:alnum:]_])kappa[[:space:]]*=/ ||
          line ~ /2\^[-0-9]/ || line ~ /N\^m|P\^n|T\^T/ ||
          line ~ /\\(begin|end|frac|sqrt|sum|prod|operatorname|mathsf|mathbb|lVert|lvert|binom|qquad)/)
        report(FNR)
    }
    END {
      exit (bad ? 1 : 0)
    }
  ' "$file"; then
    fail=1
  fi

  # Keep the structural checks in one small line-oriented parser.  It is not
  # a TeX parser: it only verifies the Markdown embedding contract that is
  # relevant to GitHub's MathJax renderer.
  if ! awk '
    function mark_bad(message, line_number) {
      printf "FAIL: %s:%d: %s\n", FILENAME, line_number, message > "/dev/stderr"
      bad = 1
    }
    function count_inline_dollars(text,    i, c, previous, nextc, total) {
      total = 0
      for (i = 1; i <= length(text); ++i) {
        c = substr(text, i, 1)
        previous = (i > 1 ? substr(text, i - 1, 1) : "")
        nextc = (i < length(text) ? substr(text, i + 1, 1) : "")
        if (c == "$" && previous != "\\") {
          if (nextc == "$")
            ++i
          else
            ++total
        }
      }
      return total
    }
    {
      lines[++line_count] = $0
    }
    END {
      for (i = 1; i <= line_count; ++i) {
        line = lines[i]
        previous_line = (i > 1 ? lines[i - 1] : "")
        following_line = (i < line_count ? lines[i + 1] : "")
        is_math_marker = 0

        was_blockquote = in_blockquote
        was_details = in_details
        was_html_table = in_html_table
        was_markdown_table = in_markdown_table

        if (line ~ /^[[:space:]]*<table([[:space:]>]|$)/)
          in_html_table = 1
        if (line ~ /^[[:space:]]*<details([[:space:]>]|$)/)
          in_details = 1
        if (line ~ /^[[:space:]]*>/) {
          in_blockquote = 1
          was_blockquote = 1
        }

        # Use a bracket expression for a literal pipe.  In awk ERE, escaped
        # pipes can be interpreted as alternation by some implementations.
        is_table_row = (line ~ /^[[:space:]]*[|].*[|][[:space:]]*$/)
        if (is_table_row) {
          in_markdown_table = 1
          was_markdown_table = 1
        }

        if (line ~ /^[[:space:]]*```math[[:space:]]*$/) {
          is_math_marker = 1
          if (in_math_fence)
            mark_bad("nested ```math block", i)
          if (was_markdown_table || was_html_table || was_details || was_blockquote)
            mark_bad("display math inside a table, blockquote, or HTML container", i)
          if (i > 1 && previous_line !~ /^[[:space:]]*$/)
            mark_bad("```math block is not isolated from preceding prose", i)
          in_math_fence = 1
        } else if (line ~ /^[[:space:]]*```[[:space:]]*$/ && in_math_fence) {
          is_math_marker = 1
          if (following_line != "" && following_line !~ /^[[:space:]]*$/)
            mark_bad("```math block is not isolated from following prose", i)
          in_math_fence = 0
        }

        if (line ~ /^[[:space:]]*\$\$[[:space:]]*$/) {
          is_math_marker = 1
          if (was_markdown_table || was_html_table || was_details || was_blockquote ||
              in_math_fence)
            mark_bad("$$ display inside a table, blockquote, HTML container, or math block", i)
          if (!in_dollar_block && i > 1 && previous_line !~ /^[[:space:]]*$/)
            mark_bad("$$ block is not isolated from preceding prose", i)
          if (in_dollar_block && following_line != "" && following_line !~ /^[[:space:]]*$/)
            mark_bad("$$ block is not isolated from following prose", i)
          in_dollar_block = !in_dollar_block
        } else if (index(line, "$$") != 0) {
          mark_bad("$$ must be on a standalone line", i)
        }

        if ((index(line, "\\begin{") != 0 || index(line, "\\end{") != 0) &&
            !in_math_fence && !in_dollar_block)
          mark_bad("LaTeX environment outside a math block", i)

        if (is_table_row && (in_math_fence || in_dollar_block))
          mark_bad("display math inside a Markdown table row", i)

        if (!is_math_marker && !in_math_fence && !in_dollar_block)
          inline_dollars += count_inline_dollars(line)

        if (line ~ /^[[:space:]]*<\/table([[:space:]>]|$)/)
          in_html_table = 0
        if (line ~ /^[[:space:]]*<\/details([[:space:]>]|$)/)
          in_details = 0
        if (line ~ /^[[:space:]]*$/)
          in_blockquote = 0
        if (!is_table_row && was_markdown_table)
          in_markdown_table = 0
      }

      if (in_math_fence) {
        mark_bad("unclosed ```math block", line_count)
      }
      if (in_dollar_block) {
        mark_bad("unclosed $$ block", line_count)
      }
      if ((inline_dollars % 2) != 0) {
        mark_bad("unbalanced inline dollar delimiters", line_count)
      }
      exit (bad ? 1 : 0)
    }
  ' "$file"; then
    fail=1
  fi

  # Matrix and multiline MathJax environments must be inside a display block.
  if ! awk '
    { lines[++line_count] = $0 }
    END {
      for (i = 1; i <= line_count; ++i) {
        line = lines[i]
        if (line ~ /^[[:space:]]*```math[[:space:]]*$/)
          in_math = 1
        else if (line ~ /^[[:space:]]*```[[:space:]]*$/ && in_math)
          in_math = 0
        else if (line ~ /^[[:space:]]*\$\$[[:space:]]*$/)
          in_dollar = !in_dollar
        else if (line ~ /\\begin\{(bmatrix|pmatrix|matrix|cases|aligned)\}/ &&
                 !in_math && !in_dollar) {
          printf "FAIL: %s:%d: complex math environment is not in a math block\n", FILENAME, i > "/dev/stderr"
          bad = 1
        }
      }
      exit (bad ? 1 : 0)
    }
  ' "$file"; then
    fail=1
  fi
done

if [[ "$fail" -ne 0 ]]; then
  echo "FAIL: GitHub Markdown math checks" >&2
  exit 1
fi

echo "PASS: GitHub Markdown math checks (${#documents[@]} documents)"
