from fastapi import FastAPI
import psutil

app = FastAPI()


@app.get("/")
@app.get("/")
def battery():
    batt = psutil.sensors_battery()

    return {
        "battery": batt.percent,
        "plugged": batt.power_plugged,
        "secsleft": batt.secsleft
    }
