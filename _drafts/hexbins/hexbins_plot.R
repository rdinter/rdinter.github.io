# You may need to install some packages in R, to do so use "install.packages()"
# install.packages(c("tidyvese", "devtools", "maptools",
#                    "rgdal", "scales", "viridis", "sp"))
# devtools::install_github("hrbrmstr/albersusa")
# devtools::install_github("dgrtwo/gganimate")

# ---- Start --------------------------------------------------------------

library(tidyverse)

banks  <- read_csv("f2_judicial.csv")
county <- read_csv("NASS_farms_county.csv")
dists  <- read_csv("district_counties.csv")

dists <- dists %>%
  group_by(STATE) %>% 
  summarise(STATE_DISTS = n_distinct(DISTRICT)) %>% 
  right_join(dists)

# Merge in with county level data, then aggregate to district level
county <- county %>% 
  mutate(acres = agland / agland_per_acre) %>% 
  select(FIPS, YEAR, farms = FARMS, agland, acres) %>% 
  left_join(dists)

j5 <- county %>% 
  group_by(YEAR, DISTRICT, STATE, STATE_DISTS, CIRCUIT) %>% 
  summarise(farms = sum(farms, na.rm = T),
            acres = sum(acres, na.rm = T),
            agland = sum(agland, na.rm = T)) %>% 
  filter(YEAR == 2007) %>% 
  ungroup()

# Need to add in a row for DC:
j5 <- j5 %>% 
  bind_rows(data.frame(YEAR = 2007, DISTRICT = "DISTRICT OF COLUMBIA",
                       STATE = "DISTRICT OF COLUMBIA", STATE_DISTS = 1,
                       CIRCUIT = "DC CIRCUIT", farms = 100,
                       acres = 100, agland = NA))

j5 <- j5 %>% 
  select(-YEAR) %>% 
  right_join(banks)


# ---- Albers -------------------------------------------------------------

library(albersusa)
library(maptools)
library(sp)
library(spdplyr)
library(viridis)
library(scales)

first <- counties_composite("aeqd")

first <- merge(first, dists, by.x = "fips", by.y = "FIPS")

first_districts <- unionSpatialPolygons(first, first$DISTRICT)
states_map      <- unionSpatialPolygons(first, first$STATE)
circuit_map     <- unionSpatialPolygons(first, first$CIRCUIT)

gg_base <- fortify(first_districts) %>%
  rename(DISTRICT = id)

# Add in aggregated data ...
gg_first <- j5 %>% 
  group_by(DISTRICT) %>% 
  summarise(b_rate = (10000/20)*sum(CHAP_12, na.rm = T) /
              mean(farms, na.rm = T),
            CHAP_12 = sum(CHAP_12, na.rm = T),
            farms  = mean(farms, na.rm = T),
            acres  = mean(acres, na.rm = T)) %>%
  right_join(gg_base)

gg_state   <- fortify(states_map)
gg_circuit <- fortify(circuit_map)

ggplot(gg_first, aes(long, lat, group = group)) +
  geom_polygon(aes(fill = b_rate), color = "black") +
  geom_path(data = gg_state, color = "white") +
  labs(title = "Farmer Bankruptcies filed per 10,000 farms", 
       subtitle = "Annualized across 1997 to 2016") +
  scale_fill_viridis(limits = c(0, 10), oob = squish) +
  theme(panel.background = element_blank(), # remove various background facets
        panel.grid = element_blank(),
        axis.line = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = "bottom", # move the legend
        legend.title = element_blank(), #remove the legend's title
        legend.key.width = unit(2, "cm"),
        legend.text = element_text(size = 14),
        plot.title = element_text(size = 20),
        plot.subtitle = element_text(size = 14))
#ggsave("albers_static.png", width = 13.3, height = 10)

# ---- Albers-Count -------------------------------------------------------

ggplot(gg_first, aes(long, lat, group = group)) +
  geom_polygon(aes(fill = CHAP_12), color = "black") +
  geom_path(data = gg_state, color = "white") +
  labs(title = "Total Farmer Bankruptcies Filed", 
       subtitle = "From 1997 to 2016") +
  scale_fill_viridis(limits = c(0, 400), oob = squish) +
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.line = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.key.width = unit(2, "cm"),
        legend.text = element_text(size = 14),
        plot.title = element_text(size = 20),
        plot.subtitle = element_text(size = 14))
