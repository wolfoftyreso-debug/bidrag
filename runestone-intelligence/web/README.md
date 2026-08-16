# Web — kartdemo

`map.html` är demo-klienten för Runestone Atlas-kartan (Mapbox GL JS):

- Alla stenar med position som markörer; **avbockade** (fotade) stenar visas
  gröna. Avbockningen lagras kontolöst i `localStorage` (V1: inga konton)
  och skickas som `seen`-lista till `POST /v1/map`.
- Popup per sten: foto (endast bilder med redistributionsrätt — licensspärr
  i `atlas/mapview.py`), attribution, källa, modern översättning samt
  **Vägbeskrivning** (Google/Apple Maps-djuplänkar; i appen ersätts de av
  Mapbox Directions med samma koordinater).
- Geolocate-kontroll för "du är här".

## Körning

```bash
python3 api/server.py --corpus <corpus-dir> --port 8080
# öppna: http://localhost:8080/map?token=pk.<mapbox-public-token>
```

Mapbox-token är en publik klient-token och skickas via `?token=` (eller
prompt). API-origin kan overridas med `?api=`.

Detta är en referensklient — mobilappens kartvy byggs nativt men mot exakt
samma feed (`POST /v1/map` → GeoJSON FeatureCollection med `visited`,
`photo`, `own_photos`, `directions`).
