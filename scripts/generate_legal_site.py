#!/usr/bin/env python3
"""Generate the public legal/support site served via GitHub Pages.

App Review requires functioning HTTPS Privacy, Terms, and Support URLs. This
emits self-contained, bilingual (日本語 + English) static pages that mirror the
in-app legal copy (Features/Settings/LegalPages.swift), so the app can point at
real URLs instead of the `skytrace.example.com` placeholder.

Output: docs/site/  (index.html + one folder per page → clean URLs like /privacy/)
Deployed by .github/workflows/pages.yml. Published under:
  https://sunpotflower4460-cpu.github.io/UFO-News-App/

Keep this in sync with LegalPages.swift when the in-app copy changes.
"""
import html
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs/site"
APP = "SkyTrace"
UPDATED = "2026-07-15"
# Support contact shown on the Support page. Replace with a real, monitored
# address before submission (see docs/MANUAL_ACTIONS.md, M-023).
SUPPORT_CONTACT = "support@skytrace.app"

# raw key -> (title_ja, title_en)
TITLES = {
    "editorial":  ("編集方針", "Editorial Policy"),
    "ai":         ("AIの役割", "How AI Is Used"),
    "scores":     ("4軸スコア", "The Four-Axis Scores"),
    "sources":    ("出典方針", "Sources Policy"),
    "correction": ("訂正方針", "Corrections Policy"),
    "privacy":    ("プライバシーポリシー", "Privacy Policy"),
    "terms":      ("利用規約", "Terms of Use"),
    "support":    ("サポート", "Support"),
}

