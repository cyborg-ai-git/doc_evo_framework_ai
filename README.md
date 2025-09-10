<img src="https://avatars.githubusercontent.com/u/129898917?v=4" alt="cyborgai" width="256" height="256">

---

## [CyborgAI](https://github.com/cyborg-ai-git) (https://github.com/cyborg-ai-git)

---

# EVO framework DOC

---

> ⚠️ **BETA DISCLAIMER**: The EVO framework AI is currently in beta version. The documentation may change.

---

## License

### License Explanation
The CyborgAI project begins with the most restrictive Creative Commons license (CC BY-NC-ND 4.0) to safeguard the community's work from unauthorized code use and exploitation. This license prohibits commercial use and derivative works without explicit permission, ensuring that early contributions remain protected and value accrues to legitimate participants.

As development milestones are achieved and community contributions expand, the license restrictions will gradually reduce according to our progressive decentralization roadmap, ultimately making the code more accessible to everyone.

### License Evolution Strategy

The licensing strategy serves multiple purposes:

* Protects initial intellectual property investment during high-risk development phases
* Creates controlled commercialization paths that direct revenue back to contributors
* Establishes clear boundaries for permissible usage during ecosystem growth
* Provides a transparent pathway toward eventual open access when appropriate safeguards are in place
* Discourages early forks that could fragment the community before critical mass is achieved

### License Terms
> #### CC BY-NC-ND 4.0 Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International
> Attribution Required: All usage must credit CyborgAI and original contributors
> Non-Commercial: Commercial usage requires explicit written permission
> No Derivatives: Modified versions cannot be distributed without authorization
> Community Protection: Ensures value flows back to legitimate ecosystem participants

---

