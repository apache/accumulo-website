# Apache Accumulo Website

Apache Accumulo uses [Jekyll] to build their website. It is recommended that you
use [Bundler] to install the necessary dependencies to run and build the website.

## Install Bundler and dependencies

Ruby is required to use Bundler so first make sure you have Ruby on your machine.  If you are using
an OS packaged version of Ruby, you will have to also install the ruby-dev (Ubuntu) or
ruby-devel (Fedora) package as well. Depending on your OS, you may also need other packages, such as
ruby-full, make, gcc, nodejs, build-essentials, or patch.

With Ruby installed on your machine, you can install [Bundler] using the command below:

    gem install bundler

Next, use [Bundler] to install [Jekyll] and other dependencies needed to run the website.

    git clone https://github.com/apache/accumulo-website
    cd accumulo-website
    bundle install

## Run the website locally

Run the following command to run the website locally using Jekyll's embedded webserver:

    cd accumulo-website
    bundle exec jekyll serve -w

The website can viewed at [http://0.0.0.0:4000/](http://0.0.0.0:4000/)

## Build website static HTML files

You can just build static HTML files which are viewable in `_config.yml`:

    cd accumulo-website
    bundle exec jekyll build

## Custom liquid tags

Custom liquid tags are used to make linking to javadocs, properties, and documents easier.
The source for these tags is at [_plugins/links.rb](_plugins/links.rb).

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

## Updating property documentation

Building Accumulo  generates `server-properties.md` and `client-properties.md`.  To
regenerate these, do the following.

```
cd <accumulo source dir>
mvn package -DskipTests
cp ./core/target/generated-docs/server-properties.md <accumulo website source>/_docs-2/configuration
cp ./core/target/generated-docs/client-properties.md <accumulo website source>/_docs-2/configuration
```

## Update the production website

For Apache Accumulo committers, the `asf-site` branch needs to be updated with the generated
HTML.  Changes to this branch are automagically mirrored to the website.

This can be done easily by invoking the post-commit hook (either by hand, or automatically via configuring
Git to invoke the post-commit hook).  The commands below are a guide for committers who wish to publish
the web site.

```bash
# ensure local asf-site branch is up to date
git checkout asf-site
git pull upstream asf-site

# switch to master branch, update it, and build new site
git checkout master
git pull upstream master
./_devtools/git-hooks/post-commit

# switch to asf-site, look at the commit created by post-commit script, and push it if ok
git checkout asf-site
git log -p
git push upstream asf-site
```
In the commands above `upstream` is :

```bash
$ git remote -v | grep upstream
upstream	https://gitbox.apache.org/repos/asf/accumulo-website/ (fetch)
upstream	https://gitbox.apache.org/repos/asf/accumulo-website/ (push)
```

To automatically run this post-commit hook in your local repository, copy
the given file into your `.git/hook` directory:

    cp ./_devtools/git-hooks/post-commit .git/hooks/

[Jekyll]: https://jekyllrb.com/
[Bundler]: https://bundler.io/