# raw key -> {"ja": (lead, [bullets]), "en": (lead, [bullets])}
CONTENT = {
    "editorial": {
        "ja": ("SkyTraceは、世界の空で報告された事象を、出典・証拠・不確実性とともに記録する観測ニュースサービスです。",
               ["「未解明」を「地球外起源」とは断定しません。",
                "記事は記事単位ではなくCase（同一の空の事象）単位で統合します。",
                "既知現象（航空機・衛星・火球・天体・気象など）との照合を先に行い、それでも残る部分を未解明として示します。",
                "評価は後日の新情報で更新し、変更履歴を残します。訂正しても過去の評価や監査記録は消しません。",
                "単一の「信ぴょう性」点数は用いず、証拠品質・独立報告性・既知現象一致度・未解明度の4軸で示します。"]),
        "en": ("SkyTrace is an observational news service that records events reported in skies around the world, together with their sources, evidence, and uncertainty.",
               ["We never assert that “unexplained” means “extraterrestrial.”",
                "We integrate coverage by Case (a single sky event), not by individual article.",
                "We first check against known phenomena — aircraft, satellites, fireballs, astronomical bodies, weather — and present only what remains as unexplained.",
                "Assessments are updated as new information arrives, and we keep a change history. Corrections never erase past assessments or the audit record.",
                "We do not use a single “credibility” score; we show four axes — evidence quality, independent reporting, known-phenomena match, and unresolvedness."]),
    },
    "ai": {
        "ja": ("AIは、複数の資料を整理し、一致点・矛盾点・情報不足を可視化し、読みやすい記事にまとめる編集助手です。真実を宣言する権威ではありません。",
               ["AIは地球外起源を断定しません。",
                "公開される各事実文は、出典または計算・照合結果へ追跡できます。",
                "推論は「推論」と明示し、不明は「不明」と記します。",
                "出典にない事実をAIが補完することはありません。",
                "生成にはモデル・プロンプトのバージョンを記録し、注目事例は人間レビューを必須にできます。"]),
        "en": ("AI is an editorial assistant that organizes multiple sources, surfaces agreements, contradictions, and information gaps, and composes them into a readable article. It is not an authority that declares the truth.",
               ["AI never asserts an extraterrestrial origin.",
                "Every published factual sentence can be traced to a source or to a calculation/matching result.",
                "Inference is labeled as “inference,” and unknowns are stated as “unknown.”",
                "AI does not fill in facts that are absent from the sources.",
                "Model and prompt versions are recorded for each generation, and notable cases can require human review."]),
    },
    "scores": {
        "ja": ("4軸スコアはいずれも0〜100で表します。",
               ["証拠品質：元映像・撮影時刻・位置・継続時間など、証拠そのものの確かさ。",
                "独立報告性：別々の人物・地点からの、転載でない報告の多さ。",
                "既知現象一致度：値が高いほど、既知現象で説明できる可能性が高い。",
                "未解明度：既知現象で説明しきれず残る部分。高くても地球外起源は意味しません。情報不足だけで高くはなりません。"]),
        "en": ("Each of the four scores is expressed on a 0–100 scale.",
               ["Evidence quality: the reliability of the evidence itself — original footage, capture time, location, duration, and so on.",
                "Independent reporting: how many non-duplicated reports come from separate people and places.",
                "Known-phenomena match: the higher the value, the more likely the event can be explained by a known phenomenon.",
                "Unresolvedness: the portion that known phenomena cannot fully explain. A high value does not mean an extraterrestrial origin, and a lack of information alone does not raise it."]),
    },
    "sources": {
        "ja": ("出典は、公的・一次資料、信頼できる報道、許諾を得た専門データベース、オープンデータを優先します。",
               ["規約で禁止された自動取得は行いません。",
                "有料記事本文や、権利不明の画像・動画を再配布しません。",
                "各出典には媒体名・種別・公開日時・役割（支持／反証／文脈）を明示します。",
                "情報源ごとの利用条件はSource Registryで管理し、未承認の情報源は本番で無効化します。"]),
        "en": ("For sources we prioritize official and primary materials, trustworthy reporting, licensed specialist databases, and open data.",
               ["We do not perform automated collection that a site’s terms prohibit.",
                "We do not redistribute paywalled article text or images/video whose rights are unclear.",
                "Each source states the outlet name, type, publication date, and role (support / rebuttal / context).",
                "Usage terms per source are managed in a Source Registry, and unapproved sources are disabled in production."]),
    },
    "correction": {
        "ja": ("訂正の際は、訂正日時・変更前の要旨・変更理由・新しい出典を記録します。",
               ["元の評価を消さず、タイムラインに変更を残します。",
                "重大な訂正は、保存したユーザーへ任意で通知します。",
                "「説明済み」への変化は格下げではなく、理解が進んだ更新として扱います。"]),
        "en": ("When we make a correction, we record the correction time, a summary of what changed, the reason, and the new source.",
               ["We do not erase the original assessment; the change stays on the timeline.",
                "For significant corrections, we can optionally notify users who saved the case.",
                "A change to “explained” is treated not as a downgrade but as an update reflecting better understanding."]),
    },
    "privacy": {
        "ja": ("SkyTrace（以下「本アプリ」）は、プライバシーを最小化する設計です。初回リリースでは、記事を読むだけであればアカウント登録も正確な位置情報も必要ありません。",
               ["追跡型広告・広告ID（IDFA）は使用せず、第三者トラッキングを行いません。",
                "連絡先・写真ライブラリ・マイク・カメラ・正確な位置情報にはアクセスしません。",
                "アプリの設定やブックマークは端末内（UserDefaults）にのみ保存され、当社サーバへ送信されません。",
                "サブスクリプションはAppleのIn-App Purchaseで処理され、支払い情報を当社が受け取ることはありません。",
                "将来プッシュ通知を導入する場合、通知トークンは通知目的のみに使用し、アプリ内に削除導線を用意します。",
                "お問い合わせは本サイトのサポートページからお願いします。"]),
        "en": ("SkyTrace (“the app”) is designed to minimize the use of personal data. In the initial release, reading articles requires no account and no precise location.",
               ["We do not use tracking ads or an advertising identifier (IDFA), and we do not perform third-party tracking.",
                "We do not access your contacts, photo library, microphone, camera, or precise location.",
                "App settings and bookmarks are stored only on your device (UserDefaults) and are not sent to our servers.",
                "Subscriptions are processed through Apple’s In-App Purchase; we never receive your payment information.",
                "If push notifications are added in the future, notification tokens will be used only for notifications, with an in-app way to delete them.",
                "For questions, please use the Support page on this site."]),
    },
    "terms": {
        "ja": ("本サービスは情報提供を目的とし、報告された事象の真偽を保証するものではありません。",
               ["有料のデジタルコンテンツはApp StoreのIn-App Purchaseで提供します。",
                "自動更新サブスクリプションは、期間終了の24時間前までにキャンセルできます。",
                "サブスクリプションはApp Storeのアカウント設定からいつでも管理・解約できます。",
                "価格・期間・更新条件はApp Storeの表示に従います。"]),
        "en": ("This service is provided for informational purposes and does not guarantee the truth of the events it reports.",
               ["Paid digital content is offered through the App Store’s In-App Purchase.",
                "An auto-renewing subscription can be canceled up to 24 hours before the end of the current period.",
                "You can manage or cancel a subscription at any time from your App Store account settings.",
                "Price, period, and renewal terms follow what the App Store displays."]),
    },
    "support": {
        "ja": (f"ご質問・誤りのご報告は、下記の連絡先までお願いします。返信には数営業日を要する場合があります。",
               ["記事の誤りは、該当CaseのAI・編集方針欄からご報告いただけます。",
                f"ご連絡先：{SUPPORT_CONTACT}",
                "アプリのバージョンと、可能であれば対象Caseのタイトルをお知らせいただくと、対応がスムーズです。"]),
        "en": (f"For questions or to report an error, please contact us below. Replies may take a few business days.",
               ["You can report an article error from the AI / editorial-policy section of the relevant Case.",
                f"Contact: {SUPPORT_CONTACT}",
                "Telling us your app version and, if possible, the title of the Case involved helps us respond faster."]),
    },
}

