import google.generativeai as genai

genai.configure(api_key='AIzaSyBTri6WtcfUhFaGi-2xGqZF6FAhJxqfSzA')
modeller = [
    'models/gemini-flash-latest',
    'models/gemini-flash-lite-latest',
    'models/gemini-2.5-flash-lite',
    'models/gemini-2.0-flash-001'
]

with open('result.txt', 'w', encoding='utf-8') as f:
    for m in modeller:
        try:
            resp = genai.GenerativeModel(m).generate_content("naber")
            f.write(f"OK: {m} -> {resp.text.strip()}\n")
            print(f"BULDUM: {m}")
            break
        except Exception as e:
            f.write(f"FAIL: {m} -> {e}\n")
