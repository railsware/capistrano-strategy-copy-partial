# capistrano-strategy-copy-partial

capistrano-strategy-copy-partial is [capistrano](https://github.com/capistrano/capistrano) extension that add strategy for deploy only part (subdirectory) of repository

## Installation

Add to `Gemfile`:

    gem "capistrano-strategy-copy-partial"

## Mandatory Configuration

Use these options:

    set :deploy_via,   :copy_partial
    set :copy_partial, "path/for/deploy"  #NOTE this path is relative to the repository root
    set :copy_strategy, :export

## Optional Configuration

You may also optionally run a build command by setting:

    set :build_dir,    "path/where/build_script/is_run"  #NOTE this path is relative to the repository root
    set :build_script, "mvn clean install"


## Licence

capistrano-strategy-copy-partial is released under the MIT licence:

* http://www.opensource.org/licenses/MIT
