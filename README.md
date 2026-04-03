# Space Invaders — Atari ST 68000 Assembly

Projet Space Invaders développé en assembleur 68000 pur pour Atari ST (320×200, 4 bitplanes, 50 Hz).

---

## Structure des dossiers

### `SRC/`
Code source du jeu. Point d'entrée : `MAIN.S`. Tous les fichiers sont inclus dans MAIN.S à l'assemblage — il n'y a qu'un seul fichier objet produit : `MAIN.PRG`.

### `SRC/LOOPS/`
Boucles de jeu par état. Chaque fichier gère un état de la machine à états du jeu (titre, jeu, mort, game over...).

### `INC/`
Fichiers d'inclusion purs (`.I`) : constantes EQU, macros, structures, adresses matériel. Ne génèrent aucun octet par eux-mêmes.

### `DATA/GFX/`
Ressources graphiques binaires prêtes à être incluses dans le jeu via `incbin` :
- `.RAW` : pixels écran 32000 bytes (sans header)
- `.PAL` : palette 32 bytes (16 couleurs format `$0RGB`)
- `.BIN` : sprites + masques (format propriétaire, voir GFX.S)

### `TMP/PI1/`
Images sources Degas Elite (`.PI1`) utilisées par les outils de conversion. Non incluses dans le jeu directement.

### `TOOLS/`
Outils de développement standalone (`.PRG`) à exécuter sous Hatari pour générer les ressources `DATA/GFX/`. Chaque outil lit un `.PI1` et écrit un fichier binaire.

### `DOC/`
Notes de documentation sur certaines routines système.

### `BUILD/`
Répertoire de compilation (vide, réservé).

---

## Fichiers source — rôle et dépendances

### `SRC/MAIN.S`
**Rôle :** Point d'entrée du programme. Gère le démarrage, la boucle principale à 50 Hz (WAITVBL), le dispatch des états, et la sortie propre vers le TOS.

**Dépendances :**
- `INC/TOS.I` — appels système GEMDOS/XBIOS
- `INC/HW_ST.I` — adresses matériel (SCREEN_RES, IKBD_DATA...)
- `INC/VECTORS.I` — vecteurs d'interruption
- `INC/CONST.I` — constantes du jeu
- `INC/KEYS.I` — scancodes clavier
- `INC/MACROS.I` — PUSHALL, POPALL, WAITVBL
- `INC/STRUCT.I` — structures de données
- `SRC/SYS.S` — appels système (supervisor, écran, palette)
- `SRC/GFX.S` — moteur graphique
- `SRC/PHYS.S` — physique et mouvements
- `SRC/DEBUG.S` — CPU meter et switch d'états
- `SRC/LOOPS/TITLE.S` — état titre
- `SRC/LOOPS/READY.S` — état prêt
- `SRC/LOOPS/PLAY.S` — état jeu
- `SRC/LOOPS/SHIP.S` — mise à jour vaisseau
- `SRC/LOOPS/BULLET.S` — mise à jour projectile
- `SRC/LOOPS/ENEMIES.S` — grille ennemis
- `SRC/LOOPS/DEATH.S` — explosion vaisseau
- `SRC/LOOPS/GAMEOVER.S` — fin de partie
- `SRC/LOOPS/NEXT_LVL.S` — transition niveau
- `SRC/SND.S` — son (stub)
- `SRC/VARS.S` — variables globales BSS

---

### `SRC/VARS.S`
**Rôle :** Déclare toutes les variables globales du jeu en section BSS (non initialisées). Aucun code exécutable. Inclus en dernier dans MAIN.S après tous les includes de code.

**Dépendances :**
- `INC/CONST.I` — pour les tailles calculées (ENM_COUNT, SPR_H...)

---

### `SRC/SYS.S`
**Rôle :** Encapsule tous les appels système TOS (GEMDOS/XBIOS). Le reste du code ne fait jamais de TRAP directement. Gère le mode superviseur, la sauvegarde/restauration de l'état GEM (palette, résolution, adresse écran), la souris, et la sortie programme.

**Dépendances :**
- `INC/TOS.I` — constantes TRAP (_Super, _Setscreen...)
- `INC/HW_ST.I` — SCREEN_RES, PAL_BASE
- `INC/MACROS.I` — PUSHALL/POPALL
- `SRC/VARS.S` — SCR_ADDR_L, SYS_SCR_ADDR_L, SYS_GEM_PAL, SYS_RESOL_B, SYS_USP_L

---

