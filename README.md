# capistrano-strategy-copy-partial

capistrano-strategy-copy-partial is [capistrano](https://github.com/capistrano/capistrano) extension that add strategy for deploy only part (subdirectory) of repository

## Installation

Add to `Gemfile`:

    gem "capistrano-strategy-copy-partial"

## Configuration

Use next options:

    set :deploy_via,   :copy_partial
    set :copy_partial, "path/for/deploy"
    set :copy_strategy, :export

## Licence

capistrano-strategy-copy-partial is released under the MIT licence:

* http://www.opensource.org/licenses/MIT
