Titre du projet : Propagation de température en C avec listes chaînées


Description :

Ce projet propose une simulation numérique de la propagation de la température dans un système à deux dimensions en utilisant le langage C et des listes chaînées. Chaque nœud de la liste représente un point de la grille avec sa température, permettant une gestion dynamique de la mémoire et une simulation flexible.
Partie physique :
La simulation repose sur l’équation de diffusion de la chaleur :
[
\frac{\partial T}{\partial t} = \alpha \left( \frac{\partial^2 T}{\partial x^2} + \frac{\partial^2 T}{\partial y^2} \right)
]
Le domaine est discrétisé en un maillage, et les températures aux points sont mises à jour en utilisant des fonctions de forme pour approximer la variation continue. Cette approche permet de relier la théorie physique aux calculs numériques et d’obtenir des résultats précis.
Fonctionnalités principales :

Initialisation de la grille avec des températures de départ.

Diffusion de la chaleur appliquée sur chaque point du maillage.

Contrôle interactif : possibilité de chauffer ou refroidir certaines zones.

Alertes sonores et visuelles lorsque la température atteint des valeurs extrêmes.

Mode nuit et visualisation graphique via Gnuplot pour suivre l’évolution de la température.

Applications industrielles :
Ce modèle de simulation peut être utilisé pour optimiser la gestion thermique dans différents secteurs :

Congélation et conservation des aliments : poissons, viandes, produits laitiers.

Industrie laitière : maintien de la température dans les bouteilles de lait pour éviter la détérioration.

Data centers et centres informatiques : suivi et contrôle des températures pour éviter la surchauffe des serveurs et réduire la consommation énergétique.

Objectifs pédagogiques et techniques :

Maîtrise des listes chaînées et de la gestion dynamique de mémoire en C.

Compréhension des principes physiques de diffusion thermique.

Intégration de signaux sonores et visuels pour la surveillance des extrêmes.

Utilisation de Gnuplot pour visualiser graphiquement les résultats.

Technologies utilisées :

Langage : C

Structures de données : Liste chaînée

Visualisation : Gnuplot

Interactions et alertes : Signaux sonores et visuels
