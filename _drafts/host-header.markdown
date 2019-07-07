---
title: "Good Old HOST header."
layout: post
categories: [ blog ]
tags: [ gcp, gae, http ]
---

As I play with App Engine and Google Cloud in general one of the things that
worry me the most is to keep the cost down to a minimums ince I am playing with
GCP for my own enjoyment and I have one user (myself).

To save costs then I have a single service (the default service) and always have
only one single version deployed to that service. To save costs this version
consists of a single instance. This means that I only pay for a single VM, which
depending on the size of the chosen VM can even be free.

GCP will give you one `f1-micro` instance per month as part of the [free
tier][0] and you can take advantage of that and use it as the VM for your App
Engine deployment.

Of course I like to play with different services so I had to find a solution so
I could use a single VM but still run multiple services on it. As I mentioned
before reliability was not a big concern for me since this is all for play so
having the single VM for all services was ok.

So what I needed was a way for me to multiplex multiple services running in a
single server. What I did was to write my own mini HTTP server that would
redirect requests to ther services also running on the same box. This is all
very reminiscent of [cgi][1].

The trick was on how the server would know where to send the request and that is
where the `Host` HTTP header comes into place. What I ended up doing is buying
cheap domains, for something like $10 a year or so. My server accepts a config
file that maps the possible values of the `Host` header into what processes need
to be run.

### The Host header
The `Host` header is part of the [HTTP 1.1][2] spec and it must be added by the
client in every request. My server checks the value against the map stored in
the config and then it just redirects to the right process.

App Engine allows you to associate as many custom domains to your project as you
want and it will even give you SSL certificates for free for those domains, see
[my previous post][3] for full details on this.

The `Host` header is an old mechanism developed to allow hosts to host multiple
websites and it is a perfectly valid mechanism to use today to share resources
between varous microservices.

[0]: https://cloud.google.com/free/
[1]: https://en.wikipedia.org/wiki/Common_Gateway_Interface
[2]: https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.23
[3]: {% link _posts/2019-07-07-htsts.markdown %}
