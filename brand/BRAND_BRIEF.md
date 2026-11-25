# LBDFI brand brief: white-label WeBuddhist app

Status: starter kit, research only (no app code changed). Prepared 2026-11-25.
Companion files: `palette.json` (colours, themes, contrast), `logo/`, `reference/`.

## 1. Who LBDFI is

- **Official name:** Light of Buddhadharma Foundation International (LBDFI). In print it also appears as "LBDFI-India" and "Light of Buddhadharma Foundation International-India". The site calls itself "The Light of Buddhadharma Foundation". Note the spelling **Buddhadharma** (one word). Do not use "Buddha Dhamma".
- **What they do:** since 2006 they have worked to restore Buddhist culture in India. That covers chanting ceremonies at the holy sites, cleaning up and improving the sacred places, walking pilgrimages, free Dharma books (more than 100,000 given away) and training Indian monks. Sources: https://www.lbdfi.org/ and https://www.lbdfi.org/about-us-buddhist-culture/
- **Offices:** headquarters in Berkeley, CA (USA) and a registered office in New Delhi. The International Tipitaka Chanting Council (ITCC) is based at Saxena More, Bodhgaya, Bihar. The About page links an "Our Team" page that features Ven. Tarthang Tulku.
- **Sister body:** the International Tipitaka Chanting Council – India, https://www.tipitakachantingcouncil.co.in/. This is a React single-page app titled "ITCC" that handles "LBDFI Events registration". Its president is Ven. Dr. Bhikkhu Sanghasena Mahathero, according to the 2026 invitation.
- **Partners on 2026 material:** Ministry of Culture (Govt. of India), Bihar Tourism, Odisha Tourism and the Odia Language, Literature & Culture Dept., and Bodhipakkhiya Dhamma Foundation (which made the Abhidhamma poster series).

## 2. Programmes (what the app content should reflect)

| Programme | 2026–27 edition | Source |
|---|---|---|
| International Tipitaka Chanting Ceremony (ITCC) | 21st edition, 2–12 Dec 2026, Bodhgaya, branded "25,000 Voices · Buddhavacana" | Invitation PDF, poster, lbdfi.org |
| Inspirational Dhamma Talks ("Dhamma Speaker") | 2–11 Dec 2026, 6:30–8:30 PM under the Bodhi Tree, with Hindi translation. Nine speakers, mostly Thai Forest tradition plus Sri Lankan and Indian Sangha | Hoarding + speaker booklet PDFs |
| Guru Padmasambhava Monlam | 3rd edition, 28 Dec 2026 – 3 Jan 2027, Lalitgiri–Udayagiri–Ratnagiri, Odisha, then 21 Tara Prayers on 4–5 Jan 2027. A "4th Monlam" cover is already in the deck | Monlam programme PDF |
| Abhidhamma learning posters | 13 illustrated posters in the ITCC series (Citta, Cetasika, Rūpa, Nibbāna, Paṭṭhāna…) | Bodhipakkhiya PDF |
| Other | Tipitaka chanting at Sarnath, Rajgir, Vaishali, Kushinagar, Lumbini, Sri Lanka and more; 8th International Mahayana Chanting Ceremony; Beautifying the holy places; Yatra walks; Dharma books / Daily Tipitaka | lbdfi.org nav |

## 3. Audience and languages

- **Audience:** the international Theravada Sangha and lay delegations from Bangladesh, Cambodia, India, Indonesia, Lao PDR, Myanmar, Nepal, Sri Lanka, Thailand, Vietnam and the USA. Also Indian lay Buddhists (including the Ambedkarite community, since the invitation mentions Baba Saheb), Himalayan and Tibetan Vajrayana practitioners (Monlam), pilgrims and volunteers.
- **Languages seen:** English is primary everywhere. Hindi appears in Dhamma talk translation, the Hindi volunteer form and Ministry logos. Pali uses full diacritics (Dāna, samādhi, mettā, Tipiṭaka, Paṭṭhāna). Tibetan script is on the Monlam cover. The ITCC registration bundle references Thai, Myanmar, Khmer, Lao, Pali and Hindi. Sinhala and Odia appear in context.
- **App implication:** the fonts must cover Pali diacritics (ā ī ū ṃ ṅ ñ ṭ ḍ ṇ ḷ), Devanagari and Tibetan. The current app already ships Tibetan fonts.

