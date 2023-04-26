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
| ghc   | GitHub code link          | Branch defaults to `gh_branch` setting in `_config.yml`. Override using `-b` | `{% ghc server/tserver/src/main/java/org/apache/accumulo/tserver/TabletServer.java %}` `{% ghc -b 1.10 README.md %}` |
| jira   | Jira issue link          | None  | `{% jira ACCUMULO-1000 %}` |

### Updating Property Documentation for Releases

Building Accumulo  generates `server-properties.md` and `client-properties.md`.
To regenerate these, do the following.

```bash
ACCUMULO_SITE_CLONE=<accumulo website clone location, with main branch checked out>
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
of this repository with the `main` branch checked out, because that's where
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

### Testing using Docker environment 

A containerized development environment can be built using the local
Dockerfile.


A containerized development environment can be built using the local
Dockerfile. You can build it with the following command:

```bash
docker build -t webdev .
```

This action will produce a `webdev` image, with all the website's build
prerequisites preinstalled. When a container is run from this image, it
will perform a `jekyll serve` command with the polling option enabled,
so that changes you make locally will be immediately reflected.

When you run a container using the webdev image, your current working
directory will be mounted, so that any changes made by the build inside
the container will be reflected in your local workspace. This is done with
the `-v` flag. To run the container, execute the following command:

```bash
docker run -d -v "$PWD":/mnt/workdir -p 4000:4000 webdev
```

While this container is running, you will be able to review the rendered website
in your local browser at [http://127.0.0.1:4000/](http://127.0.0.1:4000/).


Shell access can be obtained by overriding the default container command.

This is useful for adding new gems, or modifying the Gemfile.lock for updating
existing dependencies.

When using shell access the local directory must be mounted to ensure
the Gemfile and Gemfile.lock updates are reflected in your local
environment so you can create a commit and submit a PR.

```bash
docker run -v "$PWD":/mnt/workdir -it webdev /bin/bash
```

## Publishing

Changes pushed to our `main` branch will automatically trigger Jekyll to
build our site from that branch and push the result to our `asf-site`
branch, where they will be served on [our production site][production].

[Bundler]: https://bundler.io/
[Jekyll]: https://jekyllrb.com/
[Liquid]: https://jekyllrb.com/docs/liquid/
[kramdown]: https://kramdown.gettalong.org/
[production]: https://accumulo.apache.org
