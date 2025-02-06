import osmnx as ox
import geopandas as gpd

# Define the place (Metro Manila, Philippines)
place_name = "Metro Manila, Philippines"

# Query OpenStreetMap for schools and universities in Metro Manila
schools = ox.features_from_place(place_name, tags={"amenity": ["school", "university"]})

# Extract coordinates for points and centroids for polygons
schools["latitude"] = schools.geometry.centroid.y
schools["longitude"] = schools.geometry.centroid.x

# Add city column
schools["city"] = "Metro Manila"

# Select relevant columns
schools = schools[["name", "city", "latitude", "longitude", "geometry"]]

# Save to GeoJSON and CSV
schools.to_file("manila_schools.geojson", driver="GeoJSON")
schools.to_csv("manila_schools.csv")

print("Dataset saved: manila_schools.geojson and manila_schools.csv")