# Page order for navigation.
ORDER = ["editorial", "ai", "scores", "sources", "correction", "privacy", "terms", "support"]

CSS = """
:root{color-scheme:dark}
*{box-sizing:border-box}
body{margin:0;background:#070B14;color:#F4F7FB;
  font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,"Hiragino Sans","Noto Sans JP",sans-serif;
  line-height:1.7;-webkit-text-size-adjust:100%}
a{color:#5FD4C8;text-decoration:none}
a:hover{text-decoration:underline}
.wrap{max-width:720px;margin:0 auto;padding:32px 20px 64px}
header.site{display:flex;align-items:center;gap:12px;padding-bottom:8px;border-bottom:1px solid rgba(255,255,255,.10);margin-bottom:24px}
.mark{width:34px;height:34px;border-radius:9px;flex:0 0 auto;
  background:radial-gradient(circle at 50% 46%,rgba(127,230,220,0) 34%,rgba(127,230,220,.9) 38%,rgba(127,230,220,0) 46%),#0B1621;
  box-shadow:inset 0 0 0 1px rgba(255,255,255,.06)}
.brand{font-weight:600;font-size:18px;letter-spacing:.2px}
.brand small{display:block;color:#A9B5C7;font-weight:400;font-size:12px;letter-spacing:.3px}
h1{font-size:26px;margin:8px 0 4px}
.updated{color:#728096;font-size:13px;margin:0 0 28px}
h2.lang{font-size:13px;text-transform:uppercase;letter-spacing:1.4px;color:#5FD4C8;margin:34px 0 10px}
p.lead{color:#DCE4F0;margin:0 0 14px}
ul{padding-left:20px;margin:0 0 8px}
li{margin:8px 0;color:#C6D0DF}
nav.pages{display:flex;flex-wrap:wrap;gap:8px 14px;margin:26px 0 0;padding-top:20px;border-top:1px solid rgba(255,255,255,.10)}
nav.pages a{font-size:14px;color:#A9B5C7}
nav.pages a.active{color:#5FD4C8}
footer{color:#728096;font-size:12px;margin-top:40px;padding-top:16px;border-top:1px solid rgba(255,255,255,.10)}
.cards{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:12px;margin-top:24px}
.card{display:block;padding:16px;border-radius:14px;background:#0E1623;border:1px solid rgba(255,255,255,.08)}
.card:hover{border-color:rgba(95,212,200,.5);text-decoration:none}
.card b{display:block;color:#F4F7FB;font-size:15px}
.card span{display:block;color:#A9B5C7;font-size:12px;margin-top:3px}
""".strip()


