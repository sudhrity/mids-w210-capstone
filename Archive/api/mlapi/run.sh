curl -X 'POST' \
 'localhost:8000/predict' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"text": ["I hate you.", "I love you."]}'

curl -X 'GET' \
 'localhost:8000/predict' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"text": ["I love you."]}'

curl -iLX 'GET' \
 'https://sudhrity.mids-w255.com/predict' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"text": ["I love you."]}'

