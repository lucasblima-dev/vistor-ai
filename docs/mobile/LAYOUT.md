# Vistor AI — Design System Completo para Flutter

> **Fonte de verdade de UI/UX extraída das telas reais.**

> O agente deve consultar este arquivo antes de gerar qualquer widget, tela ou tema.

> Nunca invente valores de cor, espaçamento ou fonte — use exclusivamente os tokens definidos aqui.

> Este documento cobre as 12 telas confirmadas: Splash/Loading, Login, Home, Mapa, Laudos, Perfil,

> Gestão de Equipe, Exportar Dados, Gestão de Usuários, Nova Inspeção, Detalhe de Inspeção, Offline.

---

## 1. Tokens de Cor (Fonte da Verdade)

### 1.1 Paleta Base — Light / Dark

| Token | Light | Dark | Observado em |
|---|---|---|---|
| `background` | `#F0F2F8` | `#0D1117` | Scaffold de todas as telas |
| `surface` | `#FFFFFF` | `#161B27` | Cards, bottom sheets |
| `surfaceVariant` | `#F5F7FA` | `#1E2435` | Inputs, search bar |
| `primary` | `#3B55E6` | `#4F6BFF` | Botões primários, FAB, gradiente |
| `primaryDeep` | `#1A3C5E` | `#1A3C5E` | Títulos bold (ex: "Minhas Inspeções") |
| `secondary` | `#2E75B6` | `#2E75B6` | Links, ícones ativos, foco de input |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | Texto sobre botões primários |
| `onBackground` | `#0D1117` | `#E8EAF0` | Texto principal |
| `onSurface` | `#1A1F35` | `#CDD0DC` | Texto em cards |
| `onSurfaceVariant` | `#6B7280` | `#8892A4` | Subtextos, placeholders, metadados |
| `outline` | `#E2E6F0` | `#252D40` | Bordas de cards e inputs |
| `bottomNavBg` | `#FFFFFF` | `#0D1117` | Barra de navegação inferior |
| `bottomNavActive` | `#3B55E6` | `#4F6BFF` | Tab ativo |
| `bottomNavInactive`| `#9CA3AF` | `#4A5568` | Tab inativo |

### 1.2 Gradiente — Splash, Splash Header, Botões Premium

Observado nas telas de Loading e fundo do header da Home e Gestão:

```dart
// Gradiente azul-violeta premium
const kGradientPrimary = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],  // indigo → blue
);

// Gradiente para fundo completo da Splash (modo escuro fica mais profundo)
const kGradientSplash = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF4338CA), Color(0xFF2563EB), Color(0xFF3B82F6)],
);

// Gradiente de overlay sobre foto (Inspection Detail header)
const kGradientPhotoOverlay = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Colors.transparent, Color(0xE6000000)],
);
```

### 1.3 Severidade — Cores Exatas

| Severidade | Badge FG | Badge BG | Left border | Dot ativo |
|---|---|---|---|---|
| Crítico | `#FFFFFF` | `#E53E3E` | `#E53E3E` | `#E53E3E` |
| Moderado | `#FFFFFF` | `#DD6B20` | `#DD6B20` | `#DD6B20` |
| Baixo | `#FFFFFF` | `#38A169` | `#38A169` | `#38A169` |
| Pendente | `#6B7280` | `#F3F4F6` | `#9CA3AF` | `#9CA3AF` |

> **Atenção:** os badges de severidade têm texto branco sobre fundo colorido sólido (não bg claro).
> Formato: pill `borderRadius: 100`, `padding: horizontal 10, vertical 4`.

### 1.4 Cores Funcionais e de Estado

```dart
class AppColors {
  // Severidade
  static const criticalFg  = Color(0xFFFFFFFF);
  static const criticalBg  = Color(0xFFE53E3E);
  static const moderateFg  = Color(0xFFFFFFFF);
  static const moderateBg  = Color(0xFFDD6B20);
  static const lowFg       = Color(0xFFFFFFFF);
  static const lowBg       = Color(0xFF38A169);
  static const pendingFg   = Color(0xFF6B7280);
  static const pendingBg   = Color(0xFFF3F4F6);

  // Offline (tela 8.12 e banner)
  static const offline     = Color(0xFFF59E0B);   // amber
  static const offlineBg   = Color(0xFFFFFBEB);
  static const offlineBtn  = Color(0xFFF59E0B);   // botão "Criar Inspeção Offline"

  // Hash badge (Laudos)
  static const hashFg      = Color(0xFF3B55E6);
  static const hashBg      = Color(0xFFEEF2FF);   // indigo-50

  // Role badges (Usuários)
  static const roleAdminFg = Color(0xFF3B55E6);
  static const roleAdminBg = Color(0xFFEEF2FF);
  static const roleInspFg  = Color(0xFF059669);
  static const roleInspBg  = Color(0xFFD1FAE5);
  static const roleBlocFg  = Color(0xFFDC2626);
  static const roleBlocBg  = Color(0xFFFEE2E2);

  // "Admin" badge no topo da tela de Usuários
  static const adminTagFg  = Color(0xFFFFFFFF);
  static const adminTagBg  = Color(0xFF3B55E6);

  // Pendentes badge (Perfil — Sincronização)
  static const pendenteFg  = Color(0xFFFFFFFF);
  static const pendenteBg  = Color(0xFFF59E0B);

  // "Crítico" no card da lista (dot vermelho piscante)
  static const dotCritical = Color(0xFFE53E3E);
  static const dotModerate = Color(0xFFDD6B20);

  // Ícone PDF nos Laudos
  static const pdfIconFg   = Color(0xFFFFFFFF);
  static const pdfIconBg   = Color(0xFFE53E3E);  // vermelho

  // Gradientes
  static const gradStart   = Color(0xFF4F46E5);
  static const gradEnd     = Color(0xFF3B82F6);
  static const gold        = Color(0xFFFFD700);  // ícone Sparkles na logo
}
```

