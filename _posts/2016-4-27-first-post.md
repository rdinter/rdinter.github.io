---
layout: post
title: First post, building this website.
---

This is my first post, which will be about my experience building (sic.) this website through the unbelievably easy to follow [readme](https://github.com/daattali/beautiful-jekyll#readme) by [Dean Attali](http://deanattali.com/). So far, I went to the GitHub page for [beautiful-jekyll](https://github.com/daattali/beautiful-jekyll) and forked the repository. After this I changed the name of the repository to [rdinter.github.io](http://rdinter.github.io/) and viola! The whole thing was up and running...although it looked exactly the same as the [demo](http://deanattali.com/beautiful-jekyll/), so I clearly needed to do a few updates. My first few snippets:

1. Change the [_config.yml](https://github.com/rdinter/rdinter.github.io/blob/master/_config.yml) file so that my name and social media information is up to date (note to self: probably should sign up for a few more social media services). Also, I put a rough template of what the navigation for the website should look like. This was based off of [my previous website](http://www4.ncsu.edu/~rdinter/) hosted at NC State, which had become too cumbersome to update.
2. Create a new project in [rstudio](https://www.rstudio.com/) where I had previously connected my GitHub account to the server I run rstudio off of. I needed to grab the ssh key from the [GitHub repository](https://github.com/rdinter/rdinter.github.io) this is hosted in. But now, I can start molding this website right from a browser running rstudio server.
3. Clean up some things that will be unnecessary for my webpage, this means I need to adapt the readme file to my liking, delete blog posts (while starting this first post to document the experience...this is very meta), update the index.html, add in a Google Analytics tracker, sign up for a Disqus account and add it, 
4.

I found looking through the GitHub repositories of others who have used this template is helpful. In particular, [Derek Ogle](https://github.com/droglenc/droglenc.github.io) is a great website and cool to recognize some of the intricacies of organizing the website. Some things I found helpful:

* The first few lines on any page that I want rendered on the site follows YAML, which I think stands for yet-another-markup-language. This thing took a while to figure out, but when I wanted to add an image of Philips Arena to the front page I needed to include a snippet of `img: philips.jpg` in that first bit.
