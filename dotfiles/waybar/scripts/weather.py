#!/usr/bin/env python
import json
import requests
import os
import time
from datetime import datetime, date

# Existing configuration
API_KEY = "YOUR-TOKENs"
UNITS = "metric"
LANG = "de"
MULTI_LOCATION_CACHE_FILE = "/tmp/weather_multi_cache.json"
REQUESTS_FILE = "/tmp/weather_requests.json"
MAX_REQUESTS_PER_DAY = 800
CACHE_EXPIRY = 3 * 900 # ... * 15 Minuten

# Weather Icons Mapping (unchanged)
weather_icons = {
    "01d": "☀️", "01n": "🌙", "02d": "🌤️", "02n": "🌤️",
    "03d": "☁️", "03n": "☁️", "04d": "☁️", "04n": "☁️",
    "09d": "🌧️", "09n": "🌧️", "10d": "🌦️", "10n": "🌦️",
    "11d": "⛈️", "11n": "⛈️", "13d": "🌨️", "13n": "🌨️",
    "50d": "🌫️", "50n": "🌫️"
}

def load_request_count():
    """Load daily API request count"""
    if os.path.exists(REQUESTS_FILE):
        try:
            with open(REQUESTS_FILE, "r") as file:
                data = json.load(file)
                if data.get("date") == str(date.today()):
                    return data.get("count", 0)
        except json.JSONDecodeError:
            pass
    return 0

def update_request_count():
    """Update daily API request count"""
    count = load_request_count() + 1
    with open(REQUESTS_FILE, "w") as file:
        json.dump({
            "date": str(date.today()),
            "count": count
        }, file)
    return count

def check_request_limit():
    """Check if daily request limit is reached"""
    return load_request_count() >= MAX_REQUESTS_PER_DAY

def load_multi_location_cache():
    """Load weather cache for multiple locations"""
    if os.path.exists(MULTI_LOCATION_CACHE_FILE):
        try:
            with open(MULTI_LOCATION_CACHE_FILE, "r") as file:
                return json.load(file)
        except json.JSONDecodeError:
            return {}
    return {}

def save_multi_location_cache(cache_data):
    """Save weather cache for multiple locations"""
    with open(MULTI_LOCATION_CACHE_FILE, "w") as file:
        json.dump(cache_data, file)

def get_location():
    """Retrieve location details via IP geolocation"""
    try:
        response = requests.get("http://ip-api.com/json/")
        data = response.json()
        return {
            "lat": data["lat"],
            "lon": data["lon"],
            "city": data.get("city", "Unknown"),
            "country": data.get("country", "Unknown"),
            "region": data.get("regionName", "Unknown")
        }
    except Exception as e:
        print(json.dumps({
            "text": "❌",
            "tooltip": f"Location Error: {str(e)}"
        }))
        exit(1)

def get_weather():
    """Fetch weather data with request limiting and enhanced caching"""
    location_info = get_location()
    location_key = f"{location_info['lat']}_{location_info['lon']}"

    multi_cache = load_multi_location_cache()
    cached_entry = multi_cache.get(location_key, {})

    # Return cached data if within expiry
    if cached_entry and time.time() - cached_entry.get('timestamp', 0) < CACHE_EXPIRY:
        return cached_entry['data'], location_info

    # Check request limit
    if check_request_limit():
        if cached_entry:
            # Return cached data with warning
            cached_entry['data']['request_limit_reached'] = True
            return cached_entry['data'], location_info
        else:
            print(json.dumps({
                "text": "⚠️",
                "tooltip": "API request limit reached for today"
            }))
            exit(1)

    try:
        weather_url = (
            f"https://api.openweathermap.org/data/3.0/onecall"
            f"?lat={location_info['lat']}"
            f"&lon={location_info['lon']}"
            f"&appid={API_KEY}"
            f"&units={UNITS}"
            f"&lang={LANG}"
        )
        weather_response = requests.get(weather_url)
        weather_data = weather_response.json()

        if weather_response.status_code != 200 or 'current' not in weather_data:
            raise ValueError(f"API Error: {weather_data.get('message', 'Unknown error')}")

        # Update request count before making API call
        update_request_count()

        multi_cache[location_key] = {
            'data': weather_data,
            'timestamp': time.time(),
            'location': location_info
        }
        save_multi_location_cache(multi_cache)

        return weather_data, location_info

    except Exception as e:
        if cached_entry:
            return cached_entry['data'], location_info

        print(json.dumps({
            "text": "❌",
            "tooltip": f"Weather Error: {str(e)}"
        }))
        exit(1)

def format_hourly_forecast(forecast_data):
    """Format hourly forecast"""
    forecast_text = "\n\nStündliche Vorhersage:"
    for item in forecast_data[:8]:
        time_str = datetime.fromtimestamp(item['dt']).strftime('%H:%M')
        temp = round(item['temp'])
        prob = round(item.get('pop', 0) * 100)
        forecast_text += f"\n{time_str}: {temp}°C ({prob}% ☔)"
    return forecast_text

def main():
    weather_data, location_info = get_weather()

    # Add warning if request limit was reached
    request_limit_warning = ""
    if weather_data.get('request_limit_reached'):
        request_limit_warning = "\n⚠️ API request limit reached - showing cached data"

    current = weather_data['current']
    temp = round(current['temp'])
    feels_like = round(current['feels_like'])
    humidity = current['humidity']
    wind_speed = round(current['wind_speed'] * 3.6)
    description = current['weather'][0]['description']
    icon_code = current['weather'][0]['icon']
    icon = weather_icons.get(icon_code, "❓")

    tooltip_text = (
        f"📍 {location_info['city']}, {location_info['region']}, {location_info['country']}"
        f"{request_limit_warning}\n"
        f"<span size='xx-large'>{temp}°C</span>\n"
        f"<big>{icon} {description.capitalize()}</big>\n"
        f"Gefühlte: {feels_like}°C\n"
        f"Feuchtigkeit: {humidity}%\n"
        f"Wind: {wind_speed} km/h"
        f"{format_hourly_forecast(weather_data.get('hourly', []))}"
    )

    output = {
        "text": f"{icon} {temp}°C",
        "alt": description,
        "tooltip": tooltip_text,
        "class": icon_code
    }

    print(json.dumps(output))

if __name__ == "__main__":
    main()
