
#upload API key
def get_api_key(filename):
    try:
        with open(filename, 'r') as f:
            API_KEY = f.read().strip()
    except:
        API_KEY = ''
    return(str(API_KEY).strip())