---

## 2. Tokens de Tipografia

**Fonte principal:** `Inter` via `google_fonts`.
**Fonte de código/hash:** `JetBrains Mono` via `google_fonts`.

```dart
class AppText {
  // Títulos de tela (ex: "Minhas Inspeções", "Laudos Técnicos", "Perfil")
  static const screenTitle = TextStyle(
    fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w800,
    letterSpacing: -0.5, color: Color(0xFF1A3C5E),  // primaryDeep
  );

  // Subtítulo abaixo do título (ex: "Visão geral do campo")
  static const screenSubtitle = TextStyle(
    fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w400,
    color: Color(0xFF6B7280),
  );

  // Título de card de inspeção (ex: "Fissura em pared...")
  static const cardTitle = TextStyle(
    fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
    color: Color(0xFF1A1F35),
  );

  // Metadado de card (endereço, data, "6 dias atrás")
  static const cardMeta = TextStyle(
    fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400,
    color: Color(0xFF6B7280),
  );

  // Label de categoria chip (ex: "Estrutural", "Hidráulica")
  static const categoryChip = TextStyle(
    fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500,
    color: Color(0xFF3B55E6),
  );

  // Badge de severidade
  static const severityBadge = TextStyle(
    fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
    color: Color(0xFFFFFFFF),
  );

  // Label de seção (ex: "CONTA", "PREFERÊNCIAS")
  static const sectionLabel = TextStyle(
    fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
    letterSpacing: 1.2, color: Color(0xFF9CA3AF),
  );

  // Texto de botão primário
  static const buttonPrimary = TextStyle(
    fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700,
    color: Color(0xFFFFFFFF),
  );

  // Hash abreviado nos Laudos
  static const hashText = TextStyle(
    fontFamily: 'JetBrains Mono', fontSize: 12, fontWeight: FontWeight.w500,
    color: Color(0xFF3B55E6),
  );

  // Título do Splash
  static const splashTitle = TextStyle(
    fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w800,
    color: Color(0xFFFFFFFF), letterSpacing: -0.5,
  );

  // Subtítulo do Splash
  static const splashSubtitle = TextStyle(
    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400,
    color: Color(0xCCFFFFFF),
  );
}
```

---

## 3. Tokens de Espaçamento, Raio e Sombra

```dart
class AppSpacing {
  static const xs   =  4.0;
  static const sm   =  8.0;
  static const md   = 16.0;
  static const lg   = 20.0;  // padding horizontal padrão das telas
  static const xl   = 24.0;
  static const xxl  = 32.0;

  static const screenH   = 20.0;  // padding horizontal em todas as telas
  static const screenV   = 16.0;
  static const cardPad   = 14.0;  // padding interno de card
  static const sectionGap= 20.0;  // espaço entre seções
  static const itemGap   = 10.0;  // gap entre cards na lista
}

class AppRadius {
  static const logo      = 20.0;   // logo container na Splash e Login
  static const card      = 16.0;   // cards de inspeção, laudos, usuários
  static const cardLg    = 20.0;   // cards de seção maiores (Perfil, Gestão)
  static const input     = 12.0;   // inputs e search bar
  static const button    = 14.0;   // botões primários e secundários
  static const badge     = 100.0;  // pill: severity, role, hash, category chip
  static const sheet     = 24.0;   // bottom sheets
  static const avatar    = 100.0;  // avatar circular
  static const navCard   = 20.0;   // cards de item próximo no mapa
}

class AppShadows {
  static const card = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 20, offset: Offset(0, 4),
  );
  static const cardMd = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 30, offset: Offset(0, 8),
  );
  static const bottomNav = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 20, offset: Offset(0, -4),
  );
}
```

---

## 4. Logo do App (Componente Dinâmico)

Observado nas telas de Login e Splash/Loading:

- Container quadrado com `borderRadius: 20dp`
- Fundo: gradiente `kGradientPrimary` (não glassmorphism)
- Ícone central: `MapPin` / `locationPin` — branco, ~36dp
- Ícone overlay: `Sparkles` — dourado `#FFD700`, ~16dp, posicionado no canto superior direito
- Tamanho: 80dp na Login, 72dp na Splash