### `SRC/GFX.S`
**Rôle :** Moteur graphique complet. Gère l'affichage des sprites (preshift dynamique, 4 bitplanes), la sauvegarde/restauration du fond sous les sprites, l'affichage des écrans RAW, la restauration de rectangles depuis un buffer source, et le chargement des palettes. Contient aussi tous les `incbin` des ressources graphiques.

**Technique sprite :** X AND 15 = preshift. Le sprite 16px est étalé sur 2 colonnes (block1 + block2) en décalant un long de 32 bits. Le masque perce le fond, le sprite se pose dans le trou. REPT 4 pour les 4 plans.

**Routines :**
- `GFX_CLEAR_SCREEN` — efface tout l'écran
- `GFX_CLEAR_LINES` — efface une plage de lignes
- `GFX_RESTORE_LINES` — recopie des lignes depuis un buffer RAW
- `GFX_RESTORE_RECT` — recopie un rectangle depuis un buffer RAW
- `GFX_LOAD_PALETTE` — charge 16 couleurs dans les registres matériel
- `GFX_DISPLAY_RAW` — affiche un écran complet (palette + pixels)
- `GFX_SAVE_BG` — sauvegarde le fond sous un sprite (3 colonnes × hauteur)
- `GFX_RESTORE_BG` — restaure le fond sauvegardé
- `GFX_DRAW_SPRITE` — dessine un sprite avec preshift dynamique

**Dépendances :**
- `INC/CONST.I` — SCR_ROW_BYTES, SPR_W_BYTES, SPR_HDR, ENM_SIZE...
- `INC/MACROS.I` — PUSHALL/POPALL
- `INC/HW_ST.I` — PAL_BASE
- `SRC/VARS.S` — SCR_ADDR_L
- `DATA/GFX/TITLE.PAL`, `TITLE.RAW`
- `DATA/GFX/READY.PAL`, `READY.RAW`
- `DATA/GFX/NEXT.PAL`, `NEXT.RAW`
- `DATA/GFX/DAMIER.PAL`, `DAMIER.RAW`
- `DATA/GFX/GAMEOVER.PAL`, `GAMEOVER.RAW`
- `DATA/GFX/SHIP.BIN`
- `DATA/GFX/ENEMIES1.BIN`
- `DATA/GFX/ENEMIES2.BIN`

---

### `SRC/PHYS.S`
**Rôle :** Calculs physiques purs — mouvements et détection de bords. Ne touche jamais à l'écran. Lit et écrit uniquement les variables de position.

**Routines :**
- `PHYS_MOVE_SHIP` — lit KEY_CUR, déplace SHIP_X_CUR, clamp aux bornes
- `PHYS_MOVE_BULLET` — décrémente BULLET_Y de 6px, désactive si hors écran
- `PHYS_MOVE_GRID` — déplace GRID_X selon GRID_DIR, détecte les bords, fait descendre la grille et inverse la direction

**Dépendances :**
- `INC/CONST.I` — SHIP_X_MIN/MAX/STEP, ENM_GRID_X_MIN/MAX, ENM_MOVE_STEP, ENM_DROP_STEP
- `INC/KEYS.I` — KEY_LEFT, KEY_RIGHT
- `INC/MACROS.I` — PUSHALL/POPALL
- `SRC/VARS.S` — SHIP_X_CUR, BULLET_Y, BULLET_ACTIVE, GRID_X, GRID_Y, GRID_DIR, KEY_CUR

---

### `SRC/DEBUG.S`
**Rôle :** Outils de debug uniquement. CPU meter par couleur de bordure (rouge = CPU occupé, noir = CPU libre). Switch d'états via F1-F6 pour tester chaque écran sans jouer.

**Routines :**
- `DBG_RED` / `DBG_GREEN` / `DBG_BLACK` — change la couleur de fond 0 (bordure)
- `DBG_STATE_SWITCH` — teste F1-F6 et force le changement d'état

**Dépendances :**
- `INC/HW_ST.I` — PAL_BASE
- `INC/KEYS.I` — KEY_F1..KEY_F6
- `INC/CONST.I` — STATE_*
- `SRC/VARS.S` — GAME_STATE, *_INIT_DONE, STATE_TIMER, KEY_CUR

---

### `SRC/SND.S`
**Rôle :** Stub player SNDH. Les trois points d'entrée (init, stop, frame) sont déclarés mais le fichier musique n'est pas encore intégré.

**Dépendances :** aucune active (incbin commenté)

---

### `SRC/LOOPS/TITLE.S`
**Rôle :** Gère l'état `STATE_TITLE`. Affiche l'écran titre et attend une action du joueur.

