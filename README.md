# Apache Accumulo Website

Apache Accumulo uses [Jekyll] to build their website. It is recommended that you
use [Bundler] to install the necessary dependencies to run and build the website.

## Install Bundler and dependencies

Ruby is required to use Bundler so first make sure you have Ruby on your machine.  If you are using
an OS packaged version of Ruby, you will have to also install the ruby-dev (Ubuntu) or 
ruby-devel (Fedora) package as well.

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

## Update the production website

For Apache Accumulo committers, the `asf-site` branch needs to be updated with the generated
HTML.

This can be done easily by invoking the post-commit hook (either by hand, or automatically via configuring
Git to invoke the post-commit hook).

`./_devtools/git-hooks/post-commit`

To automatically run this post-commit hook in your local repository, copy
the given file into your `.git/hook` directory:

    cp ./_devtools/git-hooks/post-commit .git/hooks/

[Jekyll]: https://jekyllrb.com/
[Bundler]: https://bundler.io/