def rel(depth):
    return "../" * depth


def head(depth, title):
    return (f"<!DOCTYPE html>\n<html lang=\"ja\">\n<head>\n<meta charset=\"utf-8\">\n"
            f"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
            f"<title>{html.escape(title)} · {APP}</title>\n"
            f"<style>{CSS}</style>\n</head>\n<body>\n<div class=\"wrap\">\n"
            f"<header class=\"site\"><a class=\"mark\" href=\"{rel(depth)}index.html\" aria-label=\"{APP}\"></a>"
            f"<div class=\"brand\">{APP}<small>Observational UAP news · 観測ニュース</small></div></header>\n")


def nav(depth, active):
    links = []
    for key in ORDER:
        tj, te = TITLES[key]
        cls = " class=\"active\"" if key == active else ""
        links.append(f"<a href=\"{rel(depth)}{key}/\"{cls}>{html.escape(tj)} · {html.escape(te)}</a>")
    return "<nav class=\"pages\">\n" + "\n".join(links) + "\n</nav>\n"


def foot():
    return (f"<footer>© {APP}. Last updated {UPDATED}. "
            f"日本語と英語で提供しています。 / Provided in Japanese and English.</footer>\n"
            f"</div>\n</body>\n</html>\n")


def section(lang_label, block):
    lead, bullets = block
    items = "\n".join(f"<li>{html.escape(b)}</li>" for b in bullets)
    return (f"<h2 class=\"lang\">{lang_label}</h2>\n"
            f"<p class=\"lead\">{html.escape(lead)}</p>\n<ul>\n{items}\n</ul>\n")


def build_page(key):
    tj, te = TITLES[key]
    c = CONTENT[key]
    doc = head(1, f"{tj} / {te}")
    doc += f"<h1>{html.escape(tj)} <span style=\"color:#728096;font-weight:400\">/ {html.escape(te)}</span></h1>\n"
    doc += f"<p class=\"updated\">最終更新 {UPDATED} · Last updated {UPDATED}</p>\n"
    doc += section("日本語", c["ja"])
    doc += section("English", c["en"])
    doc += nav(1, key)
    doc += foot()
    d = OUT / key
    d.mkdir(parents=True, exist_ok=True)
    (d / "index.html").write_text(doc, encoding="utf-8")


def build_index():
    doc = head(0, "About")
    doc += (f"<h1>{APP}</h1>\n"
            f"<p class=\"updated\">世界の空で報告された事象を、出典・証拠・不確実性とともに。 "
            f"Reported sky events, with sources, evidence, and uncertainty.</p>\n")
    doc += "<div class=\"cards\">\n"
    for key in ORDER:
        tj, te = TITLES[key]
        doc += f"<a class=\"card\" href=\"{key}/\"><b>{html.escape(tj)}</b><span>{html.escape(te)}</span></a>\n"
    doc += "</div>\n"
    doc += foot()
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "index.html").write_text(doc, encoding="utf-8")
    # Prevent Jekyll from touching the static files.
    (OUT / ".nojekyll").write_text("", encoding="utf-8")


def main():
    build_index()
    for key in ORDER:
        build_page(key)
    print(f"Generated {len(ORDER)} pages + index at {OUT}")


if __name__ == "__main__":
    main()