**Dépendances :**
- `SRC/GFX.S` — GFX_DISPLAY_RAW, GFX_DRAW_SPRITE (labels RAW_TITLE, PAL_TITLE, BIN_SPRITE)
- `INC/CONST.I` — SHIP_SPR, SPR_H
- `SRC/VARS.S` — TITLE_INIT_DONE, SHIP_X_CUR

---

### `SRC/LOOPS/READY.S`
**Rôle :** Gère l'état `STATE_READY`. Affiche l'écran "prêt" pendant 1 seconde puis passe à `STATE_PLAY`.

**Dépendances :**
- `SRC/GFX.S` — GFX_DISPLAY_RAW (RAW_READY, PAL_READY)
- `INC/CONST.I` — READY_DELAY, STATE_PLAY
- `SRC/VARS.S` — READY_INIT_DONE, STATE_TIMER, GAME_STATE, PLAY_INIT_DONE

---

### `SRC/LOOPS/PLAY.S`
**Rôle :** Orchestre l'état `STATE_PLAY`. Initialise le niveau au premier appel, puis chaque frame appelle dans l'ordre : mise à jour vaisseau, projectile, ennemis. Gère la touche de debug K (mort forcée).

**Dépendances :**
- `SRC/GFX.S` — GFX_DISPLAY_RAW, GFX_SAVE_BG, GFX_DRAW_SPRITE (RAW_LEVEL1, PAL_LEVEL1, BIN_SPRITE)
- `SRC/LOOPS/SHIP.S` — SHIP_UPDATE
- `SRC/LOOPS/BULLET.S` — BULLET_UPDATE
- `SRC/LOOPS/ENEMIES.S` — ENEMIES_INIT, ENEMIES_DRAW, ENEMIES_SAVE_BG, ENEMIES_UPDATE
- `INC/CONST.I` — SHIP_SPR, SPR_H, STATE_DEATH
- `INC/KEYS.I` — KEY_K
- `SRC/VARS.S` — PLAY_INIT_DONE, SHIP_X_CUR, SHIP_X_PREV, SHIP_BG_SAV, GAME_STATE, KEY_CUR

---

### `SRC/LOOPS/SHIP.S`
**Rôle :** Mise à jour du vaisseau chaque frame : déplacement physique, restauration du fond à l'ancienne position, sauvegarde du fond à la nouvelle position, dessin du sprite selon la direction.

**Dépendances :**
- `SRC/PHYS.S` — PHYS_MOVE_SHIP
- `SRC/GFX.S` — GFX_RESTORE_BG, GFX_SAVE_BG, GFX_DRAW_SPRITE
- `INC/CONST.I` — SHIP_SPR, SHIP_SPR_L, SHIP_SPR_R, SPR_H
- `INC/KEYS.I` — KEY_LEFT, KEY_RIGHT
- `SRC/VARS.S` — SHIP_X_CUR, SHIP_X_PREV, SHIP_BG_SAV, KEY_CUR
- `SRC/GFX.S` — BIN_SPRITE (label data)

---

### `SRC/LOOPS/BULLET.S`
**Rôle :** Gère le projectile du joueur. Détecte l'appui sur la touche de tir, spawne le projectile au-dessus du vaisseau, le déplace chaque frame, restaure/sauvegarde/dessine. Gère le verrou de touche (anti-répétition).

**Dépendances :**
- `SRC/PHYS.S` — PHYS_MOVE_BULLET
- `SRC/GFX.S` — GFX_SAVE_BG, GFX_RESTORE_BG, GFX_DRAW_SPRITE
- `INC/CONST.I` — SHIP_SPR_FIRE, SPR_H
- `INC/KEYS.I` — KEY_F
- `SRC/VARS.S` — BULLET_ACTIVE, BULLET_KEY_LOCK, BULLET_X, BULLET_Y, BULLET_Y_PREV, BULLET_BG_SAV, SHIP_X_CUR, KEY_CUR
- `SRC/GFX.S` — BIN_SPRITE (label data)

---

### `SRC/LOOPS/ENEMIES.S`
**Rôle :** Gère la grille d'ennemis. Initialisation du tableau (types cyclants 1..26), affichage de tous les ennemis vivants, déplacement périodique de la grille (timer), restauration du fond avant le déplacement, vérification de la condition game over (grille trop basse).

