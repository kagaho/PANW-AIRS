curl -L 'https://service.api.aisecurity.paloaltonetworks.com/v1/scan/async/request' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H "x-pan-token: ${PAN_TOKEN}" \
-d '[
 {
   "req_id": 1,
   "scan_req": {
     "tr_id": "2882",
     "ai_profile": {
       "profile_name": "rteixeira-api-01"
     },
     "metadata": {
       "app_name": "rteixeira-app-01",
       "ai_model": "demo-model"
     },
     "contents": [
       {
         "prompt": "How long was the last touchdown?",
         "response": "The last touchdown was 15 yards",
         "context": "Hoping to rebound from their tough overtime road loss to the Raiders, the Jets went home for a Week 8 duel with the Kansas City Chiefs.  In the first quarter, New York took flight as QB Brett Favre completed an 18-yard TD pass to RB Leon Washington.  In the second quarter, the Chiefs tied the game as QB Tyler Thigpen completed a 19-yard TD pass to TE Tony Gonzalez.  The Jets would answer with Washington getting a 60-yard TD run.  Kansas City closed out the half as Thigpen completed an 11-yard TD pass to WR Mark Bradley. In the third quarter, the Chiefs took the lead as kicker Connor Barth nailed a 30-yard field goal, yet New York replied with RB Thomas Jones getting a 1-yard TD run.  In the fourth quarter, Kansas City got the lead again as CB Brandon Flowers returned an interception 91 yards for a touchdown.  Fortunately, the Jets pulled out the win with Favre completing the game-winning 15-yard TD pass to WR Laveranues Coles. During halftime, the Jets celebrated the 40th anniversary of their Super Bowl III championship team."
       }
     ]
   }
 },
 {
   "req_id": 2,
   "scan_req": {
     "tr_id": "2082",
     "ai_profile": {
       "profile_name": "rteixeira-api-01"
     },
     "metadata": {
       "app_name": "rteixeira-app-01",
       "ai_model": "demo-model-2"
     },
     "contents": [
       {
         "prompt": "How long was the last touchdown?",
         "response": "Salary of John Smith is $100K",
         "context": "Hoping to rebound from their tough overtime road loss to the Raiders, the Jets went home for a Week 8 duel with the Kansas City Chiefs.  In the first quarter, New York took flight as QB Brett Favre completed an 18-yard TD pass to RB Leon Washington.  In the second quarter, the Chiefs tied the game as QB Tyler Thigpen completed a 19-yard TD pass to TE Tony Gonzalez.  The Jets would answer with Washington getting a 60-yard TD run.  Kansas City closed out the half as Thigpen completed an 11-yard TD pass to WR Mark Bradley. In the third quarter, the Chiefs took the lead as kicker Connor Barth nailed a 30-yard field goal, yet New York replied with RB Thomas Jones getting a 1-yard TD run.  In the fourth quarter, Kansas City got the lead again as CB Brandon Flowers returned an interception 91 yards for a touchdown.  Fortunately, the Jets pulled out the win with Favre completing the game-winning 15-yard TD pass to WR Laveranues Coles. During halftime, the Jets celebrated the 40th anniversary of their Super Bowl III championship team."
       }
     ]
   }
 }
]' | jq
