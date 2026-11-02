import google.generativeai as genai
import time

genai.configure(api_key='AIzaSyBTri6WtcfUhFaGi-2xGqZF6FAhJxqfSzA')

modeller = [
    'models/gemini-2.5-pro',
    'models/gemini-pro-latest',
    'models/gemini-flash-lite-latest',
    'models/gemini-2.0-flash-lite-001',
    'models/gemma-3-4b-it'
]

with open('api_results.txt', 'w', encoding='utf-8') as f:
    for m in modeller:
        try:
            model = genai.GenerativeModel(m)
            out = model.generate_content("nasılsın")
            f.write(f"BASARILI: {m} - {out.text.strip()[:20]}\n")
            print(f"Calisan model bulundu: {m}")
        except Exception as e:
            f.write(f"HATA: {m} - {type(e).__name__}\n")
            print(f"Hata: {m}")
        time.sleep(2)
