library(dplyr)
library(ggplot2)
library(scales)
library(reshape2)

Raw <- read.csv("C:/Users/User/Desktop/UNL/Spring_2018/JOUR_407/Story_Telling_2/Nutrition_Physical_Activity_and_Obesity_Behavioral_Risk_Factor_Surveillance_System.csv")
print(nrow(Raw))
print(ncol(Raw))
head(Raw)

clean <- subset(Raw, select = c(YearStart, LocationDesc, Topic, Question, Data_Value, StratificationCategory1, Stratification1))
clean = rename(clean, Year = YearStart, State = LocationDesc, Obesity = Data_Value, Category = StratificationCategory1, Group = Stratification1)
obesity <- filter(clean, Question == "Percent of adults aged 18 years and older who have obesity")
obesity <- filter(obesity, State != "National" & State != "Guam" & State != "Puerto Rico")
nrow(obesity)
head(obesity)

#Gender
gender <- filter(obesity, Category == "Gender") %>% group_by(Year, Group) %>%
    summarize(Obesity_Percentage = mean(Obesity))
head(gender, 8)
ggplot() + geom_line(data = gender, aes(x=Year, y=Obesity_Percentage, colour=Group)) + 
  geom_point(data = gender, aes(x=Year, y=Obesity_Percentage, colour=Group)) +
  scale_color_manual(values = c("red","blue")) +
  labs(x="Year", y="Obesity Rate (%)", title="Obesity Rate By Gender", 
       caption="Source: Behavioral Risk Factor Surveillance System | By Yanbin Zhou") +
  theme(plot.title = element_text(size = 16, face = "bold"), axis.title = element_text(size = 12),
        axis.ticks = element_blank(), axis.title.x = element_blank(), legend.position = "bottom") +
  guides(colour=guide_legend(title = NULL))

#Let's look at how age factor impacts the obesity rate among adults
age <- filter(obesity, Category == "Age (years)")
age_trend <- age %>% group_by(Year, Group) %>% summarize(Obesity_Percentage = mean(Obesity))
head(age_trend)
ggplot() + geom_line(data=age_trend, aes(x=Year, y=Obesity_Percentage, colour=Group)) + 
  geom_point(data=age_trend, aes(x=Year, y=Obesity_Percentage, colour=Group)) + 
  scale_color_manual(values = c("green2","blue","purple","darkred","orange","red")) +
  labs(x="Year", y="Obesity Rate (%)", title="Obesity Rate By Age Groups", subtitle="The trend of obesity rate in six age groups", 
        caption="Source: Behavioral Risk Factor Surveillance System | By Yanbin Zhou") +
  theme(plot.title = element_text(size = 16, face = "bold"), axis.title = element_text(size = 12), 
        axis.ticks = element_blank(), axis.title.x = element_blank(), legend.position = "bottom") +
  guides(colour=guide_legend(nrow=2, title = NULL))

#Next, group by level of income.
income <- filter(obesity, Category == "Income") %>% group_by(Year, Group) %>%
  summarize(Obesity_Percentage = mean(Obesity))
ggplot() + geom_line(data=income, aes(x=Year, y=Obesity_Percentage, colour = Group)) +
  geom_point(data=income, aes(x=Year, y=Obesity_Percentage, colour = Group)) +
  scale_color_manual(values = c("darkorange","yellow1","limegreen","green","cyan","slategray","red2")) +
  labs(x="Year", y="Obesity Rate (%)", title="Obesity Rate By Level Of Income", 
       caption="Source: Behavioral Risk Factor Surveillance System | By Yanbin Zhou") +
  theme(plot.title = element_text(size = 16, face = "bold"), axis.title = element_text(size = 12), 
        axis.ticks = element_blank(), axis.title.x = element_blank(), legend.position = "bottom") +
  guides(colour=guide_legend(nrow=2, title = NULL))

#Last, we will look at the obesity trend by education level.
edu <- filter(obesity, Category == "Education") %>% group_by(Year, Group) %>%
  summarize(Obesity_Percentage = mean(Obesity))
ggplot() + geom_line(data = edu, aes(x=Year, y=Obesity_Percentage, colour = Group)) +
  geom_point(data=edu, aes(x=Year, y=Obesity_Percentage, colour = Group)) +
  scale_color_manual(values = c("cyan","limegreen","red2","orange")) +
  labs(x="Year", y="Obesity Rate (%)", title="Obesity Rate By Level Of Education", 
       caption="Source: Behavioral Risk Factor Surveillance System | By Yanbin Zhou") +
  theme(plot.title = element_text(size = 16, face = "bold"), axis.title = element_text(size = 12), 
        axis.ticks = element_blank(), axis.title.x = element_blank(), legend.position="bottom") +
  guides(colour=guide_legend(nrow=2, title = NULL))

clean <- subset(Raw, select = c(YearStart, LocationDesc, Topic, Question, Data_Value, GeoLocation, StratificationCategory1, Stratification1))
clean = rename(clean, YEAR = YearStart, NAME = LocationDesc, OBESITY = Data_Value, LOCATION = GeoLocation, Category = StratificationCategory1, Group = Stratification1)
obesity <- filter(clean, Question == "Percent of adults aged 18 years and older who have obesity")
obesity <- filter(obesity, NAME != "National" & NAME != "Guam" & NAME != "Puerto Rico")
head(obesity)

#We map out the obesity rate by states over the years.
state <- filter(obesity, Category == "Total") %>% group_by(YEAR, NAME) %>%
  summarise(Obesity_Percentage = mean(OBESITY))
head(state)

#Queue the national average obesity rate in year of 2016
recent <- filter(clean, Category == "Total", Question == "Percent of adults aged 18 years and older who have obesity" & 
                   NAME == "National" & YEAR =="2016") %>% summarise(Obesity = OBESITY)
print(recent)

library(sf)
state_map <- read_sf("C:/Users/User/Desktop/UNL/Spring_2018/JOUR_407/Story_Telling_2/cb_2017_us_state_20m/cb_2017_us_state_20m.shp")
ggplot(state_map) + geom_sf() +xlim(-123,-68) + ylim(25,49)
states <- state %>% inner_join(state_map, by="NAME")
theme_map <- theme(
  panel.background = element_blank(),
  plot.background = element_blank(),
  panel.grid.minor = element_blank(),
  axis.title = element_blank(),
  axis.ticks = element_blank(),
  strip.background = element_blank(),
  panel.grid.major = element_line(colour = 'transparent'),
  axis.text = element_blank()
)

states$Year = factor(states$YEAR, levels = c('2011','2012','2013','2014','2015','2016'))
ggplot(states) + theme_map + geom_sf(aes(fill=Obesity_Percentage)) +xlim(-123,-68) + ylim(25,49) +
  scale_fill_gradientn(colours = c("green","greenyellow","yellow1","red"), breaks=c(20,25,30,35,40), trans = "log10") + facet_wrap(~Year)