**Routines :**
- `ENEMIES_INIT` — remplit ENEMY_TABLE, initialise position et timer
- `ENEMIES_DRAW` — parcourt le tableau avec compteurs col/row, dispatche vers BIN_ENEMIES1 ou BIN_ENEMIES2 selon le type, appelle GFX_DRAW_SPRITE
- `ENEMIES_SAVE_BG` — snapshot de GRID_Y pour le restore au prochain step
- `ENEMIES_UPDATE` — décrémente le timer, restaure le rectangle de fond, appelle PHYS_MOVE_GRID, redessine, recharge le timer (vitesse proportionnelle aux ennemis vivants)

**Dépendances :**
- `SRC/PHYS.S` — PHYS_MOVE_GRID
- `SRC/GFX.S` — GFX_DRAW_SPRITE, GFX_RESTORE_RECT
- `INC/CONST.I` — ENM_COLS, ENM_ROWS, ENM_COUNT, ENM_TYPE_MAX, ENM_H, ENM_SIZE, ENM_STEP_X, ENM_STEP_Y, ENM_GRID_X_MIN, ENM_MOVE_DELAY, ENM_MOVE_DELAY_MIN, ENM_GAMEOVER_Y, SPR_HDR
- `INC/MACROS.I` — PUSHALL/POPALL
- `SRC/VARS.S` — ENEMY_TABLE, GRID_X, GRID_Y, GRID_DIR, GRID_MOVE_TIMER, GRID_ALIVE, ENEMIES_BG_GRID_Y, GAME_STATE
- `SRC/GFX.S` — BIN_ENEMIES1, BIN_ENEMIES2, RAW_LEVEL1 (labels data)

---

### `SRC/LOOPS/DEATH.S`
**Rôle :** Gère l'état `STATE_DEATH`. Anime l'explosion du vaisseau sur 5 frames pendant 1 seconde, puis décrémente les vies et passe à `STATE_READY` ou `STATE_GAMEOVER`.

**Dépendances :**
- `SRC/GFX.S` — GFX_RESTORE_BG, GFX_SAVE_BG, GFX_DRAW_SPRITE
- `INC/CONST.I` — DEATH_DELAY, SHIP_SPR_EXP0, SPR_SIZE, SPR_H, STATE_GAMEOVER, STATE_READY, LIVES_MAX
- `SRC/VARS.S` — DEATH_INIT_DONE, DEATH_FRAME, STATE_TIMER, SHIP_X_CUR, SHIP_BG_SAV, BULLET_ACTIVE, GAME_LIVES_W, GAME_STATE, PLAY_INIT_DONE
- `SRC/GFX.S` — BIN_SPRITE (label data)

---

### `SRC/LOOPS/GAMEOVER.S`
**Rôle :** Gère l'état `STATE_GAMEOVER`. Affiche l'écran game over pendant 2 secondes puis retourne à `STATE_TITLE` en réinitialisant les vies.

**Dépendances :**
- `SRC/GFX.S` — GFX_DISPLAY_RAW (RAW_GAMEOVER, PAL_GAMEOVER)
- `INC/CONST.I` — STATE_TITLE, LIVES_MAX
- `SRC/VARS.S` — GAMEOVER_INIT_DONE, STATE_TIMER, GAME_STATE, GAME_LIVES_W, TITLE_INIT_DONE

---

### `SRC/LOOPS/NEXT_LVL.S`
**Rôle :** Gère l'état `STATE_NEXT_LVL`. Affiche l'écran de transition de niveau pendant 1 seconde puis passe à `STATE_READY`. L'incrément du niveau et l'affichage du numéro de stage sont à implémenter.

**Dépendances :**
- `SRC/GFX.S` — GFX_DISPLAY_RAW (RAW_NEXT, PAL_NEXT)
- `INC/CONST.I` — NEXT_LVL_DELAY, STATE_READY
- `SRC/VARS.S` — NEXT_LVL_INIT_DONE, STATE_TIMER, GAME_STATE, READY_INIT_DONE

---

## Fichiers d'inclusion — rôle et dépendances

### `INC/CONST.I`
**Rôle :** Toutes les constantes du jeu (EQU uniquement, zéro octet généré). Dimensions écran, sprites, ennemis, vaisseau, états, timers.

**Dépendances :** aucune

---

### `INC/MACROS.I`
**Rôle :** Macros assembleur réutilisables.
- `PUSHALL` / `POPALL` : sauvegarde et restauration de tous les registres d0-d7/a0-a6
- `WAITVBL` : attente de la prochaine interruption verticale via le compteur TOS `$466`

**Dépendances :**
- `INC/HW_ST.I` — `_frclock` ($466)

---

