---
title: "Introduction and first article"
layout: post
---

Hello, I always wanted to start writting about my experiences in coding. I have
been in one way or another coding professionally for just about 20 years. I have
been working professionaly with many languages, some stayed with me, others
banished in the history. I have worked on languages from Smalltalk to plain C,
C++ passing through C#, Go and now Java.

I think think that one of the best skills that a programmer has to have is the
ability to learn new things. Don't define yourself by a particular tech. Techs
come and go and you should addapt. As Bruce Lee once said, _be water my friend_.

So in this first article I am just want to talk about how I got setup to write
artices, a kind of meta-article if you will.

I decided to use Github pages because I wanted to write my articles with
markdown text and had plenty of experience doing markdown in Github. I used to
work on the [Google Cloud Visual Studio Extension][1] and everything in Github
one way or another is markdown.

The setup process is pretty straight forward until I tried to get the Jekyll
processor installed locally on my machine. I normally use a 2013 MacBook Pro to
do my hacking at home, which will have to take away from my cold dead hands,
because this machine rocks. The process to install Jekyll calls for using Ruby
gems, use bundler (which I don't know what it is) and more. You can see the
process as recommended by Github [here][2].

Well, the process failed miserably for me. One of the packages ([nokogirl][4])
requires a native extension which apprently failed to build. This just aborted
the setup process and now I have a bunch of ruby packages installed on my
machine and no functioning Jekyll installation. Bummer.

Since I wanted to be able to run the Jekyll site locally I resorted to what
anybody would these days, Docker. The Dockerhub has a very handy official [Ruby
image][3] that I used as the base for my image.

After that duplicating the setup instructions in my `Dockerfile` was really
easy:
```Dockerfile
# This file describe an active installation of Jekyll.
FROM ruby:2.4

# Install bundler.
RUN gem install bundler

# Install the dependencies.
ADD ./Gemfile /
RUN bundle install

# Export the port to preview sites.
EXPOSE 4000

# Done.
```

The `Gemfile` is exactly the one recommended by the Github pages documentation:
```
source 'https://rubygems.org'
gem 'github-pages', group: :jekyll_plugins
```

You can build this with:
```bash
docker build -t jekyll .
```

This will produce the `jekyll` image in your local Docker installation. And this
image is fully setup to run the pages locally. To get the Jekyll server up and
running you can start the container with:
```bash
docker run \
  -it \
  -p 4000:4000 \
  -v ${FULL_PATH_TO_REPO}/:/var/repo/:rw \
  --rm \
  --workdir /var/repo/ \
  jekyll \
  bundle exec jekyll serve --host 0.0.0.0
```       

Where `FULL_PATH_TO_REPO` will point to the full path of the local clone of your
pages repo. The `--host` parameter is necessary since by default the server will
listen on `127.0.0.1` only. That means only listening on connections coming from
the _inside_ of the container. This is a security measure, but it is preventing
us from reacing the server from outside of the container as we want to make it
listen on any host.

[1]: https://github.com/GoogleCloudPlatform/google-cloud-visualstudio
[2]: https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/#step-2-install-jekyll-using-bundler
[3]: https://github.com/docker-library/ruby/blob/3149de350c3bc540492a4331881b925e608c3abd/2.4/stretch/Dockerfile
[4]: https://github.com/sparklemotion/nokogiri
