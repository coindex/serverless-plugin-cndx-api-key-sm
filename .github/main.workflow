# on push workflow
workflow "push: install and audit push" {
  on = "push"
  resolves = ["push: npm audit"]
}

action "push: npm install" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "install"
}

action "push: npm audit" {
  needs = ["push: npm install"]
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "audit"
}

# on release workflow
workflow "release: publish release to npm" {
  on = "release"
  resolves = ["npm publish"]
}

action "release: is publish release" {
  uses = "actions/bin/filter@master"
  args = "action published"
}

action "release: npm install" {
  needs = ["release: is publish release"]
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "install"
}

action "release: npm audit" {
  needs = ["release: npm install"]
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "audit"
}

action "release: npm publish" {
  needs = ["release: npm audit"]
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  secrets = ["NPM_AUTH_TOKEN"]
  args = "publish"
}