## 4. Voice and tone

The voice is reverent, warm and inclusive, with a ceremonial register: "Venerable", "Sacred", "Hon'ble". They often speak of gathering as one, returning home to the land of the Buddha, and preserving the Buddha's words. Phrases they actually use:

1. "We Become One, Under the Bodhi Tree." (21st ITCC countdown poster)
2. "One collective voice of the Buddha at the seat of enlightenment" (21st ITCC invitation)
3. "Welcome home to our motherland under the most sacred Bodhi Tree" (21st ITCC invitation)
4. "Where Vajrayana and Theravada Remember Their Shared Root" (3rd Guru Padmasambhava Monlam cover)
5. "Our mission is Revitalizing Dharma" (lbdfi.org home slider)

Also used: "A Shower of Blessings" (Monlam) and "Preserving the Buddha's Teachings · Cultivating Peace" (header of the Bodhipakkhiya ITCC Abhidhamma posters).

**Guidance for app copy:** write in the second person with a gentle, invitational tone, such as "Join the chanting" and "Welcome home". Keep Pali terms with their diacritics. Avoid gamified or hype language.

## 5. Visual language

**Colours** (full list with sources in `palette.json`):

| Swatch | Hex | Where it comes from |
|---|---|---|
| Robe Maroon | `#980404` | lbdfi.org CSS (also `#840202`); maroon type in print |
| LBDFI Gold | `#D9A534` | Official line-art logo |
| Saffron | `#FE6E00` | lbdfi.org CSS main accent; colour logo fill |
| Ribbon Saffron | `#CE5005` (deep: `#B34810`) | ITCC poster ribbon |
| Bodhi Teal | `#01455E` | 2026 ITCC countdown poster background |
| Temple Cream | `#FFFAF7` | lbdfi.org CSS background |
| Parchment | `#F6ECD4` | Poster and invitation frames |
| Deep Maroon Ink | `#501919` | Title type on invitation, hoarding and poster |
| ITCC Lotus Crimson | `#D5535D` | ITCC Dharma-wheel emblem |
| Monlam Indigo | `#171252` | Monlam programme cover |

The site's WordPress theme (Gita) also defines purples (`#5F2C70` and others). These are theme defaults, not LBDFI's choice, so ignore them.

**Type styles seen:**
- **Print display:** classical serifs (EB Garamond, Cormorant Garamond, Minion Pro), often with a swash script for accent words such as "Bodhi Tree" and "Grand Opening" (Dalloway, JustCosmic).
- **Print captions:** Tw Cen MT (a geometric sans).
- **Web:** Lato for body text and Kumbh Sans for headings and menus.
- **ITCC registration app:** Georgia and Avenir Next.

**Likely Google Fonts:**
- Display: **Cormorant Garamond** or **EB Garamond**. Both are free and cover Pali diacritics.
- UI and body: **Lato**, which matches the site. **Jost** is a Tw Cen-like alternative.
- Script accent: **Pinyon Script**, for splash or onboarding only.
- Hindi: **Noto Serif Devanagari** or **Noto Sans Devanagari**.

The current app uses Inter and Source Serif. Swapping the display serif to Cormorant or EB Garamond is enough to feel "theirs". Check that Lato renders ṃ and ṅ, and fall back to Noto Sans if it does not.