```dart
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: kGradientPrimary,
        borderRadius: BorderRadius.circular(AppRadius.logo),
        boxShadow: const [AppShadows.cardMd],
      ),
      child: Stack(children: [
        Center(child: Icon(LucideIcons.mapPin, color: Colors.white, size: size * 0.45)),
        Positioned(
          top: size * 0.10, right: size * 0.10,
          child: Icon(LucideIcons.sparkles, color: AppColors.gold, size: size * 0.24),
        ),
      ]),
    );
  }
}
```

---

## 5. Bottom Navigation Bar

Observado em todas as telas principais:

- **4 abas:** Inspeções (`list`), Mapa (`map`), Laudos (`file-text`), Perfil (`user`)
- Fundo: `surface` (branco no light, `#0D1117` no dark)
- Sombra: `AppShadows.bottomNav`
- Aba ativa: ícone + label em `primary` (`#3B55E6`)
- Aba inativa: ícone + label em `onSurfaceVariant` (`#9CA3AF`)
- **SEM FAB centralizado** — o botão "Nova Inspeção" é um `FloatingActionButton.extended` sobre a lista, não encaixado na nav bar

```
Ícones (lucide_icons):
  Inspeções → LucideIcons.clipboardList
  Mapa      → LucideIcons.map
  Laudos    → LucideIcons.fileText
  Perfil    → LucideIcons.user
```

---

## 6. Componentes Reutilizáveis

### 6.1 InspectionCard

Observado na tela Home:

```
┌─────────────────────────────────────────────────────┐
│ [thumb]  Fissura em pared...  [Crítico ●] [ℹ]       │
│ [72×72]  [Estrutural]                               │
│          📍 Rua das Flores, 123 - Centro             │
│          🕐 6 dias atrás                             │
└─────────────────────────────────────────────────────┘
```

- Card `surface`, `borderRadius: AppRadius.card`, `boxShadow: AppShadows.card`
- **Sem border-left colorido** — diferença importante do design anterior
- Thumbnail: 72×72dp, `borderRadius: 10dp`, `BoxFit.cover`
- Badge de severidade: pill com bg sólido colorido + texto branco
- Ícone `ℹ` (info circle): `onSurfaceVariant`, 18dp, trailing
- Dot de "novo/ativo": circulo 8dp da cor da severidade, ao lado direito do badge
- Category chip: texto `#3B55E6`, bg `#EEF2FF`, pill, 11sp bold
- Padding interno: 12dp all
- Gap entre cards: `AppSpacing.itemGap` (10dp)

### 6.2 SeverityBadge

```dart
// Pill com fundo sólido colorido e texto branco
// Diferente do design anterior: não usa bg claro + fg colorido
class SeverityBadge extends StatelessWidget {
  final String label;       // 'Crítico' | 'Moderado' | 'Baixo' | 'Pendente'
  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (severity) {
      Severity.critical => (AppColors.criticalFg, AppColors.criticalBg),
      Severity.moderate => (AppColors.moderateFg, AppColors.moderateBg),
      Severity.low      => (AppColors.lowFg,      AppColors.lowBg),
      Severity.pending  => (AppColors.pendingFg,  AppColors.pendingBg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(AppRadius.badge)),
      child: Text(label, style: AppText.severityBadge.copyWith(color: fg)),
    );
  }
}
```

### 6.3 CategoryChip

```dart
// Chip azul claro para categoria (Estrutural, Hidráulica, etc.)
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: const Color(0xFFEEF2FF),
    borderRadius: BorderRadius.circular(AppRadius.badge),
  ),
  child: Text(category, style: AppText.categoryChip),
)
```

### 6.4 HashBadge (Laudos)

```dart
// Exibido como "⊙ 3A7F8B2C..." com ícone de shield/check
Row(children: [
  Icon(LucideIcons.shieldCheck, color: AppColors.hashFg, size: 13),
  const SizedBox(width: 4),
  Text(hash.substring(0, 8) + '...', style: AppText.hashText),
])
```

### 6.5 UserCard (Gestão de Usuários — 8.8)

```
┌─────────────────────────────────────────────────────┐
│ [Avatar] Admin Master           [⋮]                 │
│ [circle] admin@vistorai.com                         │
│          ADMINISTRADOR                              │
└─────────────────────────────────────────────────────┘
```

- Avatar circular 44dp com iniciais (2 letras) ou ícone `user`
- Avatar bg: `primary` para admin, `success` para inspetor ativo, `error` para bloqueado
- Role badge: CAPSLOCK, `sectionLabel` style mas com bg chip colorido (ver AppColors.role*)
- Usuário bloqueado: avatar com overlay vermelho semitransparente + ícone `userX`
- Trailing: `⋮` (moreVertical) `onSurfaceVariant`

### 6.6 AssignmentCard (Gestão de Equipe — 8.6)

