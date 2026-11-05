# CHANGELOG

## 1.0.10

- ajout d'un gestionnaire global `Scripts/input_mode_manager.gd` (autoload `InputModeManager`)
- règle globale UX : le dernier périphérique utilisé pilote l'interface (souris, clavier, manette)
- en navigation clavier/manette, le curseur souris est masqué
- en navigation clavier/manette, les styles `hover` des boutons sont neutralisés pour éviter le double état visuel focus + hover
- au retour souris (mouvement/clic), le curseur et les styles `hover` sont restaurés automatiquement

## 1.0.9

- ajout d'un second jeu jouable : **Mode instable**
- création de `Scenes/instable_mode.tscn` + `Scripts/instable_mode.gd` en réutilisant le visuel du mode Classic
- dans ce mode, le clavier reste visible et se remappe automatiquement toutes les secondes
- suppression des pénalités de temps sur erreur pour ce mode
- en cas de mauvaise touche, la séquence à taper repart du début
- activation du bouton du second jeu dans `Scenes/game_selection_modal.tscn` et routage vers la nouvelle scène

## 1.0.8

- ajout d'une modale dédiée à la sélection du jeu (`Scenes/game_selection_modal.tscn`)
- le bouton **Jouer** ouvre désormais la sélection de jeu au lieu de lancer directement une partie
- renommage du jeu existant en **Classic** dans la modale de sélection
- ajout d'un emplacement prêt pour un second jeu (désactivé pour le moment)
- ajout d'un panneau de règles à droite de la liste, mis à jour selon le bouton de jeu qui a le focus

## 1.0.7

- transformation de la modale principale en modale dédiée uniquement aux options
- intégration statique de `options_content` dans `Scenes/options_modal.tscn` (plus d'injection dynamique)
- déplacement de la logique de configuration/sauvegarde des options dans `Scripts/options_modal.gd`
- retrait de l'usage de cette modale pour les règles ; les règles passent désormais par un `AcceptDialog` dédié dans `Scenes/main_menu.tscn`

## 1.0.6

- correction du format de sauvegarde des scores
- correction d'un bug sur le bouton **_Recommencer_** qui ne réinitialisait pas correctement la vue une fois la partie terminée
- ajout d'un shortcut (escape button) sur le bouton **_Retour_** dans les modales du menu principal
- ajout du README
- ajout du changelog
- ajout d'un peu d'espace entre les separateurs horizontaux dans les modales du menu principal
- correction d'un bug qui réactivait le bouton **_Classement_** si celui ne contenait quand meme aucun score enregistré
