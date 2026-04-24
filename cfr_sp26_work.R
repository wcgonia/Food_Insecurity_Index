library(dplyr)
library(ggplot2)
library(scales)
library(fitdistrplus)

#Loading all 6 csv files into one data frame

raw_data <- Reduce(function(x, y) merge(x, y, by = c("GEO_ID", "NAME")), 
                     lapply(list.files("C:/Users/Willi/OneDrive/Default/Laptop Desktop/cfr/Food Insecurity Index/Data Files", 
                                       pattern="\\.csv$", 
                                       full.names=TRUE), 
                            read.csv))

#Selecting only the columns that we need

data <- raw_data %>% dplyr::select(GEO_ID, NAME, Homeownership_Rate,Estimate.Black.Population.Ratio, Estimate.Hispanic.Population.Ratio,
                           Pov_Rate, B19013_001E, Disability_Rate, Unemployement_Rate)

#Creating the Food Insecurity "Rate" using Feeding America's weights from there technical brief

  #Normalizing the Median Income so that it can be on the same scale as rest of Data

data$B19013_001E_Normal <- (data$B19013_001E - min(data$B19013_001E))/(max(data$B19013_001E)- min(data$B19013_001E))

data$Food_Insecurity_Rate <- 0.091 + 0.337*data$Pov_Rate + .478*data$Unemployement_Rate -0.001*data$B19013_001E_Normal - 0.001*data$Estimate.Hispanic.Population.Ratio - 0.078*data$Estimate.Black.Population.Ratio - 0.059*data$Homeownership_Rate+ .190*data$Disability_Rate

data$FI_normal <-  (data$Food_Insecurity_Rate - min(data$Food_Insecurity_Rate))/(max(data$Food_Insecurity_Rate)- min(data$Food_Insecurity_Rate))

data$FI_log <- log(data$Food_Insecurity_Rate)

data$`Food Insecurity Index` <- cut(
  data$FI_log,
  breaks = seq(-2.9, -1.05, length.out = 11), # 10 bins
  labels = 1:10,
  include.lowest = TRUE
)

ggplot(data, aes(x = Food_Insecurity_Rate)) +
  geom_histogram(aes(y = after_stat(count / sum(count))),
                 fill = "#6B3FA0",
                 color = "black",
                 binwidth = 0.025, 
                 boundary = 0) +
  scale_x_continuous(limits = c(0, .5),
                    breaks = seq(0, .5, by = 0.05)) +
  labs(title = "Distribution of Model Output",
       x = "Model Output",
       y = "Relative Frequency") +
  theme_bw()+
  theme(
    plot.title    = element_text(color = "#4CAF50", face = "bold", size = 26,hjust = .5),
    axis.title    = element_text(color = "#4CAF50", face = "bold", size = 20),
    axis.text     = element_text(color = "#4CAF50", face = "bold", size = 20)
  )


FI_mean <- mean(data$Food_Insecurity_Rate)
FI_sd <- sd(data$Food_Insecurity_Rate)

log((FI_mean**2 / sqrt(FI_sd**2 + FI_mean**2)))
mean(data$FI_log)

sqrt(log((FI_sd**2 / FI_mean**2) +1))
sd(data$FI_log)

fit <- fitdist(data$Food_Insecurity_Rate, distr = "lnorm",method = "mle")
summary(fit)
plot(fit)


shapiro.test(data$Food_Insecurity_Rate)
shapiro.test(data$FI_log)


ggplot(data, aes(x = FI_log)) +
  geom_histogram(binwidth = 0.1) +
  scale_x_continuous(limits = c(-3, -1)) +
  labs(title = "Distribution of Variable",
       x = "Value (0–.5 Scale)",
       y = "Count") +
  theme_minimal()


data$`Food Insecurity Index` <- cut(
  data$FI_log,
  breaks = seq(-2.9, -1.05, length.out = 11), # 10 bins → 11 break points
  labels = 1:10,
  include.lowest = TRUE
)


ggplot(data, aes(x = `Food Insecurity Index`)) +
  geom_bar(
    fill = "#4CAF50",
    color = "#6B3FA0",
    width = 0.85
  )+
  scale_y_continuous(limits = c(0,35))+
  annotate("label",
           x = 8.5, y =34,                              # position on the plot
           label = "1 = Lowest Food Insecurity \n10 = Highest Food Insecurity",
           color = "#6B3FA0",
           fill = "white",
           fontface = "bold",
           size = 6
  )+
  labs(
    title = "Distribution of Food Insecurity Index",
    x = "Food Insecurity Index Value",
    y = "Number of Census Tracts"
  ) +
  theme_bw()+
  theme(
    plot.title    = element_text(color = "#6B3FA0", face = "bold", size = 26,hjust = .5),
    axis.title    = element_text(color = "#6B3FA0", face = "bold", size = 20),
    axis.text     = element_text(color = "#6B3FA0", face = "bold", size = 20)
  )


# Outputing to csv

Tract_Food_Insecurity_Index <- data %>%
  dplyr::select(GEO_ID,NAME,`Food Insecurity Index`)

#write.csv(Tract_Food_Insecurity_Index,"C:/Users/Willi/OneDrive/Default/Laptop Desktop/cfr/FA Model Copy/Food Insecurity Index Data.csv")

rate <- data %>%
  dplyr::select(GEO_ID, NAME, Food_Insecurity_Rate)
#write.csv(rate,"C:/Users/Willi/OneDrive/Default/Laptop Desktop/cfr/FA Model Copy/Food Insecurity Rate Esitmate.csv")

