import google.generativeai as genai

API_KEY = 'AIzaSyBTri6WtcfUhFaGi-2xGqZF6FAhJxqfSzA' 
genai.configure(api_key=API_KEY)

modeller = [
    'models/gemini-2.5-flash',
    'models/gemini-2.5-flash-lite',
    'models/gemini-flash-latest',
    'models/gemini-flash-lite-latest',
    'models/gemini-2.0-flash',
    'models/gemini-2.0-flash-001'
]

for m in modeller:
    try:
        model = genai.GenerativeModel(m)
        resp = model.generate_content("Merhaba de")
        print(f"BAŞARILI: {m} - Yanit: {resp.text}")
        break
    except Exception as e:
        print(f"HATA {m}: {e}")
