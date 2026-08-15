# API

Publik V1 är avsiktligt minimal: `POST /v1/analyze` (bild + valfri GPS →
läsning, svensk översättning, confidence, osäkerheter, källor). Kontraktet
finns i `openapi.yaml` och inkluderar abstention som eget svar (`422`) —
hellre "Otillräcklig bildkvalitet" än en falskt säker översättning.

Interna endpoints (`/vision/detect`, `/vision/read`, `/knowledge/retrieve`,
`/interpret`, `/verify`) är separata och exponeras aldrig publikt.

Backend byggs från början för research mode (rune candidates, alternativa
läsningar, källor per steg) utan att kärnan behöver byggas om.

## Implementerat (orkestrering v0.1)

| Modul | Gör |
|---|---|
| `pipeline.py` | `AnalyzePipeline`: reader → retrieval → verifiering → översättning → confidence per steg. Aggregerad confidence är **minimum** av mätbara steg (maskerar aldrig svag komponent); omätbara steg (image quality, detection) är `null`, inte påhittade. Identifiering presenteras endast när verifieringen bekräftat den — mismatch ger aldrig stone_id/källa (§19). Med samtycke byggs en validerad Atlas-fältobservation per analys (ADR-0006) |
| `readers.py` | Pluggbar runläsare: `null` (ingen modell — abstainar ärligt), `http_vlm` (Gemma/vLLM via baseline-adaptern, gör API:et skarpt körbart), `MockReader` för tester |
| `server.py` | Stdlib-HTTP-server: `POST /v1/analyze` (JSON med `image_b64`; multipart kommer med mobilklienten) + interna `/knowledge/retrieve`, `/verify`, `/interpret`, `GET /healthz`. Observationer appenderas till JSONL-sänka (produktionslagring: PostgreSQL enligt `deployment/`) |

```bash
python3 server.py --corpus <corpus-dir> --port 8080 --reader null \
  --observations observations.jsonl
python3 -m unittest discover -s tests   # 20 tester
```

Utan konfigurerad läsare svarar API:et 422 med orsak och rekommendation på
varje bild — hellre det än en fabricerad läsning. Med `--reader http_vlm`
(+ `VLM_ENDPOINT`/`VLM_MODEL`) körs hela kedjan skarpt.
