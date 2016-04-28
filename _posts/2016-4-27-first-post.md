---
layout: post
title: First post, building this website.
---

This is my first post, which will be about my experience _building_ [sic] this website through the unbelievably easy to follow [readme](https://github.com/daattali/beautiful-jekyll#readme) by [Dean Attali](http://deanattali.com/). The first step was to go to the GitHub page for [beautiful-jekyll](https://github.com/daattali/beautiful-jekyll) and forked the repository. After this I changed the name of the repository to [rdinter.github.io](http://rdinter.github.io/) et viola! The whole thing was up and running ... although it looked exactly the same as the [demo](http://deanattali.com/beautiful-jekyll/). I clearly needed to do a few updates.

My first few tasks that I undertook:

1. Change the [_config.yml](https://github.com/rdinter/rdinter.github.io/blob/master/_config.yml) file so that my name and social media information is up to date (note to self: probably should sign up for a few more social media services). Also, I put a rough template of what the navigation for the website should look like in that file which is discussed in 4. This was based off of [my previous website](http://www4.ncsu.edu/~rdinter/) hosted at NC State, which had become too cumbersome to update and why I am creating this.
2. Create a new project in [rstudio](https://www.rstudio.com/) where I had previously connected my GitHub account to. I needed to grab the ssh key from the newly created [GitHub repository](https://github.com/rdinter/rdinter.github.io) this is hosted in. This helps in that I can mold this website right from a browser because I have rstudio running on a server.

    Here's a blog post from [the molecular ecologist](http://www.molecularecologist.com/2013/11/using-github-with-r-and-rstudio/) on how to get r, rstudio, and GitHub to sync up together. And [yhat](http://blog.yhat.com/posts/r-in-the-cloud-part-1.html) has a post on how to set up an rstudio server with Amazon's EC2, which can be easily adapted to wherever you want the server hosted.
3. Clean up some things that will be unnecessary for my website, this means I need to adapt the readme file to my liking, update the main index.html, add in a Google Analytics tracker, sign up for a Disqus account to allow commenting on here, and delete blog posts while starting this first post to document the experience.
4. Put placeholders in `.md` files or folders for the intended structure of the site from 1. This entailed files for research and aboutme, which are in the main (root?) folder. But for my more comprehensive teaching section, this needed to be a folder because there are multiple courses I have taught. This was a bit puzzling to accomplish, but so long as each folder includes an `index.md` file then I can link to the folder instead of a `.md` file.

I found looking through the GitHub repositories of others who have used this template is helpful. In particular, [Derek Ogle](https://github.com/droglenc/droglenc.github.io) maintains a great website with all the code related to this hosted on his GitHub. Looking through some of his code helps me in recognizing some of the intricacies of organizing a website.

Some things I found helpful:

* The first few lines on any page that I want rendered on the site follows YAML, which I think stands for yet-another-markup-language. This thing took a while to figure out, but when I wanted to add an image of Philips Arena to the front page I needed to include a snippet of `bigimg: "/img/philips.jpg"` in that first bit. This took me way longer than it ever needed to because Dean lists all the [YAML parameters](https://github.com/daattali/beautiful-jekyll#yaml-front-matter-parameters) for this theme.
* If you want to link across pages, then it takes the folder form. If you link to another page within the same folder, then call that page (ie `page2` will call for `page2.md` in the same folder). This also works for folders so long as an `index.md` exists. But if you want to call a page in a subfolder? Then you need to have the path (ie `fold/page2` is needed if the folder `fold` is in current page's folder).

This is a good stopping point for a first post, now I'll need to populate my website with more content. I will also need to figure out how to potentially host this on a different domain and how to connect other GitHub repositories to the site.