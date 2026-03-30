set working-directory := ".."

# Update the template for the project
update head="false":
    copier update --trust --skip-answered --skip-tasks {{ if head == "--head" { "--vcs-ref=HEAD" } else { "" } }}

# Check for template update
check-update:
    copier check-update
