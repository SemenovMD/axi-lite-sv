# AXI‑Lite SystemVerilog Library

Набор готовых к использованию модулей и эталонных проектов на SystemVerilog для работы с протоколом AXI‑Lite. Библиотека включает примеры мастера/слейва, периферийные устройства, интерконнект/кроссбар, конвертеры и утилиты для симуляции и верификации.

## Содержание
- [Особенности](#Особенности)
- [Структура репозитория](#Структура-репозитория)
- [Быстрый старт](#Быстрый-старт)
- [Симуляция](#Симуляция)
- [Документация по модулям](#Документация-по-модулям)
- [Лицензия](#Лицензия)

## Особенности
- Полная поддержка AXI‑Lite (каналы AW/W/B и AR/R).
- Эталонные примеры: Master/Slave, UART Master.
- Интерконнект (Round‑Robin/Priority арбитраж, декод адресов, кроссбар).
- Конвертеры: AXI‑Lite → AXI‑Stream.
- Тестовое окружение, make‑скрипты, python‑утилиты.

## Структура репозитория
- [AXI_Lite_Example_Master/](AXI_Lite_Example_Master/) — пример мастера AXI‑Lite.
- [AXI_Lite_Example_Slave/](AXI_Lite_Example_Slave/) — пример слейва AXI‑Lite.
- [AXI_Lite_UART_Master/](AXI_Lite_UART_Master/) — UART Master AXI‑Lite.
- [AXI_Lite_Interconnect/](AXI_Lite_Interconnect/) — интерконнект AXI-Lite (RR/Priority).
- [AXI_Lite_To_Stream_Converter/](AXI_Lite_To_Stream_Converter/) — конвертер AXI‑Lite → AXI‑Stream.

Базовые интерфейсы:
- `axil_if.sv` — интерфейс AXI‑Lite.
- `axis_if.sv` — интерфейс AXI‑Stream.

## Быстрый старт
1) Клонировать репозиторий и выбрать нужный подпроект (например, Example Master/Slave или UART Master).
2) Открыть локальный `README.md` подпроекта — там описаны параметры, структура и команды запуска.

## Симуляция
Для симуляции используется QuestaSim/ModelSim.

## Документация по модулям
- [AXI_Lite_Example_Master/README.md](AXI_Lite_Example_Master/README.md)
- [AXI_Lite_Example_Slave/README.md](AXI_Lite_Example_Slave/README.md)
- [AXI_Lite_UART_Master/README.md](AXI_Lite_UART_Master/README.md)
- [AXI_Lite_Interconnect/README.md](AXI_Lite_Interconnect/README.md)
- [AXI_Lite_To_Stream_Converter/README.md](AXI_Lite_To_Stream_Converter/README.md)

## Лицензия
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  
Проект распространяется под лицензией [MIT](LICENSE).

## Автор
- [Семёнов Максим](https://t.me/semenovmd) — FPGA Engineer
