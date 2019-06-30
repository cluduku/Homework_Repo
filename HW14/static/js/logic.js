//*****************************************************************************************************
// Name: Chike Uduku
//HW #: 14
//******************************************************************************************************

// Creating map object
var map = L.map("map", {
  center: [34.0522, -118.2437],
  zoom: 11
});

// Adding tile layer
L.tileLayer("https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}", {
  attribution: "Map data &copy; <a href=\"https://www.openstreetmap.org/\">OpenStreetMap</a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"https://www.mapbox.com/\">Mapbox</a>",
  maxZoom: 18,
  id: "mapbox.streets",
  accessToken: API_KEY
}).addTo(map);

var link = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson";

var plateLink = "https://raw.githubusercontent.com/fraxen/tectonicplates/master/GeoJSON/PB2002_boundaries.json"

//Creator: Chike Uduku
//Created: 06/29/2019
//Desc: This function assigns a color to the marker circles drawn on the map, based on magnitude of earthquake
//Revision:1.0
function GetColor(mag)
{
  var color ="";
  if(mag >= 0 && mag  < 1)
  {
    color = "lime";
  }
  else if(mag >= 1 && mag  < 2)
  {
    color = "limegreen";
  }
  else if(mag >= 2 && mag  < 3)
  {
    color = "gold";
  }
  else if(mag >= 3 && mag  < 4)
  {
    color = "GoldenRod";
  }
  else if(mag >= 4 && mag  < 5)
  {
    color = "saddlebrown";
  }
  else
  {
    color = "Maroon";
  }
  return color;
}

// Grabbing our GeoJSON data..
d3.json(link, function(data) {
  // Creating a GeoJSON layer with the retrieved data
  L.geoJson(data,{
    onEachFeature: function(feature,layer)
    {
      if(feature.properties.mag > 0)
      {
      //draw circles
        L.circle([feature.geometry.coordinates[1], feature.geometry.coordinates[0]], {
        color: GetColor(feature.properties.mag),
        fillColor: GetColor(feature.properties.mag),
        fillOpacity: 0.75,
        radius: feature.properties.mag * 1000
        }).bindPopup("<h1>" + feature.properties.place + "</h1> <hr> <h3>Mag: " + feature.properties.mag + "</h3>").addTo(map);
      }
    }
  });

  //Add legend
  var legend = L.control({position: 'bottomright'});
  legend.onAdd = function (map) {

    var div = L.DomUtil.create('div', 'info legend'),
    grades = [0, 1, 2, 3, 4, 5],
    labels = [];

    // loop through our magnitude intervals and generate a label with a colored square for each interval
    for (var i = 0; i < grades.length; i++) {
        div.innerHTML +=
            '<i style="background:' + GetColor(grades[i]) + '"></i> ' +
            grades[i] + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+');
    }

    return div;
};

legend.addTo(map);
});