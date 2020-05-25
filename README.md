# Solar Mapping Project
*this project is in progress*
### Three years ago...
...I started this project in MATLAB and worked with a team to get visualization of prime solar locations across the entire U.S. using a heat map. However, I could not make the final breakthrough--my skills in MATLAB at the time were more limited and the interpolation failed time and again to produce decent results. The final visualization was resorted to Tableau, with dot size/color and county colors representing the annual total solar influx.

### Recently...
...I realized that I had now learned in R everything I needed to fill the gaps. In addition, I have also gained skill through GIS of different types of interpolation meant for spatial methods. With these skills combined, I can finally go back and create the entire project from scratch. As a Climate Data Scientist, I can see it in my head... I want to share that image with the entire community.

##### Work So Far
- Utilized Python to wrangle all 959 files--strip the double header and repeat several individual values as column vectors
- Imported all into R tibble dataframe like using row bind
- Added column names
- Combined a few columns to create a Date type column
- Get a better idea of the dataframe with introduce, gather, and spread
- Visualize distribution of the Year column--all values were labelled Typical, meaning Typical Meteorological Year (TMY)
- Convert the dataframe to a long format to prep for facet_wrap() plotting
- Attempt to aggregate all variables and sum/mean values where appropriate, according to the Month
- Dataframe is too large to do this (~400MB, aggregating increases size to over 7.5GB)

##### Work to Do
- Decrease size of the dataframe prior to aggregating 
  - Pull out each variable along with Month in a separate dataframe
  - Aggregate each along the Month to create a 2x12 array (mean for most variables, sum for solar variables)
    - Mean wind per month makes sense, sum does not
    - Total solar energy in a month makes sense, mean does not (emphasizing total energy production over the average received)
  - Column bind back together using Month as the joining column
- With size decreased drastically... (~526,000 observations per variable to 12 [minutes per year vs months])
  - Can continue with planned facet plots
  - Line plots of each variable along with a line of best fit and variance around the line
- Continue by diving primarily into DNI (Direct Normal Irradiance) and potentially into DHI (Diffuse Horizontal Irradiance)
  - Could also consider GHI (Global Horizontal Irradiance)
  - Geolocate all the DNI points (Annual total to start, could also explore Annual mean to compare difference)
  - Plot on map with size/color indicating DNI strength
- Final plans
  - Interpolate all 959 geolocated DNI values most likely using Kriging interpolation 
      - Could also look into effectiveness of KNN (k-Nearest Neighbor) interpolation, Spline interpolation
  - Utilize a heat map plotted on the US map [similar to here](https://www.prnewswire.com/news-releases/doximity-helps-physicians-navigate-their-careers-with-first-ever-local-compensation-map-300026248.html)
  - Animate through the 12 months with gganimate()
  - Share final conclusions
 
### Similar Image...
...from my past work in Climate Science utilizing MATLAB, [found here](https://github.com/jtoepp/computational-methods).
![test](https://github.com/jtoepp/computational-methods/blob/master/Project%201/Figures/Figure%203.jpg)**Figure 1:** Calculated global Theta-e