#ggsave("albers_static_raw.png", width = 13.3, height = 10)


# ---- Animate-Albers -----------------------------------------------------

# Animate ..., uncomment below if you don't have the gganimate package
# devtools::install_github("dgrtwo/gganimate")
library(gganimate) # this package makes the .gif by utilizing "frame"

gg_anime <- j5 %>% 
  group_by(DISTRICT, FISCAL_YEAR) %>% 
  summarise(b_rate = (10000)*sum(CHAP_12, na.rm = T) /
              mean(farms, na.rm = T),
            farms  = mean(farms, na.rm = T),
            acres  = mean(acres, na.rm = T)) %>%
  right_join(gg_base)

anim <- ggplot(gg_anime, aes(long, lat, group = group)) +
  geom_polygon(aes(fill = b_rate, frame = FISCAL_YEAR), color = "black") +
  geom_path(data = gg_state, color = "white") +
  labs(title = "Bankruptcies filed in", 
       subtitle = "Annualized per 10,000 farms") +
  scale_fill_viridis(limits = c(0,10), oob = squish) +
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.line = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.key.width = unit(2, "cm"),
        legend.text = element_text(size = 14),
        plot.title = element_text(size = 20),
        plot.subtitle = element_text(size = 14))
gg_animate(anim)

# ---- Maps ---------------------------------------------------------------

library(rgdal)

us      <- readOGR("usa_hex.geojson", "OGRGeoJSON")
centers <- cbind.data.frame(coordinates(us), as.character(us$st_abb))
names(centers) <- c("x", "y", "id")

us_map  <- fortify(us, region = "st_abb")
us_map$ST_ABRV <- us_map$id

banks_state <- j5 %>% 
  select(STATE, FISCAL_YEAR, TOTAL_FILINGS:NB_CHAP13, farms) %>% 
  group_by(FISCAL_YEAR, STATE) %>% 
  summarise_all(funs(sum(., na.rm = T))) %>% 
  mutate(ST_ABRV = state.abb[match(STATE, toupper(state.name))],
         ST_ABRV = ifelse(STATE == "DISTRICT OF COLUMBIA", "DC", ST_ABRV))

hex_map_data <- as.tbl(us_map) %>%
  full_join(banks_state) %>%
  left_join(centers) %>%
  filter(!is.na(long))

hex_map_data %>% 
  group_by(long, lat, order, hole, piece, id, group, ST_ABRV, STATE, x, y) %>% 
  summarise_all(funs(sum(., na.rm = T))) %>% 
  arrange(order) %>% 
  ggplot(aes(long, lat)) +
  geom_polygon(aes(group = group, fill = 10000*CHAP_12 / farms),
               colour = "white") +
  geom_text(aes(label = id, x = x, y = y), color = "white", size = 4) +
  labs(title = "Bankruptcies filed across 1997 to 2016", 
       subtitle = "Annualized per 10,000 farms") +
  scale_fill_viridis(limits = c(0,10), oob = squish) +
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.line = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.key.width = unit(2, "cm"),
        legend.text = element_text(size = 12))

# ---- Animate-Ugly -------------------------------------------------------

p <- ggplot(hex_map_data, aes(long, lat, frame = FISCAL_YEAR)) +
  geom_polygon(aes(group = group, fill = 10000*CHAP_12 / farms),
               colour = "white") +
  geom_text(aes(label = id, x = x, y = y), color = "white", size = 4)
gg_animate(p)

# ---- Animate ------------------------------------------------------------

p <- ggplot(hex_map_data, aes(long, lat, frame = FISCAL_YEAR)) +
  geom_polygon(aes(group = group, fill = 10000*CHAP_12 / farms),
               colour = "white") +
  geom_text(aes(label = id, x = x, y = y), color = "white", size = 4) +
  labs(title = "Bankruptcies filed in",
       subtitle = "Annualized per 10,000 farms") +
  scale_fill_viridis(limits = c(0,10), oob = squish) +
  theme(panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.line = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.key.width = unit(2, "cm"),
        legend.text = element_text(size = 14),
        plot.title = element_text(size = 20),
        plot.subtitle = element_text(size = 14))
gg_animate(p)