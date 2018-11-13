1. User logs in or creates account

Models:

User
Incident - name, location for mapping, created at, open or closed
Borough - name
UserBorough

Find your neighbourhood

1. User logs in or creates account

2. User enters work address and desired commute time

- query db to find neighborhoods within range

4. User selects from neighborhoods that are within commute time and what attributes are most desired
- Checkboxlist: select (max 5) zip codes
- 5 dropdowns of 'criteria' 
- query db to find ideal location based on params (each )

6. Matched neighbourhoods are returned along with stats and map.
- more info can be displayed etc..
- charts for results

7. User selects a neighborhood from matches

8. Display the listings from zillow that match that neighborhood