```
┌─────────────────────────────────────────────────────┐
│ Fissura em viga de sustentação            ●         │
│ 📍 Bloco A - Subsolo • Há 2 horas                   │
│         [👥 Atribuir Inspetor]                      │
└─────────────────────────────────────────────────────┘
```

- Card `surface`, `borderRadius: AppRadius.card`
- Dot vermelho 8dp pulsante no canto direito (inspeção crítica aguardando)
- Botão "Atribuir Inspetor": outlined, `secondary`, ícone `users`, largura full, `borderRadius: AppRadius.button`

### 6.7 ReportCard (Laudos — 8.4)

```
┌─────────────────────────────────────────────────────┐
│ [📄]  Fiação exposta                    [⤴][⬇]     │
│ [red] Gerado em 13/04/2026                          │
│       Por Pedro Costa                               │
│       ⊙ 3A7F8B2C...                                │
│                                                     │
│  Ver documento >                                    │
└─────────────────────────────────────────────────────┘
```

- Ícone PDF: quadrado 44dp, `borderRadius: 10dp`, bg `#E53E3E`, ícone branco `fileText`
- "Ver documento >" — texto link em `primary`, `fontSize: 13`, `fontWeight: w600`
- Ação compartilhar: `shareNetwork` icon, `onSurfaceVariant`
- Ação download: `download` icon, `onSurfaceVariant`
- Divisor sutil entre cards: `Divider(height: 1, color: outline)`

### 6.8 SyncIndicator (AppBar trailing — Home 8.2)

- Ícone `refreshCcw` com badge numérico vermelho no canto superior direito
- Badge: circulo 16dp, bg `#E53E3E`, texto branco 10sp
- Ao lado: ícone do tema (`sun` no light mode, `moon` no dark) — observado na tela 8.2 dark

---

## 7. Especificação por Tela

### 8.1 — Tela de Login

```dart
Scaffold(bg: background)
└── SafeArea
    └── SingleChildScrollView → Padding(lg)
        └── Column(center)
            ├── SizedBox(h: 48)
            ├── AppLogo(size: 80)                ← logo centralizada
            ├── SizedBox(h: 20)
            ├── RichText: "Bem-vindo ao " (bold preto) + "Vistor AI" (bold primary #3B55E6)
            │   fontSize: 26, fontWeight: w800
            ├── SizedBox(h: 6)
            ├── Text("Inspeções técnicas potencializadas por IA", cardMeta, center)
            ├── SizedBox(h: 36)
            │
            ├── Column(crossStart) [Form]
            │   ├── Text("Email", labelSmall, onSurface, bold)
            │   ├── SizedBox(h: 6)
            │   ├── TextField(
            │   │     hint: "inspetor@empresa.com",
            │   │     prefix: Icon(mail, secondary, 18dp),
            │   │     fill: surfaceVariant, radius: 12dp
            │   │   )
            │   ├── SizedBox(h: 14)
            │   ├── Text("Senha", labelSmall, onSurface, bold)
            │   ├── SizedBox(h: 6)
            │   ├── TextField(
            │   │     hint: "••••••••",
            │   │     prefix: Icon(lock, secondary, 18dp),
            │   │     suffix: Icon(eye, onSurfaceVariant, 18dp),
            │   │     obscureText: true, fill: surfaceVariant, radius: 12dp
            │   │   )
            │   ├── SizedBox(h: 10)
            │   ├── Align(right): TextButton("Esqueceu a senha?", primary, 13sp)
            │   ├── SizedBox(h: 20)
            │   └── ElevatedButton(
            │         "Acessar Plataforma",
            │         bg: primary #3B55E6, width: double.infinity, height: 52dp,
            │         radius: 14dp
            │       )
            │
            ├── SizedBox(h: 24)
            └── Text("Protegido por criptografia Vistor AI", 11sp, onSurfaceVariant, center)
```

**Dark mode:** fundo `#0D1117`, campos `#1E2435`, título branco. Botão mantém `#3B55E6`.

---

### 8.2 — Home (Minhas Inspeções)

```dart
Scaffold(bg: background)
├── body: CustomScrollView
│   ├── SliverToBoxAdapter → Padding(h: screenH, v: screenV)
│   │   └── Row(spaceBetween)
│   │       ├── Column(crossStart)
│   │       │   ├── Text("Minhas Inspeções", screenTitle)      ← bold azul escuro
│   │       │   └── Row: Icon(mapPin, secondary, 14dp) + Text("Visão geral do campo", cardMeta)
│   │       └── Row
│   │           ├── GestureDetector → Icon(refreshCcw, 22dp) + badge vermelho "1"
│   │           └── SizedBox(w: 10) + CircleAvatar(32dp, gradient primary)
│   │
│   ├── SliverToBoxAdapter → Padding(h: screenH)
│   │   └── SearchBar(
│   │         hint: "Buscar por local ou ID...",
│   │         prefix: Icon(search, 18dp, onSurfaceVariant),
│   │         fill: surfaceVariant, radius: 12dp, height: 46dp
│   │       )
│   │
│   ├── SliverToBoxAdapter → Padding(h: screenH, v: 12dp)
│   │   └── Row(spaceBetween)
│   │       ├── Row: Icon(filter, secondary, 16dp) + Column("Filtros e Status" / "Exibindo todas")
│   │       └── Container(badge "4", bg: surfaceVariant, radius: badge, 24dp)
│   │
│   └── SliverPadding(h: screenH)
│       └── SliverList (gap: itemGap)
│           └── InspectionCard × N (com FadeInUp stagger)
│
├── floatingActionButton: FloatingActionButton.extended(
│     icon: Icon(plus), label: "Nova Inspeção",
│     bg: Color(0xFF3B55E6), radius: 14dp
│   )
└── bottomNavigationBar: AppBottomNav(active: 0)
```

