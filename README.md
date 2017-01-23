Mirror GitHub to Gitlab
=======================

The mirror tool will index all repositories inside a GitHub organization and will take care about mirroring that
repositories into a GitLab installation.

## How it works

You will need:

* GitHub API token (for read access)
* GitHub user / organization as source
* Gitlab group as target (e.g. `github-mirror`)
* Gitlab user (e.g. `github-mirror-worker`) with its API token
  * user has to be owner of the target group

The tool indexes all repositories and checks if they are present on target.

Missing repositories will be created, and git will mirror all refs over to Gitlab.

**Note:** Make sure that the Gitlab group is read-only to everyone else, as you don't want to have updates there.

On sync the directory `tmp/` will be used to store the mirrored repositories, please persist it, so the sync is incremental.

## Usage

Fill `settings.yml` with config

    ---
    github:
      oauth_token: XXXXXXXXXXX
      user: awesome-corp

    target: gitlab

    gitlab:
      endpoint: https://gitlab.awesome.corp/api/v3
      private_token: XXXXXXXXXXXX
      group: github-mirror

And run the tool:

    bundle install
    bundle exec ./bin/github-mirror --list
    bundle exec ./bin/github-mirror --sync

If you want to use a local SSH identity file:

    SSH_AUTH_SOCK= GIT_SSH_COMMAND="/usr/bin/ssh -i `pwd`/id_rsa" bundle exec ./bin/github-mirror --sync

## Copyright

    Copyright (C) 2016 Markus Frosch <markus@lazyfrosch.de>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
