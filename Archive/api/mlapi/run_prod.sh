curl -iLX 'GET' \
 'https://sudhrity.mids-w255.com/predict' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"text": ["I love you."]}'
echo