**Imagery motifs:**
- Places: the Mahabodhi temple spire, Bodhi leaves and the Bodhi Tree.
- Figures: a golden seated Buddha, and saffron- and maroon-robed Sangha processions with national flags.
- Animals and flowers: white caparisoned elephants, jasmine and lotus.
- Symbols and ornament: the Dharma wheel, the Three Jewels on clouds, cream cartouches with thin gold rules and lotus dividers, and Tibetan floral borders (Monlam).
- Mood: warm sunrise light.

## 6. Assets: available and missing

| Asset | Status | File |
|---|---|---|
| LBDFI logo, gold line art + wordmark | ✅ Official PNG served by lbdfi.org, 539×478, transparent | `logo/lbdfi-logo-gold.png` |
| LBDFI emblem only, gold | ✅ Cropped from the above, 316×316 (small) | `logo/lbdfi-mark-gold.png` |
| LBDFI logo, colour (saffron jewels, yellow line) | ✅ Rendered from **vector** art in `Dhamma Speaker_Hoarding.pdf` at 1500 dpi, ~1000 px, transparent outside | `logo/lbdfi-logo-color.png`, `logo/lbdfi-mark-color.png` |
| ITCC Dharma-wheel emblem | ✅ ITCC site PWA icon 512×512 (gradient, white background) + vector render ~950 px | `logo/itcc-emblem-dharma-wheel.png`, `logo/itcc-logo-color.png` (use on light backgrounds; its white outlines went transparent) |
| Vector master (SVG/AI/EPS) | ❌ Not published. The vector exists inside the CorelDRAW PDFs, so **ask LBDFI for the master** | — |
| 1024 px app-icon artwork, brand guidelines | ❌ Missing | — |
| Photography rights (Mahabodhi, Sangha, Buddha renders) | ❓ Many 2026 images look AI-generated or composited. Rights need confirming | `reference/*.jpg` (reference only) |
| Privacy policy | ❌ None found on lbdfi.org. The site's form text mentions a "Privacy Policy" but does not link one | — |
| Instagram URL | ❌ The icon is on the site but no URL could be resolved | — |

## 7. Contact and support details found

- **General:** lbdfiorg@gmail.com (lbdfi.org)
- **Event registration help:** lbdfi_events_registration_help@googlegroups.com (in the ITCC site bundle). Another group address, lbdfi_events_notification@googlegroups.com, also exists.
- **Socials:** https://www.facebook.com/LBDFI and https://www.youtube.com/@LBDFIOnline. The site also links a Dharma Talks YouTube playlist.
- **Addresses:** 1A Vandana Building, Tolstoy Marg, New Delhi-110001; Saxena More, Bodhgaya, Gaya, Bihar-824231.
- **Privacy URL:** none found.

## 8. Proposed directions

### A. Heritage: Robe Maroon & Gold (recommended)
- **Why recommended:** it is the identity LBDFI already uses where they control it: the site CSS (maroon and saffron), the gold logo, and the cream-and-maroon invitation and hoarding.
- **App name options:** **LBDFI**, *Light of Buddhadharma*, *LBDFI Dharma*.
- **Colours:** primary `#980404`, secondary `#B34810` (deep saffron, so white text passes), accent `#D9A534` gold, background `#FFFAF7`, surface `#F6ECD4`, text `#501919`.
- **Icon:** the gold line-art Three Jewels on a Robe Maroon field, with the logo's thin outer ring. Use the saffron-filled jewels (`lbdfi-mark-color.png`) at small sizes for legibility.
- **Onboarding and first screen:**
  - Splash: cream parchment, with the emblem fading in and a maroon serif "LBDFI".
  - Welcome slides: (1) a full-bleed Bodhi Tree and Mahabodhi image with "Welcome home…"; (2) chant the Buddha's words daily; (3) LBDFI ceremonies.
  - Home screen: today's chanting text plus a framed "Next ceremony" card (ITCC Bodhgaya / Monlam).
- **Tagline:** "One collective voice of the Buddha".

