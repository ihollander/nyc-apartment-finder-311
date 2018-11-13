1. User logs in or creates account

Models:

User
Incident - name, location for mapping, created at, open or closed
Borough - name
UserBorough

Find your neighbourhood

1. User logs in or creates account

2. User enters work address to compute commute time.

3. user enters desired commute time

- query db to find ideal zips.

4. User selects from zips that are within commute time and what attributes are most desired
@zips = Incident.select(:zip).distinct.limit(20)
@criteria = some text we can translate using a switch statement to query Incidents
- Checkboxlist: select (max 5) zip codes
- 5 dropdowns of 'criteria' 
- query db to find ideal location based on params (each )

6. Matched neighbourhood is returned with option to view other neighbourhoods and the attributes that stoped a match.
- more info can be displayed etc..
- charts for results
2. User enters work address to compute commute time.

3. user enters desired commute time

 #### query db to find ideal zips.

4. User selects from boroughs that are within commute time.

5. User selects from drop downs what attributes are most desired (5 selections)

 #### query db to find ideal location based on params

6. Matched neighbourhood is returned with option to view other neighbourhoods and the attributes that stoped a match.
#### more info can be displayed etc..


#### charts for results

*BACK END*

#DONE

 User enters work address to compute commute time.

 user enters desired commute time

 Build a method to find zips within commute time and return array of cities in selection box
#TODO - get "city from zips to add to dropdown"
