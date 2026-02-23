from flask import Flask, request, jsonify
import requests
from bs4 import BeautifulSoup
import time
import random

app = Flask(__name__)

# User-Agents для обхода блокировок
USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
]

def search_duckduckgo(query):
    """Поиск через DuckDuckGo HTML"""
    try:
        # Формируем URL
        url = f"https://html.duckduckgo.com/html/?q={requests.utils.quote(query)}"
        
        # Случайный User-Agent
        headers = {
            'User-Agent': random.choice(USER_AGENTS),
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
            'Accept-Encoding': 'gzip, deflate',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        }
        
        # Задержка для избежания блокировки
        time.sleep(random.uniform(1, 3))
        
        # Запрос к DuckDuckGo
        response = requests.get(url, headers=headers, timeout=30)
        response.raise_for_status()
        
        # Парсинг HTML
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Извлечение результатов
        results = []
        result_elements = soup.find_all('div', class_='result')
        
        for result in result_elements[:10]:  # Ограничиваем 10 результатами
            try:
                title_elem = result.find('a', class_='result__title')
                snippet_elem = result.find('a', class_='result__snippet')
                url_elem = result.find('a', class_='result__url')
                
                if title_elem and snippet_elem:
                    results.append({
                        'title': title_elem.text.strip(),
                        'snippet': snippet_elem.text.strip()[:200],
                        'url': url_elem.text.strip() if url_elem else '',
                        'source': 'duckduckgo'
                    })
            except:
                continue
        
        return results
        
    except Exception as e:
        print(f"Ошибка поиска DuckDuckGo: {e}")
        return []

def search_instant_answer(query):
    """Поиск через DuckDuckGo Instant Answer API"""
    try:
        url = f"https://api.duckduckgo.com/?q={requests.utils.quote(query)}&format=json&no_html=1&skip_disambig=1"
        
        headers = {
            'User-Agent': random.choice(USER_AGENTS),
            'Accept': 'application/json',
        }
        
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()
        
        data = response.json()
        
        results = []
        
        # Abstract (краткое описание)
        if data.get('Abstract'):
            results.append({
                'title': data.get('Heading', query),
                'snippet': data['Abstract'][:300],
                'url': data.get('AbstractURL', ''),
                'source': 'duckduckgo_instant'
            })
        
        # Related Topics
        for topic in data.get('RelatedTopics', [])[:5]:
            if isinstance(topic, dict) and 'Text' in topic:
                results.append({
                    'title': topic.get('FirstURL', '').split('/')[-1].replace('_', ' '),
                    'snippet': topic['Text'][:200],
                    'url': topic.get('FirstURL', ''),
                    'source': 'duckduckgo_related'
                })
        
        return results
        
    except Exception as e:
        print(f"Ошибка Instant Answer API: {e}")
        return []

@app.route('/search', methods=['GET'])
def search():
    """Основной endpoint поиска"""
    query = request.args.get('q', '')
    
    if not query:
        return jsonify({'error': 'Параметр q обязателен'}), 400
    
    print(f"Поиск: {query}")
    
    # Пробуем оба метода
    results = []
    
    # Сначала Instant Answer (быстрее)
    instant_results = search_instant_answer(query)
    results.extend(instant_results)
    
    # Если мало результатов, пробуем HTML парсинг
    if len(results) < 3:
        html_results = search_duckduckgo(query)
        results.extend(html_results)
    
    # Убираем дубликаты
    unique_results = []
    seen_urls = set()
    
    for result in results:
        if result['url'] and result['url'] not in seen_urls:
            seen_urls.add(result['url'])
            unique_results.append(result)
    
    # Если всё ещё нет результатов, возвращаем заглушку
    if not unique_results:
        unique_results = [{
            'title': f'Результаты по запросу "{query}"',
            'snippet': 'Попробуйте уточнить запрос или повторить позже.',
            'url': f'https://duckduckgo.com/?q={requests.utils.quote(query)}',
            'source': 'fallback'
        }]
    
    return jsonify({
        'query': query,
        'results': unique_results[:10],  # Ограничиваем 10 результатами
        'count': len(unique_results),
        'timestamp': time.time()
    })

@app.route('/health', methods=['GET'])
def health():
    """Проверка здоровья сервиса"""
    return jsonify({'status': 'OK', 'service': 'duckduckgo-proxy'})

if __name__ == '__main__':
    print("🚀 DuckDuckGo Proxy запущен на порту 8000")
    app.run(host='0.0.0.0', port=8000, debug=False)