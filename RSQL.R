library(RSQLite)
conn <- dbConnect(RSQLite::SQLite(),"DBNAME.sqlite")
wc <- read.csv("world_cities.csv")
bss <- read.csv("bike_sharing_systems.csv")
cwf <- read.csv("cities_weather_forecast.csv")
sbs <- read.csv("seoul_bike_sharing.csv")
dbWriteTable(conn, "WORLD_CITIES", wc)
dbWriteTable(conn, "BIKE_SHARING_SYSTEMS", bss)
dbWriteTable(conn, "CITIES_WEATHER_FORECAST", cwf)
dbWriteTable(conn, "SEOUL_BIKE_SHARING", sbs)
dbListTables(conn)
#Determine how many records are in the seoul_bike_sharing dataset.
query = "SELECT COUNT(*) FROM SEOUL_BIKE_SHARING"
dbGetQuery(conn,query)
#Determine how many hours had non-zero rented bike count.
query = "SELECT COUNT(HOUR) FROM SEOUL_BIKE_SHARING WHERE RENTED_BIKE_COUNT != 0"
dbGetQuery(conn,query)
#Recall that the records in the CITIES_WEATHER_FORECAST dataset are 3 hours apart, so we just need the first record from the query.
query = "SELECT * FROM CITIES_WEATHER_FORECAST LIMIT 1"
dbGetQuery(conn,query)
#Find which seasons are included in the seoul bike sharing dataset.
query = "SELECT DISTINCT(SEASONS) FROM SEOUL_BIKE_SHARING"
dbGetQuery(conn,query)
#Find the first and last dates in the Seoul Bike Sharing dataset.
query = "SELECT MIN(DATE), MAX(DATE) FROM SEOUL_BIKE_SHARING"
dbGetQuery(conn,query)
#determine which date and hour had the most bike rentals.
query = "SELECT DATE, HOUR FROM SEOUL_BIKE_SHARING WHERE RENTED_BIKE_COUNT = (SELECT MAX(RENTED_BIKE_COUNT) FROM SEOUL_BIKE_SHARING)"
dbGetQuery(conn,query)
#Determine the average hourly temperature and the average number of bike rentals per hour over each season. List the top ten results by average bike count.
query = "SELECT AVG(TEMPERATURE), AVG(RENTED_BIKE_COUNT), SEASONS FROM SEOUL_BIKE_SHARING GROUP BY SEASONS ORDER BY AVG(RENTED_BIKE_COUNT) LIMIT 10"
dbGetQuery(conn,query)
#Find the average hourly bike count during each season.
query = "SELECT MAX(RENTED_BIKE_COUNT), MIN(RENTED_BIKE_COUNT), SQRT(AVG(RENTED_BIKE_COUNT*RENTED_BIKE_COUNT) - AVG(RENTED_BIKE_COUNT)*AVG(RENTED_BIKE_COUNT)) AS SD, SEASONS FROM SEOUL_BIKE_SHARING GROUP BY SEASONS"
dbGetQuery(conn,query)
#Consider the weather over each season. On average, what were the TEMPERATURE, HUMIDITY, WIND_SPEED, VISIBILITY, DEW_POINT_TEMPERATURE, SOLAR_RADIATION, RAINFALL, and SNOWFALL per season?
query = "SELECT AVG(TEMPERATURE), AVG(HUMIDITY), AVG(WIND_SPEED), AVG(VISIBILITY), AVG(DEW_POINT_TEMPERATURE), AVG(SOLAR_RADIATION), AVG(RAINFALL), AVG(SNOWFALL), SEASONS FROM SEOUL_BIKE_SHARING GROUP BY SEASONS"
dbGetQuery(conn,query)
#Use an implicit join across the WORLD_CITIES and the BIKE_SHARING_SYSTEMS tables to determine the total number of bikes avaialble in Seoul, plus the following city information about Seoul: CITY, COUNTRY, LAT, LON, POPULATION, in a single view.
query = "SELECT SUM(BICYCLES), B.CITY, W.COUNTRY, LAT, LNG, POPULATION FROM BIKE_SHARING_SYSTEMS B INNER JOIN WORLD_CITIES W ON B.CITY = W.CITY WHERE B.CITY LIKE 'SEOUL'"
dbGetQuery(conn,query)
#Find all cities with total bike counts between 15000 and 20000. Return the city and country names, plus the coordinates (LAT, LNG), population, and number of bicycles for each city.
query = "SELECT B.CITY, B.COUNTRY, LAT, LNG, POPULATION, BICYCLES FROM BIKE_SHARING_SYSTEMS B INNER JOIN WORLD_CITIES W ON B.CITY = W.CITY WHERE B.BICYCLES BETWEEN 15000 AND 20000"
dbGetQuery(conn,query)





