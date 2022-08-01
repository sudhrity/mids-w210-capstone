

################################################################################
################################################################################
################################################################################
 

# estimatesData <- fread('C:/Users/crort/OneDrive/Desktop/W210Capstone/mids-w210-capstone/webapp/Estimates.csv')

areastart <- data.frame(grass=0.54,tree=0.32,water=0.02,soil=0.12,turf=0.001)
areaEnd <- data.frame(grass=0.23,tree=0.18,water=0.04,soil=0.12,turf=0.001)

usedModel <- subset(estimatesData, subset = model == 'RFDay')

y1Day = areastart$grass*usedModel$grassEstimate + 
  areastart$tree * usedModel$treeEstimate +
  areastart$water * usedModel$waterEstimate +
  areastart$soil * usedModel$soilEstimate +
  areastart$turf * usedModel$turfEstimate

y2Day = areaEnd$grass*usedModel$grassEstimate + 
  areaEnd$tree * usedModel$treeEstimate +
  areaEnd$water * usedModel$waterEstimate +
  areaEnd$soil * usedModel$soilEstimate +
  areaEnd$turf * usedModel$turfEstimate

ytotalDay <- y2Day-y1Day

y1MaxDay = areastart$grass*usedModel$grassMax + 
  areastart$tree * usedModel$treeMax +
  areastart$water * usedModel$waterMax +
  areastart$soil * usedModel$soilMax +
  areastart$turf * usedModel$turfMax

y2MaxDay = areaEnd$grass*usedModel$grassMax + 
  areaEnd$tree * usedModel$treeMax +
  areaEnd$water * usedModel$waterMax +
  areaEnd$soil * usedModel$soilMax +
  areaEnd$turf * usedModel$turfMax

ytotalMaxDay <- y2MaxDay-y1MaxDay

y1MinDay = areastart$grass*usedModel$grassMin + 
  areastart$tree * usedModel$treeMin +
  areastart$water * usedModel$waterMin +
  areastart$soil * usedModel$soilMin +
  areastart$turf * usedModel$turfMin

y2MinDay = areaEnd$grass*usedModel$grassMin + 
  areaEnd$tree * usedModel$treeMin +
  areaEnd$water * usedModel$waterMin +
  areaEnd$soil * usedModel$soilMin +
  areaEnd$turf * usedModel$turfMin

ytotalMinDay <- y2MinDay-y1MinDay

usedModel <- subset(estimatesData, subset = model == 'RFNight')

y1Night = areastart$grass*usedModel$grassEstimate + 
  areastart$tree * usedModel$treeEstimate +
  areastart$water * usedModel$waterEstimate +
  areastart$soil * usedModel$soilEstimate +
  areastart$turf * usedModel$turfEstimate

y2Night = areaEnd$grass*usedModel$grassEstimate + 
  areaEnd$tree * usedModel$treeEstimate +
  areaEnd$water * usedModel$waterEstimate +
  areaEnd$soil * usedModel$soilEstimate +
  areaEnd$turf * usedModel$turfEstimate

ytotalNight <- y2Night-y1Night

y1MaxNight = areastart$grass*usedModel$grassMax + 
  areastart$tree * usedModel$treeMax +
  areastart$water * usedModel$waterMax +
  areastart$soil * usedModel$soilMax +
  areastart$turf * usedModel$turfMax

y2MaxNight = areaEnd$grass*usedModel$grassMax + 
  areaEnd$tree * usedModel$treeMax +
  areaEnd$water * usedModel$waterMax +
  areaEnd$soil * usedModel$soilMax +
  areaEnd$turf * usedModel$turfMax

ytotalMaxNight <- y2MaxNight-y1MaxNight

y1MinNight = areastart$grass*usedModel$grassMin + 
  areastart$tree * usedModel$treeMin +
  areastart$water * usedModel$waterMin +
  areastart$soil * usedModel$soilMin +
  areastart$turf * usedModel$turfMin

y2MinNight = areaEnd$grass*usedModel$grassMin + 
  areaEnd$tree * usedModel$treeMin +
  areaEnd$water * usedModel$waterMin +
  areaEnd$soil * usedModel$soilMin +
  areaEnd$turf * usedModel$turfMin

ytotalMinNight <- y2MinNight-y1MinNight

print("Estimated Microclimate Impacts")
print("Daytime average temperature effect (in degrees Celsius)")
print(paste0("5%: ", ytotalMinDay, " / Estimate: ",ytotalDay, " / 95%: ", ytotalMaxDay))
print("Night-time average temperature effect (in degrees Celsius)")
print(paste0("5%: ", ytotalMinNight, " / Estimate: ",ytotalNight, " / 95%: ", ytotalMaxNight))








