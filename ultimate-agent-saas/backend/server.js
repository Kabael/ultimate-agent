const express = require('express');
const path = require('path');
const { Client } = require('pg');
const TelegramBot = require('node-telegram-bot-api');
const { google } = require('googleapis');
const axios = require('axios');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Статические файлы (для launch.html)
app.use(express.static(path.join(__dirname, 'public')));

// База данных
const db = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Telegram бот
const bot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: true });

// Google Sheets API
const sheets = google.sheets({ version: 'v4', auth: process.env.GOOGLE_SHEETS_API_KEY });

// Подключение к БД
db.connect()
  .then(() => console.log('✅ Подключено к PostgreSQL'))
  .catch(err => console.error('❌ Ошибка подключения к БД:', err));

// Создание таблицы клиентов
db.query(`
  CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    telegram_chat_id BIGINT UNIQUE,
    articles TEXT[],
    google_sheet_id TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
  )
`).catch(err => console.error('❌ Ошибка создания таблицы:', err));

// API Endpoints

// Проверка здоровья
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Создание нового клиента
app.post('/api/create-client', async (req, res) => {
  try {
    const { articles, telegramChatId } = req.body;
    
    // Создаём Google Sheets таблицу
    const spreadsheet = await sheets.spreadsheets.create({
      requestBody: {
        properties: {
          title: `Ultimate Agent - Клиент ${telegramChatId || 'Новый'}`,
          locale: 'ru_RU',
          timeZone: 'Europe/Moscow'
        },
        sheets: [
          {
            properties: {
              title: 'Дашборд',
              sheetType: 'GRID'
            }
          },
          {
            properties: {
              title: 'Отзывы',
              sheetType: 'GRID'
            }
          },
          {
            properties: {
              title: 'Финансы',
              sheetType: 'GRID'
            }
          }
        ]
      }
    });

    const sheetId = spreadsheet.data.spreadsheetId;
    const sheetUrl = `https://docs.google.com/spreadsheets/d/${sheetId}`;

    // Сохраняем клиента в БД
    const result = await db.query(
      'INSERT INTO clients (telegram_chat_id, articles, google_sheet_id) VALUES ($1, $2, $3) RETURNING id',
      [telegramChatId, articles || [], sheetId]
    );

    // Активируем n8n workflow через вебхук
    await axios.post(`${process.env.N8N_WEBHOOK_URL || 'http://n8n:5678'}/webhook/client-created`, {
      clientId: result.rows[0].id,
      telegramChatId,
      sheetId,
      articles
    });

    // Отправляем приветственное сообщение в Telegram
    if (telegramChatId) {
      await bot.sendMessage(telegramChatId, 
        `🎉 Добро пожаловать в Ultimate Agent Platform!\n\n` +
        `📊 Ваша таблица: ${sheetUrl}\n` +
        `📱 Отслеживаем артикулы: ${articles?.join(', ') || 'не указаны'}\n\n` +
        `Команды:\n` +
        `/articles - изменить артикулы\n` +
        `/status - текущий статус\n` +
        `/help - помощь`
      );
    }

    res.json({
      success: true,
      clientId: result.rows[0].id,
      sheetUrl,
      message: telegramChatId ? 'Сообщение отправлено в Telegram' : 'Клиент создан'
    });

  } catch (error) {
    console.error('❌ Ошибка создания клиента:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Получение информации о клиенте
app.get('/api/client/:id', async (req, res) => {
  try {
    const result = await db.query(
      'SELECT * FROM clients WHERE id = $1',
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Клиент не найден' });
    }

    res.json({ success: true, client: result.rows[0] });
  } catch (error) {
    console.error('❌ Ошибка получения клиента:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Вебхук от n8n
app.post('/api/webhook/n8n', async (req, res) => {
  try {
    const { event, data } = req.body;
    
    switch (event) {
      case 'new_review':
        // Отправляем уведомление о новом отзыве
        const client = await db.query(
          'SELECT telegram_chat_id FROM clients WHERE id = $1',
          [data.clientId]
        );
        
        if (client.rows[0]?.telegram_chat_id) {
          await bot.sendMessage(client.rows[0].telegram_chat_id,
            `📝 Новый отзыв на артикул ${data.article}:\n` +
            `Рейтинг: ${data.rating}/5\n` +
            `Текст: ${data.text?.substring(0, 200)}...`
          );
        }
        break;

      case 'financial_alert':
        // Отправляем финансовое уведомление
        const financialClient = await db.query(
          'SELECT telegram_chat_id FROM clients WHERE id = $1',
          [data.clientId]
        );
        
        if (financialClient.rows[0]?.telegram_chat_id) {
          await bot.sendMessage(financialClient.rows[0].telegram_chat_id,
            `💰 Финансовое уведомление:\n` +
            `${data.message}\n` +
            `Сумма: ${data.amount} руб.`
          );
        }
        break;
    }

    res.json({ success: true, received: true });
  } catch (error) {
    console.error('❌ Ошибка обработки вебхука:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Telegram Bot Commands

// /start команда
bot.onText(/\/start/, async (msg) => {
  const chatId = msg.chat.id;
  
  try {
    // Проверяем, есть ли уже клиент
    const existing = await db.query(
      'SELECT * FROM clients WHERE telegram_chat_id = $1',
      [chatId]
    );

    if (existing.rows.length > 0) {
      await bot.sendMessage(chatId,
        `👋 С возвращением!\n\n` +
        `Ваша таблица: https://docs.google.com/spreadsheets/d/${existing.rows[0].google_sheet_id}\n` +
        `Артикулы: ${existing.rows[0].articles?.join(', ') || 'не указаны'}\n\n` +
        `Используйте /articles чтобы изменить артикулы`
      );
      return;
    }

    // Создаём нового клиента
    const response = await axios.post(`http://localhost:${port}/api/create-client`, {
      telegramChatId: chatId,
      articles: []
    });

    await bot.sendMessage(chatId,
      `🎉 Регистрация завершена!\n\n` +
      `Теперь укажите артикулы для мониторинга:\n` +
      `/articles 123456, 789012, 345678\n\n` +
      `Или отправьте команду /help для помощи`
    );

  } catch (error) {
    console.error('❌ Ошибка обработки /start:', error);
    await bot.sendMessage(chatId, '❌ Произошла ошибка. Попробуйте позже.');
  }
});

// /articles команда
bot.onText(/\/articles (.+)/, async (msg, match) => {
  const chatId = msg.chat.id;
  const articles = match[1].split(',').map(a => a.trim()).filter(a => a);

  try {
    await db.query(
      'UPDATE clients SET articles = $1 WHERE telegram_chat_id = $2',
      [articles, chatId]
    );

    await bot.sendMessage(chatId,
      `✅ Артикулы обновлены: ${articles.join(', ')}\n\n` +
      `Мониторинг запущен. Уведомления будут приходить сюда.`
    );

    // Активируем мониторинг в n8n
    await axios.post(`${process.env.N8N_WEBHOOK_URL || 'http://n8n:5678'}/webhook/start-monitoring`, {
      telegramChatId: chatId,
      articles
    });

  } catch (error) {
    console.error('❌ Ошибка обновления артикулов:', error);
    await bot.sendMessage(chatId, '❌ Ошибка обновления артикулов.');
  }
});

// /status команда
bot.onText(/\/status/, async (msg) => {
  const chatId = msg.chat.id;

  try {
    const result = await db.query(
      'SELECT * FROM clients WHERE telegram_chat_id = $1',
      [chatId]
    );

    if (result.rows.length === 0) {
      await bot.sendMessage(chatId, '❌ Вы не зарегистрированы. Используйте /start');
      return;
    }

    const client = result.rows[0];
    await bot.sendMessage(chatId,
      `📊 Ваш статус:\n\n` +
      `🆔 ID: ${client.id}\n` +
      `📅 Регистрация: ${new Date(client.created_at).toLocaleDateString('ru-RU')}\n` +
      `📋 Артикулы: ${client.articles?.join(', ') || 'не указаны'}\n` +
      `📈 Статус: ${client.is_active ? '✅ Активен' : '❌ Неактивен'}\n\n` +
      `Таблица: https://docs.google.com/spreadsheets/d/${client.google_sheet_id}`
    );

  } catch (error) {
    console.error('❌ Ошибка получения статуса:', error);
    await bot.sendMessage(chatId, '❌ Ошибка получения статуса.');
  }
});

// /help команда
bot.onText(/\/help/, (msg) => {
  const chatId = msg.chat.id;
  
  bot.sendMessage(chatId,
    `🆘 Помощь по Ultimate Agent Platform\n\n` +
    `Команды:\n` +
    `/start - регистрация\n` +
    `/articles [артикулы] - указать артикулы для мониторинга\n` +
    `/status - текущий статус\n` +
    `/help - эта справка\n\n` +
    `Пример:\n` +
    `/articles 123456, 789012, 345678\n\n` +
    `Система автоматически:\n` +
    `• Мониторит отзывы на Wildberries\n` +
    `• Анализирует тональность\n` +
    `• Создаёт финансовые отчёты\n` +
    `• Генерирует маркетинговые посты\n\n` +
    `Вопросы? Пишите: support@ultimate-agent.com`
  );
});

// Запуск сервера
app.listen(port, () => {
  console.log(`🚀 Ultimate Agent API запущен на порту ${port}`);
  console.log(`🤖 Telegram бот запущен`);
  console.log(`📊 База данных: ${process.env.DATABASE_URL ? 'Подключена' : 'Не настроена'}`);
});