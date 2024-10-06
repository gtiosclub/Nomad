# Nomad
Fall 2024 Project

Tech Leads: Nick Candello, Rik Roy

Senior Developers: Austin Huguenard, Datta Kansal, Shaunak Karnik

# Design Info
Figma Link: https://www.figma.com/design/VVrrXAWspLEOhcyuR1ehLV/General-Meeting-Mockup?node-id=2058-9&node-type=canvas&t=FXT8dot8J4nS2Bi5-0

# Subteams
- Navigation: Jaehun, Karen, Rudra, Aryan, Ira, Vignesh
- Itinerary Planning: Neel, Brayden, Ling, Amber, Dahyun
- AI Assistant: Ganden, Connor, Yingqi, Ethan
- Recap: Angela, Daira, Nithyaa
- Firebase: Shlok, Alec, Vidhi

# Claiming an Issue
When claiming an issue, assign yourself as a contributor and create a branch with the issue number as a prefix. You can do this easily by clicking **Create a branch** under the *Development* section within the issue. Make sure that your branch source is accurate. All of your work should be completed on this new branch.


# Mapbox Setup

In order to properly set up Mapbox, you will need the store a Mapbox secret token into ```~/.netrc```, following the steps below

## Step 1: Check if you have already created a .netrc file on your computer.

1. Go to your home directory.
2. Type file .netrc into your terminal and see if anything returns.
3. If you have a .netrc file already, append the file linked below into your current ```~/.netrc```.

## Step 2: Create the .netrc file.

1. Open up your terminal in your home directory.
2. Type touch .netrc.

## Step 3: Open the .netrc file.
1. Type open .netrc from the same terminal window from Step 2

## Step 4: Add login instructions in to netrc
To setup credentials for the SDK, add the following to your .netrc file

```
machine api.mapbox.com
login mapbox
password sk.eyJ1Ijoidmlnc2sxNyIsImEiOiJjbTE4cW9obXEweHp0MmxtejU4am05d3M5In0.9q4B3Ds8_VYsye4wAslhPg
```

## Step 5: Set .netrc file permissions

1. Go to your home directory: /Users/[CurrentUser].
2. If you do not see the .netrc file, press Command + Shift + .(the period key).
3. Right click on the .netrc.
4. Click Get Info.
5. Scroll down to Sharing & Permissions.
6. Under your current username, make sure to set Privilege to Read & Write.

# Navigation How-To's (this will change over time to reflect future work)
Here is a quick summary of how the structure of the map and navigation scheme will operate, and how you should interact with it. 

## Models
- **NomadRoute**: This is the custom data type we will use for our routes. This is where all information related to a route is stored, including the information for each **Step** of the route.
- **Step** (defined within NomadRoute.swift): This type defines a single step of a route (i.e. "Turn right in 0.5 miles at Techwood Pkwy). You can find the shape of the step (MKPolyline), descriptions of the instruction, or exit numbers here.

## Adding/Removing View Components to the Map
- **Markers**: You should always add/remove a marker from the map using the *showMarker* and *removeMarker* functions in the view model. You can customize the title of the marker, location, and icon displayed with it.
- **Polylines**: You should always add/remove a polyline from the map using the *showPolyline* and *removePolyline* functions in the view model. The input to these functions is a **Step**, since polylines are always displayed after route generation.

## Generating Routes
- You can generate a route by adding **Waypoint**s using *addWaypoint* in the view model. There are other functions to modify or remove waypoints, also. Once you add/update/remove a waypoint, a route is automatically generated/regenerated.
- Adding waypoints is currently done by entering locations in the *LocationSearchBox* at the bottom of *MapView* and clicking the blue icon to the right.