### B. Bodhi Tree: Teal, Saffron & Cream (ITCC campaign)
- **App name options:** *Tipitaka Chanting*, *ITCC Bodhgaya*, *Buddhavacana*.
- **Colours:** primary `#01455E`, secondary `#CE5005`, accent `#F4CD5F`, cream `#F6ECD4`. White on `#CE5005` is 4.4:1, so use it for large text or fills only.
- **Icon:** the ITCC Dharma wheel, or a simplified gold wheel, on teal with one Bodhi leaf.
- **Onboarding and first screen:** a teal splash with Bodhi leaves framing a live **ITCC countdown** ("8 days to go") in a cream cartouche with a saffron ribbon, plus a registration link. After the ceremony it switches to "Chant with the Sangha".
- **Tagline:** "We Become One, Under the Bodhi Tree."

### C. Shared Root: Monlam Indigo & Antique Gold
- **App name options:** *Light of Dhamma*, *Shared Root*, *LBDFI Monlam*.
- **Colours:** primary `#171252`, secondary `#BC8B4A`, accent `#FE6E00`.
- **Icon:** saffron Three Jewels on indigo with a soft radiating halo, a nod to the Monlam rainbow rays.
- **Onboarding and first screen:** an indigo night-sky splash. The first screen offers two paths, Pali chanting and Tibetan prayers, reflecting both of LBDFI's traditions.
- **Tagline:** "Where Vajrayana and Theravada Remember Their Shared Root".

### Proposed app theme (Direction A), WCAG contrast

| | Light | Dark |
|---|---|---|
| primary / onPrimary | `#980404` / `#FFFFFF`: **8.92** | `#E3B04B` / `#2B0A05`: **9.21** |
| secondary / onSecondary | `#B34810` / `#FFFFFF`: **5.45** | `#FF8A3D` / `#2B0A05`: **7.80** |
| background | `#FFFAF7` | `#160C0A` |
| surface | `#F6ECD4` | `#2A1714` |
| text on background | `#501919`: **13.57** | `#FBEFDC`: **16.94** |
| text on surface | **11.96** | **15.01** |

**Flags (below 4.5:1):**
- Gold `#D9A534` on cream is **2.16**. Use it only for decoration and icons; never for text on light surfaces.
- White on Saffron `#FE6E00` is **2.82**. Use dark ink on Saffron instead (`#501919`: 4.98).
- White on `#CE5005` is **4.40**. Use it for large text only.

**App token mapping** (same tint recipe as `lib/core/theme/app_colors.dart`): primary `#980404`, primaryLight `#AD3636`, primaryDark `#720303`, primaryDarkest `#580202`, primaryContainer `#F5E6E6`, primarySurface `#FAF2F2`. Map accentGold to `#D9A534` and surfaceLight to `#FFFAF7`.

## 9. Open questions for LBDFI

1. Confirm the app name and which legal entity is the store publisher: LBDFI-India, or the US headquarters in Berkeley.
2. Please send master logo files (SVG/AI/EPS, or PNG at 1024 px or larger) for the gold line and saffron colour versions.
3. May the app use the ITCC Dharma-wheel emblem, or does it belong only to the ITCC Council?
4. Should the app lead with LBDFI, ITCC, or both (for example "LBDFI", with ITCC as a featured event)?
5. Do you have a privacy policy URL and a dedicated support email? Both are required for the App Store and Play Store.
6. Which languages are needed at launch: English and Hindi, plus Thai, Myanmar, Sinhala, Khmer, Lao or Tibetan?
7. Do you hold licences for Tw Cen MT and Minion Pro, or are the Google Fonts listed above acceptable?
8. Who owns the rights to the 2026 poster and invitation imagery, and may the app reuse it for onboarding?
9. Should Bodhipakkhiya Dhamma Foundation's Abhidhamma posters appear in the app as content?
10. Do you want an event countdown and registration link (tipitakachantingcouncil.co.in) on the first screen during ceremony season?