---

### 8.3 — Mapa

```dart
Scaffold
└── body: Stack
    ├── FlutterMap(fullscreen, OSM tiles)
    │   ├── TileLayer(OSM)
    │   ├── MarkerLayer: ícones mapPin coloridos por severidade (32dp)
    │   └── (HeatmapLayer visual: blobs radiais vermelho→verde)
    │
    ├── Positioned(top: safeArea, left: screenH, right: screenH)
    │   └── Row(spaceBetween)
    │       ├── Container(glassmorphism blur)
    │       │   └── Row: Icon(filter) + Text("Filtrar Mapa") ← pill branco/blur
    │       └── Column: zoom+ (Q) / zoom- (Q) / layers / navigate buttons
    │                   cada um: circulo 40dp, surface, shadow
    │
    └── DraggableScrollableSheet(
          initialSize: 0.28, minSize: 0.15, maxSize: 0.55,
          builder: → Container(surface, radius: sheet top-only)
            ├── Handle bar (32×4dp, onSurfaceVariant, center)
            ├── Text("Inspeções ao seu redor", titleMedium, bold)
            └── ListView.horizontal: NearbyCard × N
        )
        NearbyCard: Container(surface, radius: 12dp, padding: 12dp, border-left 3dp severity)
          Row: [border] Column(title bold 13sp / "📍 A X km daqui" 11sp gray)
```

**Heatmap visual (importante):**

- Blobs circulares com `RadialGradient`: centro vermelho `#E53E3E` opaco → bordas verdes `#38A169` transparentes
- Não usar biblioteca de heatmap — renderizar com `CustomPainter` e `RadialGradient` + `BlendMode.screen`

---

### 8.4 — Laudos Técnicos

```dart
Scaffold(bg: background)
├── body: Padding(h: screenH)
│   ├── SizedBox(h: screenV)
│   ├── Row(spaceBetween)
│   │   ├── Text("Laudos Técnicos", screenTitle)
│   │   └── Container(pill, "2 totais", bg: surfaceVariant, 12sp gray)
│   ├── SizedBox(h: 14)
│   ├── SearchBar("Buscar por título ou inspetor...", fill: surfaceVariant, radius: 12dp)
│   ├── SizedBox(h: 20)
│   └── ListView.builder
│       └── ReportCard (ver componente 6.7) + Divider
└── bottomNavigationBar: AppBottomNav(active: 2)
```

---

### 8.5 — Perfil

```dart
Scaffold(bg: background)
└── body: SingleChildScrollView
    ├── Container(h: 160dp, gradient: kGradientPrimary, radius-b: 0)
    │   └── SafeArea → Column(center)
    │       ├── Row(end): Icon(sun/moon toggle, white, 22dp)   ← toggle de tema
    │       ├── Expanded → Column(center)
    │       │   ├── CircleAvatar(64dp, gradient primary, iniciais "JS" white 22sp bold)
    │       │   ├── SizedBox(h: 8)
    │       │   ├── Container(pill "Inspetor Sênior", bg: white.20%, text: white, 11sp)
    │       │   ├── Text("João Silva", white, 18sp bold)
    │       │   └── Text("joao.silva@empresa.com", white.70%, 12sp)
    │
    └── Padding(h: screenH)
        ├── SizedBox(h: 20)
        ├── _SectionLabel("CONTA")
        ├── _SettingsCard: [Editar perfil →] [Segurança e Senha →]
        ├── SizedBox(h: 16)
        ├── _SectionLabel("PREFERÊNCIAS")
        ├── _SettingsCard:
        │   ├── _SwitchTile(icon: bell, "Alertas críticos", "Notificações push imediatas")
        │   ├── _SwitchTile(icon: clipboard, "Resumo diário", "Relatório via email")
        │   └── _SwitchTile(icon: bell, "Inspeção atribuída", "Avisar ao receber tarefa")
        ├── SizedBox(h: 16)
        ├── _SectionLabel("Sincronização")  ← sem capslock nesta seção
        ├── _SettingsCard:
        │   ├── Row: Text("Última sync: Há 2 minutos", gray 12sp) +
        │   │        Container(pill "3 Pendentes", bg: offlineBg amber)
        │   └── OutlinedButton(icon: refreshCcw, "Forçar Sincronização", fullWidth)
        ├── SizedBox(h: 16)
        ├── _ListTile(icon: info, "Sobre o App", trailing: "v1.0.0")
        └── _ListTile(icon: logOut, "Sair da conta", color: error, trailing: null)
```

