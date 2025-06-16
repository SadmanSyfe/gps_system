from bokeh.io import curdoc
from bokeh.models import ColumnDataSource
from bokeh.plotting import figure
from bokeh.models.tiles import WMTSTileSource

source = ColumnDataSource(data=dict(lat=[], lon=[]))

def wgs84_to_web_mercator(lon, lat):
    import math
    k = 6378137
    x = lon * (k * math.pi / 180.0)
    y = math.log(math.tan((90 + lat) * math.pi / 360.0)) * k
    return (x, y)

tile_url = 'https://tile.openstreetmap.org/{Z}/{X}/{Y}.png'
tile_provider = WMTSTileSource(url=tile_url)

p = figure(
    x_range=(0, 100), y_range=(0, 100),
    x_axis_type="mercator", y_axis_type="mercator",
    sizing_mode='stretch_both'
)
p.add_tile(tile_provider)

p.circle(x='lon', y='lat', size=10, fill_color="red", line_color="black", source=source)

def update_location(new_lat, new_lon):
    x, y = wgs84_to_web_mercator(new_lon, new_lat)
    new_data = dict(lat=[y], lon=[x])
    source.stream(new_data, rollover=50)

curdoc().add_root(p)
curdoc().title = "Live Rover Tracking"
curdoc().session_context.server_context.update_location = update_location
