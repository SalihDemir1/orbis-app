import google.generativeai as genai

API_KEY = 'AIzaSyBTri6WtcfUhFaGi-2xGqZF6FAhJxqfSzA' 
genai.configure(api_key=API_KEY)

print("Modeller Alınıyor...")
try:
    models = genai.list_models()
    for m in models:
        if 'generateContent' in m.supported_generation_methods:
            print(f"Deneme yapılıyor: {m.name}")
            try:
                model = genai.GenerativeModel(m.name)
                resp = model.generate_content("Merhaba de, kisa bir cevap ver.")
                print(f"--> BAŞARILI: {m.name} | Yanıt: {resp.text.strip()}")
            except Exception as e:
                print(f"--> HATA: {m.name} | {type(e).__name__}: {str(e)}")
except Exception as e:
    print(f"Genel Hata: {e}")
