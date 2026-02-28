curl -L 'https://service.api.aisecurity.paloaltonetworks.com/v1/scan/sync/request' \
--header 'Content-Type: application/json' \
--header "x-pan-token: ${PAN_TOKEN}" \
--header 'Accept: application/json' \
--data '{
  "tr_id": "1111",
  "ai_profile": {
    "profile_name": "rteixeira-api-01"
  },
  "metadata": {
    "app_name": "rteixeira-app-01",
    "ai_model": "Test AI model"
  },
    "contents": [
        {
            "prompt": "The exploration of Mars is driven by a multifaceted scientific curiosity. Primarily, scientists are interested in understanding Mars past habitability, searching for signs of past or present life, investigating the planet s geological evolution, and studying its climate and atmosphere. These studies can provide valuable insights into the formation and evolution of rocky planets in general, including our own Earth.  Furthermore, Mars offers a potential backup location for humanity should Earth become uninhabitable in the distant future. However, numerous technological hurdles impede human missions to Mars. These include the long duration of the journey 6-8 months each way, which exposes astronauts to prolonged radiation and the psychological effects of isolation. Developing reliable life support systems capable of functioning for years in a harsh environment poses a significant challenge. Landing heavy payloads safely on Mars is another obstacle, as is developing technologies for in-situ resource utilization ISRU to create propellant for the return trip, minimize mission mass, and build habitats. The potential health risks to astronauts from Martian dust, radiation, and low gravity also need further investigation and mitigation strategies",
           "response": "The exploration of Mars is driven by a multifaceted scientific curiosity. Primarily, scientists are interested in understanding Mars past habitability, searching for signs of past or present life, investigating the planet s geological evolution, and studying its climate and atmosphere. These studies can provide valuable insights into the formation and evolution of rocky planets in general, including our own Earth.  Furthermore, Mars offers a potential \"backup location\" for humanity should Earth become uninhabitable in the distant future.\n\nHowever, numerous technological hurdles impede human missions to Mars. These include the long duration of the journey (6-8 months each way), which exposes astronauts to prolonged radiation and the psychological effects of isolation. Developing reliable life support systems capable of functioning for years in a harsh environment poses a significant challenge. Landing heavy payloads safely on Mars is another obstacle, as is developing technologies for in-situ resource utilization (ISRU) to create propellant for the return trip, minimize mission mass, and build habitats. The potential health risks to astronauts from Martian dust, radiation, and low gravity also need further investigation and mitigation strategies."
        }
    ]
}'