## 🎥 Demo Video
[![EVO framework DOC Demo](https://img.youtube.com/vi/OnZAlOs09p4/maxresdefault.jpg)](https://www.youtube.com/watch?v=OnZAlOs09p4)


*Click the image above to watch the demo video on YouTube*

---

## Release
[EVO framework DOC](https://github.com/cyborg-ai-git/evo_framework_doc/releases)

---

## Installation

### Prerequisites

| Tool | Description | Documentation |
|------|-------------|---------------|
| **PlantUML** | Required for diagram generation in `run_documentation.sh` | 📖 **[Install PlantUML Guide](install_plantuml.md)** |
| **Pandoc** | Required for document export to PDF, DOC, ODT formats | 📖 **[Install Pandoc Guide](install_pandoc.md)** |

**Note**: We are actively working on eliminating these external dependencies in the upcoming **CyborgAI Dev** application.

---

## Project Structure

```
app_EVO framework DOC/
├── app_EVO framework DOC/              # Main CLI application
│   ├── src/
│   │   └── main.rs               # Application entry point
│   ├── benches/                  # Performance benchmarks
│   │   └── bench_app_EVO framework DOC.rs
│   ├── tests/                    # Integration tests
│   │   └── test_app_EVO framework DOC.rs
│   └── Cargo.toml               # Package configuration
├── scripts/                     # Development and automation scripts
│   ├── run_issue_create.sh      # Create GitHub issues with branches
│   ├── run_issue_commit.sh      # Commit all files changed
│   ├── run_issue_finish.sh      # Finish issues with PRs
│   ├── run_issue_list.sh        # List GitHub issues
│   ├── run_issue_start.sh       # Start working on issues
├──  data/                   # Documentation assets
├──  doc/                   # Documentation markup
├── Cargo.toml                  # Workspace configuration
├── LICENSE.txt                 # License file
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

---

## Scripts Folder Explanation

The `scripts/` folder contains automation scripts for development workflow:


### Issue Management (GitHub Integration)
- **`run_issue_create.sh`**: 
  - Creates GitHub issues and corresponding Git Flow feature branches
  - Usage: `./run_issue_create.sh "issue title" "description"`
  - Automatically generates sanitized branch names like `feature/issue_123_fix_bug`

- **`run_issue_start.sh`**: 
  - Starts work on existing GitHub issues by creating feature branches
  - Usage: `./run_issue_start.sh issue_number`
  - Checks out existing remote branches if they exist

- **`run_issue_finish.sh`**: 
  - Completes issue workflow by creating pull requests and closing issues
  - Merges feature branches back to develop using Git Flow
  - Automatically closes GitHub issues when PRs are created

- **`run_issue_list.sh`**: Lists all GitHub issues using `gh issue list`

### Documentation & Publishing
- **`run_documentation.sh`**: 
  - Generates PlantUML diagrams from `.puml` files in `documentation/data/`
  - Creates Rust documentation using `cargo doc --no-deps --open`
  - Copies generated docs to `documentation/doc/` for version control

- **`run_publish.sh`**: Publishes the crate to crates.io using `cargo publish`

---

## Development Workflow

This repository uses **Git Flow** branching strategy for organized development:

### Branch Structure
- **`master`**: Production-ready, stable releases only
- **`develop`**: Integration branch where features are merged for testing
- **`feature/*`**: Feature development branches (e.g., `feature/issue_123_new_feature`)
- **`release/*`**: Release preparation branches (e.g., `release/v1.2.0`)

**Note on Hotfix Branches**: We do not use `hotfix/*` branches in our CyborgAI standard workflow. All code must be fully tested and verified before deployment. We believe that good code takes time, and proper testing through the standard feature → develop → release → master flow ensures quality and stability.

---

## How to Contribute

### 🚀 Quick Start for Contributors

1. **Fork the Repository**: Create your own fork of the project
2. **Create an Issue**: Use our automated script to create issues and Git Flow feature branches:
3. **Start Feature Branch**: Use Git Flow to start working on the issue:
4. **Follow EVO Framework**: Adhere to naming conventions and architecture patterns
5. **Write Tests**: Include appropriate test coverage
6. **Submit Pull Request**: Use Git Flow to finish and target the `develop` branch:
7. **Code Review**: Participate in the review process


### 🛠️ Automated Contribution Workflow

Use our automated scripts for streamlined contributions:

```bash

# Create a new issue and feature branch
# type: [doc|feature]
./scripts/run_issue_create.sh type "Title" "Detailed description"

#examples:

# Create a documentation issue
#./scripts/run_issue_create.sh doc "Update API docs" "The agent tab section needs doc ..."

# Create a feature request  
#./scripts/run_issue_create.sh feature "Add dark mode" "Implement dark theme support for better user experience ..."

# Start working on an existing issue
./scripts/run_issue_start.sh 123

# Finish your work and create a pull request
./scripts/run_issue_finish.sh 123
```
---

### 📋 GitHub Templates & Community Standards

This repository includes comprehensive GitHub templates and community standards located in the `.github/` directory:

- **`.github/CODE_OF_CONDUCT.md`**: Community guidelines and expected behavior
- **`.github/ISSUE_TEMPLATE/`**: Standardized issue templates for bugs, features, and documentation
- **`.github/PULL_REQUEST_TEMPLATE.md`**: Pull request template with checklist
- **`.github/CONTRIBUTING.md`**: Detailed contribution guidelines
- **`.github/SECURITY.md`**: Security policy and vulnerability reporting

---

### 📝 Contribution Guidelines

- Follow the **[EVO Framework standard conventions](https://github.com/cyborg-ai-git/doc_evo.git)**
- Maintain strict separation between Control and Gui layers
- Document all
- Include unit tests for new functionality
- Ensure cross-platform compatibility
- Use the provided GitHub templates when creating issues and pull requests
- Follow the Code of Conduct outlined in `.github/CODE_OF_CONDUCT.md`

---


## License
**[CC BY-NC-ND 4.0 Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International](LICENSE.txt)**

---

## Links
- [CyborgAI Website](https://cyborgai.fly.dev)
- [YouTube](https://www.youtube.com/watch?v=OnZAlOs09p4)
- [GitHub](https://github.com/cyborg-ai-git)

---