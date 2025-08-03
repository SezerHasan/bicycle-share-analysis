# Data Directory

## Dataset Information

### Trips_2019_Q3.csv
- **Size**: ~215 MB
- **Records**: 1,640,718 bike share trips
- **Period**: Q3 2019 (July-September)
- **Source**: Bike Share Company

### Dataset Schema
| Column | Type | Description |
|--------|------|-------------|
| trip_id | Integer | Unique trip identifier |
| start_time | DateTime | Trip start timestamp |
| end_time | DateTime | Trip end timestamp |
| bikeid | Integer | Unique bike identifier |
| tripduration | Numeric | Trip duration in seconds |
| from_station_id | Integer | Starting station ID |
| from_station_name | String | Starting station name |
| to_station_id | Integer | Ending station ID |
| to_station_name | String | Ending station name |
| usertype | String | Customer or Subscriber |
| gender | String | User gender |
| birthyear | Integer | User birth year |

### Data Summary
- **Total Trips**: 1,640,718
- **Unique Bikes**: 5,787
- **Unique Stations**: 612
- **User Types**: 70% Subscribers, 30% Customers
- **Average Trip Duration**: 29 minutes

### Note
This large dataset file is excluded from GitHub due to size limitations (215MB > 100MB limit). 

**To run the analysis scripts, you'll need to:**
1. Obtain the dataset from the bike share company
2. Place `Trips_2019_Q3.csv` in this `data/` directory
3. Run the analysis scripts from the `scripts/` directory

### Sample Data
The first few rows of the dataset look like:
```
trip_id,start_time,end_time,bikeid,tripduration,from_station_id,from_station_name,to_station_id,to_station_name,usertype,gender,birthyear
23479388,2019-07-01 00:00:27,2019-07-01 00:20:41,3591,1214.0,117,Wilton Ave & Belmont Ave,497,Kimball Ave & Belmont Ave,Subscriber,Male,1992
23479389,2019-07-01 00:01:16,2019-07-01 00:18:44,5353,1048.0,381,Western Ave & Monroe St,203,Western Ave & 21st St,Customer,,
``` 