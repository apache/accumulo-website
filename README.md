# Apache Accumulo Website

Apache Accumulo's website is generated from Markdown source (specifically,
[kramdown] style) with [Jekyll], using [Bundler] to manage its gem
dependencies.

## Development

### Custom Liquid Tags

Jekyll uses [Liquid] to process files before interpreting their Markdown
contents. We have extended Jekyll using its plugin mechanism to create custom
Liquid tags that make it easier to link to javadocs, properties, and documents.

The source for these tags is at [\_plugins/links.rb](_plugins/links.rb).

| Tag   | Description            | Options                                                                         | Examples                                             |
| ----- | ---------------------- | ------------------------------------------------------------------------------- | ---------------------------------------------------- |
| jlink | Creates Javadoc link   | Link text will be class name by default. Use `-f` for full package + class name | `{% jlink -f org.apache.accumulo.core.client.Connector %}`  `{% jlink -f org.apache.accumulo.core.client %}` |
| jurl  | Creates Javadoc URL    | None                                                                            | `{% jurl org.apache.accumulo.core.client.Connector %}`     |
| plink | Creates Property link  | Assumes server property by default. Use `-c` to link to client properties. Accepts server property prefixes (i.e `table.\*`)       | `{% plink -c instance.name %}`                             |
| purl  | Creates Property URL   | Default is server property. Use `-c` to link to client properties. Accepts server property prefixes (i.e `table.\*`)               | `{% purl instance.volumes %}`                             |
| dlink | Creates Documentation link | None                                                                            | `{% dlink getting-stared/clients %}`                   |
| durl  | Creates Documentation URL  | None                                                                            | `{% durl troubleshooting/performance %}`                   |
| ghi   | GitHub issue link          | None  | `{% ghi 100 %}` |
| ghc   | GitHub code link          | Branch defaults to `gh_branch` setting in `_config.yml`. Override using `-b` | `{% ghc server/tserver/src/main/java/org/apache/accumulo/tserver/TabletServer.java %}` `{% ghc -b 1.9 README.md %}` |
| jira   | Jira issue link          | None  | `{% jira ACCUMULO-1000 %}` |

### Updating Property Documentation for Releases

Building Accumulo  generates `server-properties.md` and `client-properties.md`.
To regenerate these, do the following.

```bash
ACCUMULO_SITE_CLONE=<accumulo website clone location, with master branch checked out>
ACCUMULO_CLONE=<accumulo clone location>
cd "$ACCUMULO_CLONE"
mvn package -DskipTests
cp ./core/target/generated-docs/server-properties.md "$ACCUMULO_SITE_CLONE"/_docs-2/configuration
cp ./core/target/generated-docs/client-properties.md "$ACCUMULO_SITE_CLONE"/_docs-2/configuration
```

## Local Builds for Testing

### Setting up Your Jekyll/Bundler Environment

Ruby and RubyGems are required to use Jekyll and Bundler, so first make sure
you have those on your machine.

If you are using an OS packaged version of Ruby, you may also need to install
the ruby-dev (Ubuntu) or ruby-devel (Fedora) package as well to build any
native code for gems that are installed later. Installing these will also
ensure your system's RubyGems package is installed. Depending on your OS, you
may also need other packages to install/build gems, such as ruby-full, make,
gcc, nodejs, build-essentials, or patch.

Once Ruby, RubyGems, and any necessary native tools are installed, you are
ready to install [Bundler] to manage the remaining RubyGem dependencies.
Bundler is included in Ruby 2.6 and later as a default gem, so installing it
may not be needed.

Because we use [Bundler] to install specific versions of gems, it is not
recommended to use an OS packaged version of gems other than what comes
built-in. If you are using an OS packaged version of Ruby, it is __strongly__
recommended to avoid `sudo` when installing additional gems, in order to avoid
conflicting with your system's package-managed installation. Instead, you can
specify a `GEM_HOME` directory for installing gems locally in your home
directory. You can do this in your `$HOME/.bashrc` file or other appropriate
place for your environment:

```bash
# in .bashrc
export GEM_HOME=$HOME/.gem/ruby
```

With Ruby installed on your machine, you can install [Bundler] using the
command below:

```bash
# not necessary in Ruby >2.6, since it is a default gem since 2.6
gem install bundler
```

Next, use [Bundler] to install [Jekyll] and other dependencies needed to run
the website (this command assumes your current working directory is your clone
of this repository with the `master` branch checked out, because that's where
the Gemfile dependency list exists).

```bash
bundle install
```

### Testing with the Built-in Jekyll Webserver

The command to serve the site contents using Jekyll's built-in webserver is as
follows (this webserver may behave differently than apache.org's servers).

```bash
bundle exec jekyll serve -w
```

You do __NOT__ need to execute a `bundle exec jekyll build` command first, as
the `serve` command is sufficient to both build the site and serve its
contents. By default, it will also try to re-build any pages you change while
running the webserver, which can be quite useful if trying to get some CSS or
HTML styled "just right".

Jekyll will print a local URL where the site can be viewed (usually,
[http://0.0.0.0:4000/](http://0.0.0.0:4000/)).

## Publishing

### Automatic Staging

Changes pushed to our `master` branch will automatically trigger Jekyll to
build our site from that branch and push the result to our `asf-staging`
branch, where they will be served on [our default staging site][staging].

### Publishing Staging to Production

First, add our repository as a remote in your local clone, if you haven't
already done so (these commands assume the name of that remote is 'upstream').

Example:

```bash
git clone https://github.com/<yourusername>/accumulo-website
cd accumulo-website
git remote add upstream https://github.com/apache/accumulo-website
```

Next, publish the staging site to production by updating the `asf-site` branch
to match the contents in the `asf-staging` branch:

```bash
# Step 0: stay in master branch; you never need to switch
git checkout master

# Step 1: update your upstream remote
git remote update upstream

# Step 2: push upstream/asf-staging to upstream/asf-site
# run next command with --dry-run first to see what it will do without making changes
git push upstream upstream/asf-staging:asf-site
```

Note that Step 3 should always be a fast-forward merge. That is, there should
never be any reason to force-push it if everything is done correctly. If extra
commits are ever added to `asf-site` that are not present in `asf-staging`,
then those branches will need to be sync'd back up in order to continue
avoiding force pushes.

The final site can be viewed [here][production].


[Bundler]: https://bundler.io/
[Jekyll]: https://jekyllrb.com/
[Liquid]: https://jekyllrb.com/docs/liquid/
[kramdown]: https://kramdown.gettalong.org/
[production]: https://accumulo.apache.org
[staging]: https://accumulo.staged.apache.org
