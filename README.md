Mirror GitHub to Gitlab
=======================

This repo contains a helper to mirror the contents of a GitHub organization into a local Gitlab instance.

## Usage

Fill `settings.yml` with config

    ---
    github:
      oauth_token: XXXXXXXXXXX
      user: myorg
    
    target: gitlab
    
    gitlab:
      endpoint: https://gitlab.example.com/api/v3
      private_token: XXXXXXXXXXXX
      group: test

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