### `INC/HW_ST.I`
**Rôle :** Adresses des registres matériel Atari ST/STE. Vidéo (résolution, palette, adresse écran), clavier IKBD, son YM2149, MFP 68901, variables système TOS.

**Dépendances :** aucune

---

### `INC/KEYS.I`
**Rôle :** Scancodes IKBD pour toutes les touches utilisées (flèches, F1-F10, ESC, espace, lettres...).

**Dépendances :** aucune

---

### `INC/STRUCT.I`
**Rôle :** Offsets des structures de données (sprite 12 bytes, tile 4 bytes). Utilisé avec les modes d'adressage indirects du 68000.

**Dépendances :** aucune

---

### `INC/TOS.I`
**Rôle :** Constantes pour les appels système TOS (opcodes GEMDOS, BIOS, XBIOS), offsets de la basepage, résolutions, variables TOS.

**Dépendances :** aucune

---

### `INC/AES.I`
**Rôle :** Constantes et tailles de buffers pour les appels GEM AES. Utilisé uniquement par les outils `TOOLS/`.

**Dépendances :** aucune

---

### `INC/VECTORS.I`
**Rôle :** Vecteurs d'interruption du 68000.

**Dépendances :** aucune

---

## Outils de développement (`TOOLS/`)

### `TOOLS/PI1TOPAL/PI1TOPAL.S`
**Rôle :** Extrait la palette (32 bytes à l'offset +2) d'un fichier `.PI1` Degas Elite et l'écrit dans un fichier `.PAL`. À exécuter sous Hatari après chaque modification d'image source.

**Entrée :** `TMP/PI1/*.PI1`
**Sortie :** `DATA/GFX/*.PAL`

**Dépendances :**
- `INC/TOS.I` — Fcreate, Fwrite, Fclose
- `INC/AES.I` — appl_init, form_alert, appl_exit

---

### `TOOLS/PI1RHEAD/PI1RHEAD.S`
**Rôle :** Extrait les pixels bruts (32000 bytes à l'offset +34) d'un fichier `.PI1` et les écrit dans un fichier `.RAW`. À exécuter sous Hatari après chaque modification d'image source.

**Entrée :** `TMP/PI1/*.PI1`
**Sortie :** `DATA/GFX/*.RAW`

**Dépendances :**
- `INC/TOS.I` — Fcreate, Fwrite, Fclose
- `INC/AES.I` — appl_init, form_alert, appl_exit

---

### `TOOLS/SPR2BIN/SPR2BIN.S`
**Rôle :** Extrait une grille de sprites depuis un fichier `.PI1` et génère un fichier `.BIN` au format propriétaire du jeu. Les sprites sont lus ligne par ligne (pass 1 : pixels, pass 2 : masques). Le header BIN (16 bytes) contient la largeur et la hauteur. À ré-exécuter après toute modification des sprites ennemis.

**Format BIN généré :**
```
[16 bytes header : width(w), height(w), 12 bytes réservés]
[sprite 0 : SPR_H*8 bytes pixels][sprite 0 : SPR_H*8 bytes masque]
[sprite 1 : ...]
...
```

**Entrée :** `TMP/PI1/ENEMIES.PI1`
**Sortie :** `DATA/GFX/ENEMIES1.BIN`

**Dépendances :**
- `INC/TOS.I` — Fcreate, Fwrite, Fclose
- `INC/AES.I` — appl_init, form_alert, appl_exit

---

## Machine à états

```
TITLE ──(START)──► READY ──(1 sec)──► PLAY
                     ▲                  │
                     │            ┌─────┴──────┐
                     │         DEATH        NEXT_LVL (TODO)
                     │            │              │
                     └────────────┘         (1 sec)
                     (vies > 0)                  │
                                                 ▼
                                               READY
                   GAMEOVER ◄──(vies = 0)──── DEATH
                      │
                   (2 sec)
                      │
                      ▼
                    TITLE
```

---

## Flux de compilation

Tout le projet est assemblé en un seul passage depuis `MAIN.S` sous DevPac 3 :

```
MAIN.S
  ├── include INC/*.I          (constantes, macros, hardware)
  ├── include SRC/SYS.S        (système TOS)
  ├── include SRC/GFX.S        (moteur graphique + incbin DATA/)
  ├── include SRC/PHYS.S       (physique)
  ├── include SRC/DEBUG.S      (debug)
  ├── include SRC/SND.S        (son - stub)
  ├── include SRC/LOOPS/*.S    (états du jeu)
  └── include SRC/VARS.S       (BSS - doit être en dernier)
        └── SECTION BSS
```

Sortie : `SRC/MAIN.PRG`
