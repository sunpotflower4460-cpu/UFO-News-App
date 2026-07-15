#!/usr/bin/env python3
"""Seed the String Catalog for the target languages (i18n B3).

Two passes over Resources/Localizable.xcstrings:

1. English fallback: for every key, add each target language (if missing) with
   the English value, marked `needs_review`. The app becomes fully readable in
   English for all declared languages (better than the ja source fallback for a
   global audience — the user accepted a readable, non-native fallback).

2. Native core translations: overlay real, human-quality translations for the
   highest-visibility vocabulary (tabs, the 8-status set, key titles/actions),
   marked `translated`. Everything else stays on the English fallback until
   translators fill it in — the catalog is ready for them.

Idempotent: re-running only fills gaps and refreshes the CORE overlay.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CAT = ROOT / "apps/ios/SkyTrace/Resources/Localizable.xcstrings"
TARGET = ["es", "fr", "de", "pt-PT", "zh-Hans", "zh-Hant", "ko", "ar", "hi", "ru"]

# Native translations for the most-visible keys. Order of values matches TARGET.
CORE = {
    "tab.today":   ["Hoy", "Aujourd’hui", "Heute", "Hoje", "今天", "今天", "오늘", "اليوم", "आज", "Сегодня"],
    "tab.map":     ["Mapa", "Carte", "Karte", "Mapa", "地图", "地圖", "지도", "الخريطة", "मानचित्र", "Карта"],
    "tab.research":["Explorar", "Explorer", "Entdecken", "Explorar", "探索", "探索", "탐색", "استكشاف", "एक्सप्लोर", "Обзор"],
    "tab.settings":["Ajustes", "Réglages", "Einstellungen", "Definições", "设置", "設定", "설정", "الإعدادات", "सेटिंग्स", "Настройки"],

    "today.title":    ["Hoy", "Aujourd’hui", "Heute", "Hoje", "今天", "今天", "오늘", "اليوم", "आज", "Сегодня"],
    "map.title":      ["Mapa", "Carte", "Karte", "Mapa", "地图", "地圖", "지도", "الخريطة", "मानचित्र", "Карта"],
    "research.title": ["Explorar", "Explorer", "Entdecken", "Explorar", "探索", "探索", "탐색", "استكشاف", "एक्सप्लोर", "Обзор"],
    "settings.title": ["Ajustes", "Réglages", "Einstellungen", "Definições", "设置", "設定", "설정", "الإعدادات", "सेटिंग्स", "Настройки"],

    "v2.status.newReport":               ["Reporte nuevo", "Nouveau signalement", "Neue Meldung", "Novo relato", "新报告", "新報告", "새 신고", "بلاغ جديد", "नई रिपोर्ट", "Новое сообщение"],
    "v2.status.underReview":             ["En revisión", "En cours d’examen", "In Prüfung", "Em análise", "审查中", "審查中", "검토 중", "قيد المراجعة", "समीक्षाधीन", "На рассмотрении"],
    "v2.status.informationInsufficient": ["Información insuficiente", "Informations insuffisantes", "Unzureichende Informationen", "Informação insuficiente", "信息不足", "資訊不足", "정보 부족", "معلومات غير كافية", "जानकारी अपर्याप्त", "Недостаточно данных"],
    "v2.status.knownExplanationLikely":  ["Explicación conocida probable", "Explication connue probable", "Bekannte Erklärung wahrscheinlich", "Explicação conhecida provável", "很可能有已知解释", "很可能有已知解釋", "알려진 설명일 가능성 높음", "تفسير معروف محتمل", "ज्ञात व्याख्या संभावित", "Вероятно известное объяснение"],
    "v2.status.explained":               ["Explicado", "Expliqué", "Erklärt", "Explicado", "已解释", "已解釋", "설명됨", "مُفسَّر", "व्याख्या हो गई", "Объяснено"],
    "v2.status.disputed":                ["En disputa", "Contesté", "Umstritten", "Contestado", "有争议", "有爭議", "논란 있음", "محل خلاف", "विवादित", "Спорно"],
    "v2.status.corrected":               ["Corregido", "Corrigé", "Korrigiert", "Corrigido", "已更正", "已更正", "정정됨", "مُصحَّح", "सुधारा गया", "Исправлено"],
    "v2.status.archived":                ["Archivado", "Archivé", "Archiviert", "Arquivado", "已归档", "已封存", "보관됨", "مؤرشف", "संग्रहीत", "В архиве"],

    "action.retry":     ["Reintentar", "Réessayer", "Erneut versuchen", "Tentar novamente", "重试", "重試", "다시 시도", "إعادة المحاولة", "पुनः प्रयास", "Повторить"],
    "action.close":     ["Cerrar", "Fermer", "Schließen", "Fechar", "关闭", "關閉", "닫기", "إغلاق", "बंद करें", "Закрыть"],
    "action.viewOnMap": ["Ver en el mapa", "Voir sur la carte", "Auf Karte anzeigen", "Ver no mapa", "在地图上查看", "在地圖上查看", "지도에서 보기", "عرض على الخريطة", "मानचित्र पर देखें", "На карте"],
    "action.share":     ["Compartir", "Partager", "Teilen", "Partilhar", "分享", "分享", "공유", "مشاركة", "साझा करें", "Поделиться"],
    "action.bookmark":  ["Guardar", "Enregistrer", "Merken", "Guardar", "收藏", "收藏", "북마크", "حفظ", "बुकमार्क", "Закладка"],

    "case.article":         ["Síntesis de IA", "Synthèse IA", "KI-Synthese", "Síntese de IA", "AI 综合", "AI 綜合", "AI 종합", "توليف بالذكاء الاصطناعي", "AI संश्लेषण", "AI-сводка"],
    "sources.sectionTitle": ["Fuentes", "Sources", "Quellen", "Fontes", "来源", "來源", "출처", "المصادر", "स्रोत", "Источники"],
    "trust.entry":          ["Cómo funciona SkyTrace", "Comment fonctionne SkyTrace", "So funktioniert SkyTrace", "Como funciona o SkyTrace", "SkyTrace 如何运作", "SkyTrace 如何運作", "SkyTrace 작동 방식", "كيف يعمل SkyTrace", "SkyTrace कैसे काम करता है", "Как работает SkyTrace"],
}


def unit(value, state):
    return {"stringUnit": {"state": state, "value": value}}


def main():
    d = json.loads(CAT.read_text(encoding="utf-8"))
    S = d["strings"]

    # Pass 1 — English fallback for every key/target language.
    seeded = 0
    for key, entry in S.items():
        loc = entry.setdefault("localizations", {})
        en = loc.get("en")
        if not en:
            continue
        for lang in TARGET:
            if lang in loc:
                continue
            if "variations" in en:  # plural — copy the English forms, needs_review
                plural = {cat: unit(v["stringUnit"]["value"], "needs_review")
                          for cat, v in en["variations"]["plural"].items()}
                loc[lang] = {"variations": {"plural": plural}}
            else:
                loc[lang] = unit(en["stringUnit"]["value"], "needs_review")
            seeded += 1

    # Pass 2 — native core translations (overwrite the fallback for these keys).
    core_written = 0
    for key, values in CORE.items():
        if key not in S:
            continue
        loc = S[key].setdefault("localizations", {})
        for lang, value in zip(TARGET, values):
            loc[lang] = unit(value, "translated")
            core_written += 1

    d["strings"] = dict(sorted(S.items()))
    CAT.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Seeded {seeded} English-fallback entries; wrote {core_written} native core translations.")
    print(f"Languages: en + ja source, targets: {', '.join(TARGET)}")


if __name__ == "__main__":
    main()
