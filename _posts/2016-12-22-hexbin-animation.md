---
title: "Hexbin Animation"
author: "Robert Dinterman"
date: "December 22, 2016"
layout: post
output:
  md_document:
    variant: markdown_github
---






*This post was partly inspired by a [Bob Rudis hexbin state map post](https://rud.is/b/2015/05/15/u-s-drought-monitoring-with-hexbin-state-maps-in-r/) and thinking about this across time -- which is a great application of [David Robinson's gganimate package](https://github.com/dgrtwo/gganimate) in R.*

# Maps and Their Frustrations

A few months ago, I was struggling to understand a data problem. The specific problem isn't too important here, but it can be loosely characterized as trying to figure out how and why farmer bankruptcy rates vary across time and space. Before I started to think about what factors may cause bankruptcy rates to vary either spatially or temporally, I wanted to know what these bankruptcy rates looked like. The data that's available on this topic is from the [United States Courts](http://www.uscourts.gov/statistics-reports/caseload-statistics-data-tables?tn=&pn=All&t=38&m%5Bvalue%5D%5Bmonth%5D=&y%5Bvalue%5D%5Byear%5D=) website. There's a few different tables of information, but I had table F-2 data at the District level going back to 1997 Districts are basically States or sub-divisions of States and look as such:

![District Court Map](https://upload.wikimedia.org/wikipedia/commons/d/df/US_Court_of_Appeals_and_District_Court_map.svg)

Since I have District level data, my first inclination was to produce a [choropleth](https://bl.ocks.org/mbostock/4060606). My initial thoughts were:

1. Plotting raw count data is usually a bad idea because they generally mimic population density. I know that farms aren't distributed equally across the US, which already implies bankruptcies won't be equally distributed. The only reason I'm looking at bankruptcy rates is to evaluate the financial conditions of an area, I don't want a map of farm activity. So I need to put this in terms of rates.
2. In the same vein as above, I know a bit about [projections of spatial data](http://www4.ncsu.edu/~rdinter/Spatial/topic3.html). I need to try and present a visually pleasing representation of the United States and have visible states here. Something like an [Albers Projection](http://desktop.arcgis.com/en/arcmap/latest/map/projections/albers-equal-area-conic.htm) should be nice as it makes states proportional to the area they occupy.
3. As this is a choropleth, I need a color scale that reflects intensity well and is robust to all kinds of color blindness. Enter the [viridis scale](https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html) which is also a great package in R.

With all this in mind, my first crack at figuring out what bankruptcy rates look like I applied a few R techniques. Grab a county-level shapefile, aggregate the counties up to the district level, project the spatialpolygon to Albers, and plot the district level map. The end result seemed kind of nice:



This seems fine, although there really aren't that many farmer bankruptcy filings over time, so it's actually reasonable to check out what the total values would look like as opposed to the filing rates as above:



These are OK for a static representation of bankruptcies, which is what one would be limited to with an academic publication. But if you're presenting this stuff, well there's more information hidden in the data that these figures cannot convey.

# Animation

One thing that is lacking with these two maps is that they don't convey any temporal relationship. This would be fine if there wasn't much variation across time, except there is a fair amount due to changes in bankruptcies law. So because of this, I turned to the `gganimate` package to create a gif of bankruptcies over time:


![](../img/hexbin-animation-animate_albers.gif)

At first glance, I think this turns out to be a pretty good visualization for bankruptcies over time. We've got spatial and temporal variation and it's displayed in a manner that can convey them. But, does it really? The more I dug into the data the more I found this graphic to be misleading.

# Hexbins

If you've got an eagle eye, then you can spot Massachusetts in the animation above as an anomaly. But if you're a regular Joe like me, then this is hardly visible. In fact, because Massachusetts is such a small state you probably didn't even notice it. And it's true that there is not much farming in the Northeast, but the anomaly that is Massachusetts farmer bankruptcies remains even if number of farmers is accounted for.

This had me thinking, this is a scenario where I'd like to have each state equally represented but also preserve the rough spatial relationship. I had previously seen a blog post from [Bob Rudis](https://twitter.com/hrbrmstr) where he utilized hexbins with respect to drought conditions.

So why not apply this particular cartography technique, but to farmer bankruptcies to illustrate the problem that is Massachusetts? One valid argument is that the court districts are the level of interest here, so I'm going to have to sacrifice some accuracy in order to effectively point out the particular data issue related to Massachusetts.



Now, each state is equally represented and we can see that Massachuesetts is clearly high on the bankruptcy rates. But has this always been the case? Well not necessarily. So let's apply the animation methods with this hexbin map to get a clearer picture:



![](../img/hexbin-animation-hex-map-b_rates.gif)

And here, we get a nice picture of state level variation in farmer bankruptcy rates. Which was a lesson to me in recognizing that there's many ways to visualize your data. And this has had further implications for how I have decided to model farmer bankruptcy rates that I might not have considered before I fully devled into the data.

Hopefully you found this to be a helpful excerise.

*Source code for this specific .Rmd file can be found in my [github repository](https://github.com/rdinter/rdinter.github.io/blob/master/_drafts/nba-values.Rmd) while all the R code and data files necessary to reproduce these maps can be found in its [accompanying folder](https://github.com/rdinter/rdinter.github.io/tree/master/_drafts/hexbins) below that directory.*
