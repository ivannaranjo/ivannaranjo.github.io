Hi, I have been working on sofware development for 20 years now and I have some
stories to tell. This is my blog, where I will tell stories, talk about
technologies that I am passionate about and pretty much anything that tickles my
fancy.

This is also my very first experience with [Jekyll][1] (the system that Github pages
use), so please excuse me as I work this out.

List of posts:<br>
<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
      {{ post.excerpt }}
    </li>
  {% endfor %}
</ul>

[1]: https://jekyllrb.com/
