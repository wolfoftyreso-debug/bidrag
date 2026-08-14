# API

Publik V1 är avsiktligt minimal: `POST /v1/analyze` (bild + valfri GPS →
läsning, svensk översättning, confidence, osäkerheter, källor). Kontraktet
finns i `openapi.yaml` och inkluderar abstention som eget svar (`422`) —
hellre "Otillräcklig bildkvalitet" än en falskt säker översättning.

Interna endpoints (`/vision/detect`, `/vision/read`, `/knowledge/retrieve`,
`/interpret`, `/verify`) är separata och exponeras aldrig publikt.

Backend byggs från början för research mode (rune candidates, alternativa
läsningar, källor per steg) utan att kärnan behöver byggas om.