**_SettingsCard:** `Container(surface, radius: cardLg, padding: 4dp, boxShadow: card)`
**_SwitchTile:** `ListTile` com `Switch` (active: primary). Leading: círculo 36dp bg surfaceVariant com ícone secondary.
**_SectionLabel:** `Padding(v: 4dp, h: 4dp) Text(CAPSLOCK, sectionLabel)`

---

### 8.6 — Gestão de Equipe

```dart
Scaffold(bg: background)
└── body: Column
    ├── Container(gradient: kGradientPrimary, padding: screenH, rounded-b: 0)
    │   └── SafeArea → Column(crossStart)
    │       ├── Text("Gestão de Equipe", white, 24sp w800)
    │       └── Text("2 inspeções aguardando atribuição", white.70%, 13sp)
    ├── SizedBox(h: 20)
    ├── Padding(h: screenH)
    │   └── Row: Icon(clock, secondary, 16dp) + Text("Fila de Atribuição", 15sp w700)
    ├── SizedBox(h: 12)
    └── Expanded → ListView.builder(padding: h screenH, gap: 12dp)
        └── AssignmentCard (ver componente 6.6)
```

---

### 8.7 — Exportar Dados

```dart
Scaffold(bg: background)
└── body: Padding(h: screenH)
    ├── SizedBox(h: screenV)
    ├── Text("Exportar Dados", screenTitle)
    ├── SizedBox(h: 24)
    │
    ├── Container(surface, radius: cardLg, padding: md, shadow: card)
    │   ├── Row: Icon(calendar, secondary, 16dp) + Text("Período", 13sp w600)
    │   ├── SizedBox(h: 10)
    │   └── Row(gap: 8dp)
    │       ├── Expanded: _DateChip("Últimos 30 dias")  ← chip outlined secondary
    │       └── Expanded: _DateChip("Até hoje")
    │
    ├── SizedBox(h: 16)
    ├── Container(surface, radius: cardLg, padding: md, shadow: card)
    │   ├── Row: Icon(filter, secondary, 16dp) + Text("Status incluídos", 13sp w600)
    │   ├── SizedBox(h: 10)
    │   └── Wrap(gap: 8dp)
    │       ├── _StatusChip("Resolvidas", active: true)
    │       ├── _StatusChip("Abertas", active: true)
    │       └── _StatusChip("Críticas", active: true)
    │
    ├── SizedBox(h: 20)
    ├── Text("FORMATO DO ARQUIVO", sectionLabel)
    ├── SizedBox(h: 12)
    ├── Row(gap: 12dp)
    │   ├── Expanded: _FormatCard(icon: fileJson, "GeoJSON", selected: true)
    │   └── Expanded: _FormatCard(icon: fileSpreadsheet, "CSV Data", selected: false)
    │
    ├── SizedBox(h: 24)
    └── ElevatedButton(icon: download, "Fazer Download", fullWidth, h: 52dp)
```

**_FormatCard:** `Container(surface, radius: card, border: 2dp primary se selected, padding: 16dp)`
`Column(center): Icon(40dp, primary) + SizedBox(8) + Text(label, 13sp w600, primary)`

**_StatusChip:** pill com bg `primary` + texto branco quando ativo; bg `surfaceVariant` + texto gray quando inativo.

---

### 8.8 — Gestão de Usuários

```dart
Scaffold(bg: background)
└── body: Padding(h: screenH)
    ├── SizedBox(h: screenV)
    ├── Row(spaceBetween)
    │   ├── Row: Icon(shield, primary, 22dp) + SizedBox(8) + Text("Usuários", screenTitle)
    │   └── Container(pill "Admin", bg: adminTagBg #3B55E6, text: white, 11sp w700)
    ├── SizedBox(h: 14)
    ├── SearchBar("Buscar por nome ou email...", fill: surfaceVariant)
    ├── SizedBox(h: 16)
    └── ListView.builder(gap: 10dp)
        └── UserCard (ver componente 6.5)
```

**UserCard avatar colors:**

