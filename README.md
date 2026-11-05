# 🔮 Clavier Enchanté

> _Un sort a été jeté sur votre clavier !_

Jeu de typing compétitif développé en **Godot 4** pour les salons. Les touches de votre clavier ont été mélangées par un enchantement — mémorisez la nouvelle disposition et tapez la formule magique le plus vite possible !

---

#### Liens vers les executables:

Vous pouvez retrouver les executables dans le share point [Les Développeurs](https://maif.sharepoint.com/sites/Lesdveloppeurs/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FLesdveloppeurs%2FShared%20Documents%2FGeneral%2FJeux%2FClavier%20Enchant%C3%A9&viewid=301bec02%2D1358%2D4bfd%2D8b9b%2D55ee668964c1&FolderCTID=0x012000C743A86E09F5D04FA63064393A452931)

---

## 🎮 Principe du jeu

1. **Phase de mémorisation** — Les touches de votre clavier sont mélangées et affichées pendant 30 secondes. Mémorisez bien !
2. **Phase d'incantation** — Les labels des touches disparaissent. Tapez la phrase affichée le plus vite possible.
3. **Fin** — Votre temps est enregistré. Le mage le plus rapide remporte la victoire !

### ⚠️ Attention

- Chaque erreur **ajoute du temps** à votre score
- Vous pouvez révéler temporairement le clavier (`Backspace`), mais cela **coûte 10 secondes**

---

## 🚀 Installation et lancement

### Windows

Double-cliquez sur `ClavierEnchante.exe`

### macOS

Double-cliquez sur `ClavierEnchante.app`

> ⚠️ Si macOS bloque le lancement : clic droit → Ouvrir → Ouvrir quand même

### Linux

Rendre l'app éxécutable avec la commande :

```bash
chmod +x ClavierEnchante.x86_64
```

Lancer en lancant la commande:

```bash
./ClavierEnchante.x86_64
```

Ou double-cliquez sur `ClavierEnchante.x86_64`

---

## 📦 Export du jeu (Godot 4)

### Prérequis

- Utiliser **Godot 4.6** (ou version compatible avec le projet)
- Ouvrir le projet puis aller dans **Project → Export...**
- Si demandé, installer les templates d'export via **Manage Export Templates...**

### Procédure générale

1. Dans **Project → Export...**, cliquer sur **Add...**
2. Ajouter les presets nécessaires : **Windows Desktop**, **Linux/X11**, **macOS**
3. Vérifier les options de chaque preset (nom du binaire, architecture, icône, etc.)
4. Cliquer sur **Export Project...** (ou **Export All...**) pour générer les builds, décocher **Exporter avec debug**

### Export Windows

1. Sélectionner le preset **Windows Desktop**
2. Choisir le format (`.exe`)
3. Exporter dans un dossier de sortie (ex. `build/windows/`)
4. Distribuer au minimum `ClavierEnchante.exe` et le fichier `.pck` associé si séparé

### Export Linux

1. Sélectionner le preset **Linux/X11**
2. Exporter en binaire `ClavierEnchante.x86_64`
3. Placer les fichiers dans un dossier (ex. `build/linux/`)
4. Rendre l'exécutable lançable :

```bash
chmod +x ClavierEnchante.x86_64
```

### Export macOS

1. Sélectionner le preset **macOS**
2. Exporter l'application `.app` (ex. `ClavierEnchante.app`)
3. Pour distribution publique, signer/notariser l'app avec un certificat Apple
4. En local, si macOS bloque l'app : clic droit → **Ouvrir**

### Conseils pour un export salon

- Tester chaque build sur la plateforme cible avant l'événement
- Vérifier que `scores.json` et `clavier_enchante_config.json` sont bien créés à côté de l'exécutable
- Préparer un dossier par OS (`build/windows`, `build/linux`, `build/macos`) pour éviter les confusions

---

## ⚙️ Configuration (organisateurs)

Un panneau **Options** protégé par mot de passe permet de configurer :

- La **phrase** à taper
- Le **temps de mémorisation**
- Les **pénalités** (erreur, révélation)

Le mot de passe est défini dans `game_manager.gd` → variable `game_rules_password`.

La configuration est sauvegardée dans `clavier_enchante_config.json` à côté de l'exécutable.

---

## 🏆 Scores

Les scores sont sauvegardés dans `scores.json` à côté de l'exécutable, au format :

```json
[
  {
    "pseudo": "Gandalf",
    "email": "gandalf@wizards.com",
    "temps": 01:58.00
  }
]
```

Le classement est visible en jeu via le bouton **Classement** du menu principal.

---

## 🛠️ Stack technique

- **Moteur** : Godot 4.6
- **Langage** : GDScript
- **Détection layout clavier** : `DisplayServer.keyboard_get_label_from_physical()`
- **Compatibilité** : AZERTY / QWERTY détecté automatiquement
- **Plateformes** : Windows, macOS, Linux

---

## 📁 Structure du projet

```
ClavierEnchante/
├── Assets/
│   ├── keyboard/       # Sprites des touches
│   └── ...             # Backgrounds, sparkles, UI
├── Fonts/              # Police Thaleah Fat
├── Scenes/
│   ├── main_menu.tscn  # Menu principal
│   ├── main_game.tscn  # Scène de jeu
│   ├── options_modal.tscn # Modale dédiée aux options
│   └── key_button.tscn # Composant touche de clavier
├── Scripts/
│   ├── game_manager.gd # Autoload - état global du jeu
│   ├── transition.gd   # Autoload - transitions entre scènes
│   └── sparkle.gd      # Animation des sparkles
└── README.md
```

---

## 🎨 Crédits

- **Visuels** : Générés avec Gemini AI (backgrounds) + sprites animés ou non réalisés avec [Piskel](https://www.piskelapp.com/) et [Libresprite](https://libresprite.github.io/#!/)
- **Police** : Thaleah Fat (gratuite, CC-BY)
- **Moteur** : [Godot Engine](https://godotengine.org) (MIT License)

---

## 📝 Développement

```bash
# Cloner le repo
git clone https://github.com/TON_USERNAME/clavier-enchante.git

# Ouvrir dans Godot 4.6+
# File → Open Project → sélectionner le dossier
```

### Modifier la phrase du jeu

Dans le menu → Options → (mot de passe) → champ "Séquence"  
Ou directement dans `game_manager.gd` → variable `sequence`

### Récupérer les scores après l'événement

Le fichier `scores.json` se trouve dans le même dossier que l'exécutable.
