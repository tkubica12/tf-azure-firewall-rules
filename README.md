# Terraform automation for Azure Firewall rules example
This repo demonstrates one of manz options to abstract firewall rules to make it easier for network teams to author changes, manage work and process changes using GitHub features and safely deploy using GitHub Actions.

This repo includes GitHub Actions workflow including policy checks using rego language and Open Policy Agent.

# Rules logic
There are miriads of strategies and this solution is just one of those. Tradeoff is shifted towards hierarchical approach (use central Firewall for "big" rules with central control combined with microsegmentation on project level) and self-service (teams to be able to manage their rules and deciding who can access their services and what endpoints in Internet need to be accessed) by leveraging PRs (with approval from central team).

Key principles:
- No direct access to Terraform code when managing rules
- YAML abstraction to setup rules
- Structured in folders and separate files so it is easy to self-manage (teams can propose changes to their rules via Pull Request)
- Administrator "bootstraps" key projects (usualy equal subscription) by filling metadata.yaml file with name and IP range. Solution than creates IP Group that is referenced in rules. Note in this example each project/subscription uses its own Rule Collection Group and there is limit to 100 of those. Should you require more different strategy needs to be used (eg. putting grouping rules for all dev vs. all prod projects)
- Network rules (L4)
  - Created using files with "net" prefix and consist of group and ip rules. Group rules reference source ip groups (other projects/subscriptions) while ip rules reference individual IP ranges as source.
  - YAML by design do not include destination information as project owner cannot configure those (key principle is project can only manage access to itself, cannot create rules for anything else).Strategy in this is example is not to micromanage destinations (IPs) - central firewall is to do big decissiongs (what projects can talk to each other) while more specific microsegmentation (what IPs in project can receive 443 traffic) is done on subscription level (NSGs, Network Policies etc. - closer to workload, responsibility of applicaiton team as those things change often).
- Application rules (L7 = transparent proxy)
  - Created using files with "app" prefix
  - Used to configure outbound traffic to L7 targets (mostly on Internet)
  - Source cannot be configured and solution statically use proper IP group of project/subscription (owner of subscription can configure only rules for himself)
- Application publication is not solved in this demo - exposure will be done on different product (Front Door or Application Gateway) for http-based workloads and non-http-based usecases are not in scope of this simple example.

# Policy checks
Few examples of policy checks are included for example to warn of wildcard use, too wide port ranges, use of unencrypted http communication or exposure of unsecure ports. Examples are written in rego language and GitHub Actions workflow is provided to use Open Policy Agent to run policy checks in two ways:
- Testing as part of Pull Request - only changed YAMLs are considered
- Ad-hoc test with manual dispatch that will run tests over all YAML files in rules folder

# Worflow and automation
- Branch protection is configured so no direct commits to main are allowed, only via Pull Request
- Policy checks and run on each PR
- Terraform plan file is generated, storage and planned changes logged on each PR
- After merge deployment to production is initiated requiring additional approval and stored plan file is consumed so no not-reviewed changes will be done (Terraform will fail if it detects any drift)

# Roadmap and missing items
See [https://github.com/users/tkubica12/projects/2/views/1](https://github.com/users/tkubica12/projects/2/views/1)

