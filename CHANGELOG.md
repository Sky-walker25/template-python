# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.1] - 2026-05-05
Fix missing `isort` in python dev dependencies.

### Added
- Add isort to dev dependencies

### Fixed
- Fix minor typo
- Use local env file when building


## [0.6.0] - 2026-04-23

### Added
- Add python-dotenv dependency
- Add black to dev dependencies
- Set default `project_name` from destination folder name
- Add package_name variable with auto-sanitization
- Add pylock.toml

### Changed
- Add --vcs-ref=HEAD indication
- Move instructions to standard AGENTS.md
- Pin ruff check to the same version of pyproject
- Do not include any particular env variable
- Rename `Setup` to `Development` in README
- Update mypy
- Update license naming
- Clean up instructions

### Fixed
- Fix isort - black interactions
- Add missing comma in runArgs

### Removed
- Remove copilot centric instructions
- Remove copy env task


## [0.5.1] - 2026-04-07
Improve compatibility with host and update the base image.

### Changed
- Set `$TERM` env variable to match host
- Bump debian container image to trixie
- Add `--no-install-recommends` to apt install
- Use `--global` option for pipx
- Detail commit style instructions
- No numeric ID in Copilot co-author address
- Dynamic version from project `__init__`

### Fixed
- Clean apt cache and remove package lists after install
- Fix locales


## [0.5.0] - 2026-04-01
Mix of fixes and improvements and a few new features.

### Added
- Add package default version in `__init__`
- Add copilot instructions
- Add missing pre-commit to devcontainer
- Add recipe to check changes to be released
- Add release script using git-cliff

### Changed
- Improve README
- Improve README
- Improve instructions
- Detail version, commits and changelog
- Update instructions
- Detail just recipes in README
- Setup devcontainer for the template repo
- Set container hostname
- Move recipes to new module

### Fixed
- Fix missing comma
- Fix typos
- Correct recipe command to just devcontainers::up
- Correct cache path from /cache/<tool> to /tmp/cache/<tool>/
- Fix jinja/justfile competition on brackets

### Removed
- Remove addition python3 install
- Remove duplicated check
- Remove AGENT.md


## [0.4.1] - 2026-03-31
Add GitHub copilot token to mounted variables in the devcontainer. Clean up
some files.

### Changed
- feat(repo): add pre-commit verifications
  (41ce51dbd17f123489dd624ebc3cd7dace0f521a)
- feat(copilot): mount GitHub copilot token
  (33d6f46346fcebaff1d5438d46199e8aab89c588)

### Fixed
- style(recipes): clean up file (c8f0d9bedf12597c21c405977a9709d2b86c5cfe)


## [0.4.0] - 2026-03-30
Improve documentation and dev container setup.

### Added
- feat(docs): add project organization
  (f68ae1c97b921520f943cfce2e98818280420602)
- feat(devcontainer): set locales (16a71c0c54d18d992c0c989956c89975fe5b439d)
- feat(repo): add AGENT.md (5cc03b933065c1abbaa542b3a7a2085f150647ce)

### Changed
- style(docs): improve presentation (b13c57e736d29e95229a91caefd4147f096f06e8)
- feat(docs): improve README section on dependencies
  (c7846f04e17de5b95107a1159b4ba28af4b9e3da)


## [0.3.3] - 2026-03-25
Fix the working directory for commands executed from just recipes in sub
directories.

### Fixed
- fix(template): fix just recipes working dir
  (e23935e2ffecde28f603fd0847f57738da04ac06)


## [0.3.2] - 2026-03-25
Clean up clutter my moving just recipes to `.recipes/`. Add the option to
update the template from latest commit (instead of latest tag).

### Added
- feat(template): add option to update to template's last commit
  (c54f88604c98abaaac85faa41c3f1922c08d3238)

### Changed
- refacto(template): move just recipes to `.recipes`
  (90dbf7dbe044930bff75b16bbc03a20b13bbae8d)
- refacto(template): remove clutter (7e8b750520362b419b30e12c4d472b36c98b05ea)


## [0.3.1] - 2026-03-19
Fix copier installation from inside the dev container

### Fix
- fix(setup): install copier extension
  (e35b340d6ea3bd71dca1577adb9316e16ef14c38)


## [0.3.0] - 2026-03-19
Detail documentation for new project and improve setup. Add black and isort to
pre-commit hooks.

### Added
- feat(template): add README.md file with setup instructions
  (a3695c13563259e7bd87fc5ffee6820f70d781a8)
- feat(template): add instructions for adding dependencies
  (f3fe63b1bfa5327942d9e1623b40f66417ae6bdb)
- feat(template): add `py.typed` to library
  (50d4eab928c704894989db32be07e7d0abdfbe13)

### Changed
- feat(template): add black and isort git hooks
  (61b64eff96464850842db618a9eeb967dda288f3)

### Fixed
- fix(setup): continue setup on pre-commit fail
  (142e31a799eb5c00c0c6ba2f94910d9a58408b8a)


## [0.2.2] - 2026-03-17
Setup ruff and black pre commit hooks.

### Added
- feat(template): add ruff and pdm pre commit hooks
  (a9b480dfeddc6f774158d8fcf24f889f996a393b)


## [0.2.1] - 2026-03-17
Fix mypy version which was manually edited for testing changes.

### Fixed
- fix(template): fix mypy version (dee0958b9fba5041adb4dfb04e7418299ea1cdb5)


## [0.2.0] - 2026-03-17
Add a CHANGELOG.

### Added
- feat(template): add a CHANGELOG to the template
  (c4d09839adeb37eeefff18818eccca9cd959fd7f)


## [0.1.1] - 2026-03-17
Fix url of this repo for copier to better understand it's a git repo.

### Fixed
- fix(template): switch git url to ssh
  (3ae9973a3ef726386920bd64149c4019b27e8ce4)


## [0.1.0] - 2026-03-17
Setup the project.