- Admin: bg `primary` (#3B55E6)
- Inspetor ativo: bg `#38A169` (green)
- Bloqueado: bg `#E53E3E` (red), ícone `userX` em vez de `user`

---

### 8.9 — Nova Inspeção

**Layout de formulário scrollável único (não stepper/PageView):**

```dart
Scaffold(bg: background)
├── AppBar(
│     leading: IconButton(arrowLeft),
│     title: Text("Nova Inspeção", 16sp w600),
│     bg: background, elevation: 0
│   )
└── body: SingleChildScrollView → Padding(h: screenH)
    │
    ├── Container(surface, radius: cardLg, shadow: card, padding: md)
    │   ├── Row: Icon(fileText, secondary, 18dp) + Text("Informações Básicas", 15sp w700)
    │   ├── SizedBox(h: 16)
    │   ├── Text("Título da Inspeção", 13sp w600)
    │   ├── SizedBox(h: 6)
    │   ├── TextField(hint: "Ex: Fissura no Pilar P-04", fill: surfaceVariant)
    │   ├── SizedBox(h: 14)
    │   ├── Text("Categoria", 13sp w600)
    │   ├── SizedBox(h: 6)
    │   ├── DropdownButtonFormField(hint: "Selecione uma categoria...", fill: surfaceVariant)
    │   ├── SizedBox(h: 14)
    │   ├── Text("Observações iniciais (Opcional)", 13sp w600)
    │   ├── SizedBox(h: 6)
    │   └── TextField(multiline, hint: "Descreva brevemente o problema encontrado...", minLines: 3)
    │
    ├── SizedBox(h: 16)
    │
    ├── Container(surface, radius: cardLg, shadow: card, padding: md)
    │   ├── Row(spaceBetween)
    │   │   ├── Row: Icon(mapPin, #E53E3E, 18dp) + Text("Localização", 15sp w700)
    │   │   └── TextButton(
    │   │         Row: Icon(circle animated, #E53E3E pulsing, 8dp) + "Obter Localização GPS",
    │   │         color: #E53E3E, 12sp w600
    │   │       )
    │   ├── SizedBox(h: 12)
    │   └── Row(gap: 12dp)
    │       ├── Expanded: _CoordField("Latitude", "-23.550520")
    │       └── Expanded: _CoordField("Longitude", "-46.633308")
    │
    ├── SizedBox(h: 16)
    │
    ├── Container(surface, radius: cardLg, shadow: card, padding: md)
    │   ├── Row(spaceBetween)
    │   │   ├── Row: Icon(sparkles, gold, 18dp) + Text("Registros Fotográficos", 15sp w700)
    │   │   └── Text("0 fotos", 12sp, onSurfaceVariant)
    │   ├── SizedBox(h: 12)
    │   └── Container(
    │         border: DashedBorder(color: outline, radius: 12dp),
    │         padding: 24dp, center
    │       )
    │       └── Column(center)
    │           ├── Row(center): Icon(camera, secondary, 24dp) + Text("•") + Icon(image, secondary, 24dp)
    │           ├── SizedBox(h: 8)
    │           ├── Text("Capturar ou Enviar Fotos", 13sp w600)
    │           └── Text("Máximo de 8 imagens para análise por IA", 11sp gray)
    │
    ├── SizedBox(h: 24)
    └── ElevatedButton(
          icon: plus, "Criar Inspeção em Campo",
          bg: primary, fullWidth, h: 52dp, radius: 14dp
        )
```

**_CoordField:** `Column: Text(label, 12sp w600) + SizedBox(6) + Container(fill: surfaceVariant, radius: 10dp, padding: 10dp) Text(valor, 13sp, JetBrains Mono)`

---

### 8.10 — Detalhe da Inspeção

```dart
Scaffold
└── body: CustomScrollView
    ├── SliverAppBar(
    │     expandedHeight: 260dp, pinned: true,
    │     leading: IconButton(arrowLeft, white),
    │     flexibleSpace: FlexibleSpaceBar(
    │       background: Stack[
    │         CachedNetworkImage(cover),
    │         DecoratedBox(kGradientPhotoOverlay),
    │         Positioned(bottom: 16, left: 16):
    │           Column(crossStart):
    │             Text("Fissura em parede externa", white, 22sp w800)
    │             SeverityBadge("Crítico", Severity.critical)
    │       ]
    │     )
    │   )
    │
    └── SliverPadding(h: screenH)
        └── SliverList
            ├── SizedBox(h: 16)
            ├── Container(surface, radius: card, shadow: card, padding: md)
            │   └── GridView(2 colunas, crossAxisSpacing: 16, mainAxisSpacing: 12)
            │       ├── _InfoCell(Icon(mapPin), "Localização", "Rua das Flores, 123 - Centro")
            │       ├── _InfoCell(Icon(tag), "Categoria", "Estrutural")
            │       ├── _InfoCell(Icon(calendar), "Data", "15/04/2026")
            │       └── _InfoCell(Icon(user), "Inspetor", "João Silva")
            │
            ├── SizedBox(h: 16)
            ├── Container(surface, radius: card, shadow: card, padding: md)
            │   ├── Row: Icon(sparkles, gold, 18dp) + Text("ANÁLISE DE IA", sectionLabel)
            │   ├── SizedBox(h: 8)
            │   ├── Row(spaceBetween)
            │   │   ├── Text("Dano estrutural em concreto", 18sp w700)
            │   │   └── Column: Text("Confiança", 10sp gray) + Text("92%", 24sp w800 primary)
            │   ├── SizedBox(h: 8)
            │   ├── LinearProgressIndicator(value: 0.92, color: primary, bg: outline, h: 6dp, radius: 3dp)
            │   ├── SizedBox(h: 6)
            │   ├── Text("Baseado em análise de padrões visuais e dados históricos", 11sp gray)
            │   ├── SizedBox(h: 12)
            │   └── Row(gap: 8dp)
            │       ├── Expanded: FilledButton("Confirmar", bg: primary)
            │       └── Expanded: OutlinedButton("Corrigir", border: primary)
            │
            ├── SizedBox(h: 16)
            ├── Container(surface, radius: card, padding: md)
            │   ├── Text("Mídia", 15sp w700)
            │   ├── SizedBox(h: 10)
            │   └── GridView(2 colunas, gap: 8dp)
            │       └── CachedNetworkImage(radius: 10dp, 100% width, aspectRatio: 1)
            │
            ├── SizedBox(h: 16)
            ├── Container(surface, radius: card, padding: md)
            │   ├── Text("Timeline", 15sp w700)
            │   ├── SizedBox(h: 12)
            │   └── _StatusTimeline(events: [Criada, Em análise, Resolvida])
            │       cada item: Row[dot 10dp colored + Column[label bold / actor / timestamp]]
            │       linha vertical conectando dots: Container(w:2, h:40, bg: outline)
            │
            └── SizedBox(h: 16)
                Row(spaceBetween)
                  Expanded: ElevatedButton("Gerar Laudo", bg: primary, h: 50dp)
                  SizedBox(w: 8)
                  Container(50×50dp, primary, radius: button): Icon(chevronRight, white)
```

---

### 8.11 — Splash / Loading

```dart
Scaffold
└── Container(fullscreen, gradient: kGradientSplash)
    └── SafeArea
        └── Column(mainAxisAlignment: center)
            ├── AppLogo(size: 72)
            ├── SizedBox(h: 24)
            ├── Text("Vistor AI", splashTitle)
            ├── SizedBox(h: 8)
            ├── Text("Inspeções técnicas potencializadas\npor IA", splashSubtitle, center)
            ├── SizedBox(h: 64)
            └── SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  )
                )
```

**Dark mode:** gradiente mais escuro: `[Color(0xFF1E1B4B), Color(0xFF1E3A5F)]`

---

### 8.12 — Tela Offline

```dart
Scaffold(bg: background)
└── SafeArea
    └── Padding(h: screenH)
        └── Column(mainAxisAlignment: center)
            ├── Container(80×80dp, radius: 20dp, bg: surfaceVariant)
            │   └── Stack:
            │       ├── Center: Icon(wifiOff, offline #F59E0B, 36dp)
            │       └── Positioned(top-right): Icon(sparkles, offline, 16dp)
            ├── SizedBox(h: 24)
            ├── Text("Você está Offline", 24sp w800, onBackground)
            ├── SizedBox(h: 12)
            ├── Text(
            │     "Sua conexão com a internet caiu, mas o trabalho não precisa parar.\n"
            │     "Continue criando suas inspeções localmente. Elas serão\n"
            │     "sincronizadas assim que a rede voltar.",
            │     14sp, onSurfaceVariant, center
            │   )
            ├── SizedBox(h: 32)
            ├── ElevatedButton(
            │     icon: plus, "Criar Inspeção Offline",
            │     bg: offline #F59E0B, fullWidth, h: 52dp, radius: 14dp
            │   )
            ├── SizedBox(h: 12)
            └── OutlinedButton(
                  icon: refreshCcw, "Tentar Novamente",
                  border: outline, fullWidth, h: 48dp, radius: 14dp
                )
```

---

## 8. Regras que o Agente NÃO Deve Quebrar

- **Nunca use** `Colors.blue`, `Colors.red` — apenas `AppColors.*`
- **Nunca hardcode** `Color(0xFF...)` fora da classe `AppColors`
- **Nunca use** `Icons.*` do Material — apenas `LucideIcons.*` do pacote `lucide_icons`
- **Nunca use** `Stepper` padrão Flutter para Nova Inspeção — a tela é **formulário scrollável único**, não stepper
- **Nunca coloque** border-left colorido nos `InspectionCard` — o design real usa badge colorido sem border-left
- **Nunca use** badge com bg claro + fg colorido para severidade — sempre fundo sólido + texto branco
- **Sempre verifique** `Theme.of(context).brightness` em componentes com glassmorphism ou surface colorida
- **Sempre use** `SafeArea` com `top: true` quando não houver AppBar
- **Sempre use** `google_fonts` para Inter e JetBrains Mono — nunca `fontFamily: 'Inter'` literal
- **O heatmap** do mapa é renderizado com `CustomPainter` + `RadialGradient`, não com biblioteca externa
- **O gradiente da Splash** em dark mode é mais escuro (roxo profundo), não o mesmo do light

---

## 9. Pacotes (pubspec.yaml)

```yaml
# UI / Design
google_fonts: ^6.2.1
lucide_icons: ^0.0.4
animate_do: ^3.3.4
flutter_staggered_animations: ^1.1.1
animations: ^2.0.11
cached_network_image: ^3.3.1
dotted_border: ^2.1.0            
# Mapa
flutter_map: ^6.1.0
flutter_map_marker_cluster: ^1.3.0
latlong2: ^0.9.0
```
